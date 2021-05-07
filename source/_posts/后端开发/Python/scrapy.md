---
title: Scrapy
tags: 
    - Python
categories: 
    - 后端开发
date: 2017-12-3
---

[官方文档](https://docs.scrapy.org/en/latest/)
# Spiders

## 通用爬虫(Generic Spider)

Scrapy内置了一些通用的爬虫基类，你可以通过继承这些基类来快速构建自己的爬虫。这些内置爬虫基类提供了许多常用功能，比如：通过指定的规则，sitemaps或者xml/csv格式的feed文件爬取网站的链接。   
接下来的例子，假定你已经创建了scrapy项目，在items.py
中申明TestItem类：
```python
import scrapy
class TestItem(scrapy.Item):
    id = scrapy.Field()
    name = scrapy.Field()
    description = scrapy.Field()
```

### CrawlSpider
```python
class scrapy.spiders.CrawlSpider
```
<!-- more -->
这是爬取正规网站最常用的爬虫，它通过一系列的规则为跟踪网站链接提供方便的机制。对于特殊的网站或项目它或许不是最适合的，但对于常用的网站足矣。对于特殊的功能，你可以继承它，然后重载自定义部分即可，或者用它来实现你自己的爬虫。    
与从spider继承的属性（需要指定）不同的是，该类支持一个特殊的属性：
> rules     
    
Rule对象的一个或多个列表，每个Rule为爬取网站定义了明确的行为。Rules Objects将在后面的部分进行介绍。如果多个Rule匹配了同一个链接，只有第一个匹配生效，取决于它们在改属性中的顺序。

CrawlSpider还暴露了一个可重写的方法：
> parse_start_url(response)

    这个方法将被start_urls的响应调用，它允许解析初始的responses,必须返回一个Item对象或一个Request对象，或者一个包含这2个对象的可迭代类型。

#### Crawling rules
```python
class scrapy.spiders.Rule(link_extractor,callback=None,cb_kwargs=None,follow=None,process_links=None,process_request=None)   
```

link_extractor是一个[Link Extractor](https://docs.scrapy.org/en/latest/topics/link-extractors.html#topics-link-extractors)对象，用于提取爬取到的页面中的链接。    
callback每个提取到的链接调用的函数或字符串，这个callback的第一个参数是链接的response，必须返回一个Item或Request对象。
> 注意：不能将parse作为callback，因为CrawlSpider使用parse作为它处理逻辑的默认方法，如果重写,crawl spider讲不能正常工作。

cb_kwargscallback的参数
follow布尔类型，控制是否爬取页面中提取到的链接。如果没有callback，follow的默认值为True,否则默认False
process_links功能类似callback，主要用于过滤
process_request 被匹配本条Rule的request调用，必须返回一个request或者None

#### CrawlSpider例子
```python
import scrapy
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor

class MySpider(CrawlSpider):
    name = 'example.com'
    allowed_domains = ['example.com']
    start_urls = ['http://www.example.com']

    rules = (
        # Extract links matching 'category.php' (but not matching 'subsection.php')
        # and follow links from them (since no callback means follow=True by default).
        Rule(LinkExtractor(allow=('category\.php', ), deny=('subsection\.php', ))),

        # Extract links matching 'item.php' and parse them with the spider's method parse_item
        Rule(LinkExtractor(allow=('item\.php', )), callback='parse_item'),
    )

    def parse_item(self, response):
        self.logger.info('Hi, this is an item page! %s', response.url)
        item = scrapy.Item()
        item['id'] = response.xpath('//td[@id="item_id"]/text()').re(r'ID: (\d+)')
        item['name'] = response.xpath('//td[@id="item_name"]/text()').extract()
        item['description'] = response.xpath('//td[@id="item_description"]/text()').extract()
        return item
```
这个爬虫将爬取example.com的首页，收集category和item页面的链接，item页面的链接使用parse_item方法解析，每个response将使用xpath提取数据，并返回一个Item对象。
    
### XMLFeedSpider
```python
class scrapy.spiders.XMLFeedSpider
```
XMLFeedSpider被设计用来通过迭代指定的节点解析xml格式的订阅内容。解析器可选：iternodes,xml和html。出于性能考虑，推荐使用iternodes，因为xml和html为了解析一次性生成了整个DOM。然而，当解析的XML标记有问题时，使用html作为解析器是不错的选择。  
通过设置以下类属性来设置解析器和标签名：    
iterator 字符串，定义解析器。
- 'iternodes' 基于正则表达式的快速解析器,默认。
- 'html' 使用Selector的解析器，将所有Dom加载进内存，然后通过Dom解析。
- 'xml' 同html

itertag 定义解析的节点
```python
    itertag = 'product'
```

namespaces
包含(prefix,uri)的列表，prefix和uri将会通过调用register_namespace()方法注册。
然后，你就可以在itertag中通过命名空间指定节点.
```python
class Spider(XMLFeedSpider):
    namespaces = [('n', 'http://www.sitemaps.org/schemas/sitemap/0.9')]
    itertag = 'n:url'
```

可重写的方法：
> adapt_response(response)
在response到达spider中间件后，spider解析前，对response body进行修改,返回一个新的reponse或者原来的response


> parse_node(response, selector)
被itertag匹配的nodes调用，接收node的response和Selector,这个方法是必须重写的，否则，spider将不能正常工作。
返回一个Item对象或Request对象，或者包含它们的可迭代内容。

> process_results(response, results)
被spider返回的结果调用，用于处理返回至框架核心前的最后一次请求，比如：设置item的ID。它接收一个结果的列表和生成这些结果的response。它必须返回一个结果的列表。

#### XMLFeedSpider 例子：
```python
from scrapy.spiders import XMLFeedSpider
from myproject.items import TestItem

class MySpider(XMLFeedSpider):
    name = 'example.com'
    allowed_domains = ['example.com']
    start_urls = ['http://www.example.com/feed.xml']
    iterator = 'iternodes'  # This is actually unnecessary, since it's the default value
    itertag = 'item'

    def parse_node(self, response, node):
        self.logger.info('Hi, this is a <%s> node!: %s', self.itertag, ''.join(node.extract()))

        item = TestItem()
        item['id'] = node.xpath('@id').extract()
        item['name'] = node.xpath('name').extract()
        item['description'] = node.xpath('description').extract()
```
spider下载start_urls中给定的feed文档，然后通过itertag标签迭代节点item，输出并存储随机数据到Item中。

### CSVFeedSpider
```python
class scrapy.spiders.CSVFeedSpider
```
CSVFeedSpider和XMLFeedSpider很像，除了迭代的对象是rows而不是nodes。每个迭代过程中调用parse_row()。
> delimiter      

每个字段的分隔符，在CSV文件中默认是','

> quotechar

包含每个字段的符号，在CSV中默认是'"'

> headers

CSV文件的列名，一个列表[]

> parse_row(response,row)

接收一个reponse参数和一个字典(代表每一行，键是csv文件的列名)。

CSVFeedSpider也可重写adapt_response 和 process_results方法。

实例:
```python
from scrapy.spiders import CSVFeedSpider
from myproject.items import TestItem

class MySpider(CSVFeedSpider):
    name = 'example.com'
    allowed_domains = ['example.com']
    start_urls = ['http://www.example.com/feed.csv']
    delimiter = ';'
    quotechar = "'"
    headers = ['id', 'name', 'description']

    def parse_row(self, response, row):
        self.logger.info('Hi, this is a row!: %r', row)

        item = TestItem()
        item['id'] = row['id']
        item['name'] = row['name']
        item['description'] = row['description']
        return item
```
### SitemapSpider
```python
class scrapy.spiders.SitemapSpider
```
SitemapSpider允许你根据网站的sitemaps进行爬取内容。它支持嵌套的sitemaps和从robots.txt文件中发现sitemap。

> sitemap_urls  

 一个指向sitemaps的列表，包含了爬虫将要爬取得urls，也可指向robots.txt文件，它将从中提取出sitemap的urls
 

> sitemap_rules

一个(regex,callback)的列表：
regex: 从sitemaps中匹配urls的正则表达式，regex可以是字符串或编译的正则表达式对象。  
callback：字符串或可调用的函数
    
```
sitemap_rules = [('/product/', 'parse_product')]
```
规则按顺序匹配，选择匹配到的第一个。如果省略该属性，sitemap_urls中的所有urls将被parse处理。

> sitemap_follow

需要被跟踪的sitemap的正则表达式列表。仅对使用sitemap文件指向其他sitemap文件的站点有效。    
默认的所有站点将被followed。

> sitemap_alternate_links

指定 alternate links是否应该被followed。alternate links是指向同一网站的不同语言链接,使用的同一个url标记。
如：
```xml
<url>
    <loc>http://example.com/</loc>
    <xhtml:link rel="alternate" hreflang="de" href="http://example.com/de"/>
</url>
```
如果配置了sitemap_alternate_links，将会检测http://example.com/和http://example.com/de。
如果sitemap_alternate_links 为disabled，将只会检测http://example.com/，默认为disabled。

例子：
```python
//解析sitemaps中的所有url

from scrapy.spiders import SitemapSpider

class MySpider(SitemapSpider):
    sitemap_urls = ['http://www.example.com/sitemap.xml']

    def parse(self, response):
        pass # ... scrape item here ...

```

```python
//通过sitemap_rules分别指定不同的链接的解析
from scrapy.spiders import SitemapSpider

class MySpider(SitemapSpider):
    sitemap_urls = ['http://www.example.com/sitemap.xml']
    sitemap_rules = [
        ('/product/', 'parse_product'),
        ('/category/', 'parse_category'),
    ]

    def parse_product(self, response):
        pass # ... scrape product ...

    def parse_category(self, response):
        pass # ... scrape category ...
```
```python
//通过robots.txt文件跟踪sitemaps，并且只跟踪包含/sitemap_shop的链接

from scrapy.spiders import SitemapSpider

class MySpider(SitemapSpider):
    sitemap_urls = ['http://www.example.com/robots.txt']
    sitemap_rules = [
        ('/shop/', 'parse_shop'),
    ]
    sitemap_follow = ['/sitemap_shops']

    def parse_shop(self, response):
        pass # ... scrape shop here ...
```

结合SitemapSpider和其他的urls
```python
from scrapy.spiders import SitemapSpider

class MySpider(SitemapSpider):
    sitemap_urls = ['http://www.example.com/robots.txt']
    sitemap_rules = [
        ('/shop/', 'parse_shop'),
    ]

    other_urls = ['http://www.example.com/about']

    def start_requests(self):
        requests = list(super(MySpider, self).start_requests())
        requests += [scrapy.Request(x, self.parse_other) for x in self.other_urls]
        return requests

    def parse_shop(self, response):
        pass # ... scrape shop here ...

    def parse_other(self, response):
        pass # ... scrape other here ...
```

# Selectors
当你爬取网站页面的时候，最常见的事情就是从html中提取数据。下面介绍几个这方面的库：
- BeautifulSoup
    在python开发者中非常流行的爬虫库，通过html结构创建python对象，能够合理的处理坏标签。但是它有一个缺点：慢。
- lxml
    xml解析库，也能解析html，通过一个pythonic的API：ElementTree。lxml不是python标准库的一部分。

Scrapy有自己的提取数据的机制，被称为selectors，因为它通过XPath或CSS表达式选择HTML中指定部分。

XPath是一重在XML文档中选择nodes的语言，也能够用于html。CSS是应用于html样式的语言。它定义selectors关联到那些指定样式的html元素。

Scrapy selectors是建立在lxml库上的，这意味着它们在速度和解析准确度上非常相似。

下面介绍selectors是如何工作的，以及描述它小而简单的API，不同于lxml API，lxml API非常大，因为它被用来实现很多任务，不仅仅是选择文档标记。

完整的[Selector](https://docs.scrapy.org/en/latest/topics/selectors.html#topics-selectors-ref)参考

## 使用Selectors

**构建Selectors**
Scrapy selectors是Selector类的实例，通过传入text或TextResponse对象生成。它根据输入的类型自动选择最合适的解析规则（XML vs HTML）。
```python
>>from scrapy.selector import Selector
>>from scrapy.http import HtmlResponse
//通过text构建
>>body = '<html><body><span>good</span></body></html>'
>>Selector(text=body).xpath('//span/text()').extract()
[u'good']
//从response构建
>>response = HtmlResponse(url='http://example.com',body=body)
>>Selector(response=response).xpath('//span/text()').extract()
[u'good]
```
为了更便捷，response暴露了一个属性.selector，完全等价于上面的操作：
```python
response.selector.xpath('//span/text()').extract()
```
**使用**
为了解释怎么使用selectors，我们接下来将使用Scrapy shell和Scrapy服务器上的页面做实验：    
[官网链接](http://doc.scrapy.org/en/latest/_static/selectors-sample1.html)

HTML文档内容：
```html
<html>
 <head>
  <base href='http://example.com/' />
  <title>Example website</title>
 </head>
 <body>
  <div id='images'>
   <a href='image1.html'>Name: My image 1 <br /><img src='image1_thumb.jpg' /></a>
   <a href='image2.html'>Name: My image 2 <br /><img src='image2_thumb.jpg' /></a>
   <a href='image3.html'>Name: My image 3 <br /><img src='image3_thumb.jpg' /></a>
   <a href='image4.html'>Name: My image 4 <br /><img src='image4_thumb.jpg' /></a>
   <a href='image5.html'>Name: My image 5 <br /><img src='image5_thumb.jpg' /></a>
  </div>
 </body>
</html>
```
首先，打开shell
```python
scrapy shell http://doc.scrapy.org/en/latest/_static/selectors-sample1.html
```
然后，等待加载完成，你可以通过response变量获取响应结果，并且包含了response.selector属性。   
因为我们处理的HTML，选择器自动使用HTML parser。 
查看HTML页面代码，让我们一起构建一个XPath来获取title标记中的文本：
```python
>>> response.selector.xpath('//title/text()')
[<Selector (text) xpath=//title/text()>]
```
因为查询响应使用XPath和CSS太常用了，所以reponses提供了2个便利的方式：response.xpath() 和 response.css():
```python
>>> response.xpath('//title/text()')
[<Selector (text) xpath=//title/text()>]
>>> response.css('title::text')
[<Selector (text) xpath=//title/text()>]
```
如你所见，.xpath()和.css()方法返回一个selector实例的列表，使用这个API可以快速的选择嵌套的数据。
```python
>>> response.css('img').xpath('@src').extract()
[u'image1_thumb.jpg',
 u'image2_thumb.jpg',
 u'image3_thumb.jpg',
 u'image4_thumb.jpg',
 u'image5_thumb.jpg']
```
提取文本数据，你必须使用.extract()方法，如下：
```python
>>> response.xpath('//title/text()').extract()
[u'Example website']
```
如果你只是想提取匹配到的第一个元素，可以使用.extract_first()
```python
>>> response.xpath('//div[@id="images"]/a/text()').extract_first()
u'Name: My image 1 '
```
如果没有找到元素将返回None,可通过传递一个参数来设置默认值取代None：
```python
>>> response.xpath('//div[@id="not-exists"]/text()').extract_first(default='not-found')
'not-found'
```
css选择器可以使用css3的伪类元素来选择文本：
```python
>>> response.css('title::text').extract()
[u'Example website']
```
现在我们将获取基本的URL和一些图片链接：
```python
>>> response.xpath('//base/@href').extract()
[u'http://example.com/']

>>> response.css('base::attr(href)').extract()
[u'http://example.com/']

>>> response.xpath('//a[contains(@href, "image")]/@href').extract()
[u'image1.html',
 u'image2.html',
 u'image3.html',
 u'image4.html',
 u'image5.html']

>>> response.css('a[href*=image]::attr(href)').extract()
[u'image1.html',
 u'image2.html',
 u'image3.html',
 u'image4.html',
 u'image5.html']

>>> response.xpath('//a[contains(@href, "image")]/img/@src').extract()
[u'image1_thumb.jpg',
 u'image2_thumb.jpg',
 u'image3_thumb.jpg',
 u'image4_thumb.jpg',
 u'image5_thumb.jpg']

>>> response.css('a[href*=image] img::attr(src)').extract()
[u'image1_thumb.jpg',
 u'image2_thumb.jpg',
 u'image3_thumb.jpg',
 u'image4_thumb.jpg',
 u'image5_thumb.jpg']
```
**嵌套选择器**
.xpath()和.css()返回一些相同类型的selectors，因此你能为这些selectors调用selection的方法。
```python
>>> links = response.xpath('//a[contains(@href, "image")]')
>>> links.extract()
[u'<a href="image1.html">Name: My image 1 <br><img src="image1_thumb.jpg"></a>',
 u'<a href="image2.html">Name: My image 2 <br><img src="image2_thumb.jpg"></a>',
 u'<a href="image3.html">Name: My image 3 <br><img src="image3_thumb.jpg"></a>',
 u'<a href="image4.html">Name: My image 4 <br><img src="image4_thumb.jpg"></a>',
 u'<a href="image5.html">Name: My image 5 <br><img src="image5_thumb.jpg"></a>']

>>> for index, link in enumerate(links):
...     args = (index, link.xpath('@href').extract(), link.xpath('img/@src').extract())
...     print 'Link number %d points to url %s and image %s' % args

Link number 0 points to url [u'image1.html'] and image [u'image1_thumb.jpg']
Link number 1 points to url [u'image2.html'] and image [u'image2_thumb.jpg']
Link number 2 points to url [u'image3.html'] and image [u'image3_thumb.jpg']
Link number 3 points to url [u'image4.html'] and image [u'image4_thumb.jpg']
Link number 4 points to url [u'image5.html'] and image [u'image5_thumb.jpg']
```
**使用带正则表达式的选择器**
Selector还有一个.re()方法，用于使用正则表达式提取数据。然而，不像.xpath()或.css()方法，.re()返回一个unicode字符串的列表。所以.re()不能嵌套。

从上面的html代码中提取图片名称：
```python
> response.xpath('//a[contains(@href, "image")]/text()').re(r'Name:\s*(.*)')
[u'My image 1',
 u'My image 2',
 u'My image 3',
 u'My image 4',
 u'My image 5']
```
提取匹配的第一个字符串：.re_first()
```
>>> response.xpath('//a[contains(@href, "image")]/text()').re_first(r'Name:\s*(.*)')
u'My image 1'
```

**使用相对路径的XPaths**
如果你使用'/'开头的XPath进行嵌套选择，那么XPath将是相对于文档的绝对路径，而不是上一层选择器的路径。比如，你想选择出所有div下的p元素：
```python
>> divs = response.xpath('//div')
```
接下来，你可能想这样提取p元素：
```python
>>[p.extract() for p in div.xpath('//p')]
```
但是，这是错误的，这样将提取到所有的p元素。应该这样来写：
```python
>> [p.extract() for p in div.xpath('.//p')]
```
更多关于[XPath相对路径](https://www.w3.org/TR/xpath#location-paths)的资料

**XPath表达式中的变量**
XPath允许在表达式中使用变量，语法：$var。
下面通过id属性的值来匹配元素，没有硬编码。
```python
>> response.xpath('//div[@id=$val]/a/text()',val='images').extract_first()
u'Name: My image 1'
```
另外一个例子：查找含有5个a标签的div的id
```python
>> response.xpath('//div[count(a)=$cnt]/@id',cnt=5).extract_first()
u'images'
```
所有引用的变量都必须赋值，不然xpath将报错。
更多关于[XPath Variable](https://parsel.readthedocs.io/en/latest/usage.html#variables-in-xpath-expressions)

**使用EXSLT扩展**

建立在lxml上，Scrapy选择器也支持EXSLT扩展，内置了一些预先注册好的命名空间可以在XPath表达式中使用。

prefix | namespace | usage
---|---|---
re | http://exslt.org/regular-expressions | regular expressions
set| http://exslt.org/sets | set manipulation

**正则表达式**

当XPath的starts-with()或contains()不够用的时候，test()函数将会非常有用。
例如:从class以数字结尾的list的元素下提取链接。
```python
>>from scrapy import Selector
>> doc = """
... <div>
...     <ul>
...         <li class="item-0"><a href="link1.html">first item</a></li>
...         <li class="item-1"><a href="link2.html">second item</a></li>
...         <li class="item-inactive"><a href="link3.html">third item</a></li>
...         <li class="item-1"><a href="link4.html">fourth item</a></li>
...         <li class="item-0"><a href="link5.html">fifth item</a></li>
...     </ul>
... </div>
... """
>> sel = Selector(text=doc,type='html')
>> sel.xpath('//li//a/@href').extract()
[u'link1.html', u'link2.html', u'link3.html', u'link4.html', u'link5.html']
>> sel.xpath('//li[re:test(@class,"item-\d$")]//@href').extract()
[u'link1.html', u'link2.html', u'link4.html', u'link5.html']
```
**设置操作**
可以方便的在提取文本元素前排除部分dom元素。
例如提取item的范围和相对应的属性
```python
>>> doc = """
... <div itemscope itemtype="http://schema.org/Product">
...   <span itemprop="name">Kenmore White 17" Microwave</span>
...   <img src="kenmore-microwave-17in.jpg" alt='Kenmore 17" Microwave' />
...   <div itemprop="aggregateRating"
...     itemscope itemtype="http://schema.org/AggregateRating">
...    Rated <span itemprop="ratingValue">3.5</span>/5
...    based on <span itemprop="reviewCount">11</span> customer reviews
...   </div>
...
...   <div itemprop="offers" itemscope itemtype="http://schema.org/Offer">
...     <span itemprop="price">$55.00</span>
...     <link itemprop="availability" href="http://schema.org/InStock" />In stock
...   </div>
...
...   Product description:
...   <span itemprop="description">0.7 cubic feet countertop microwave.
...   Has six preset cooking categories and convenience features like
...   Add-A-Minute and Child Lock.</span>
...
...   Customer reviews:
...
...   <div itemprop="review" itemscope itemtype="http://schema.org/Review">
...     <span itemprop="name">Not a happy camper</span> -
...     by <span itemprop="author">Ellie</span>,
...     <meta itemprop="datePublished" content="2011-04-01">April 1, 2011
...     <div itemprop="reviewRating" itemscope itemtype="http://schema.org/Rating">
...       <meta itemprop="worstRating" content = "1">
...       <span itemprop="ratingValue">1</span>/
...       <span itemprop="bestRating">5</span>stars
...     </div>
...     <span itemprop="description">The lamp burned out and now I have to replace
...     it. </span>
...   </div>
...
...   <div itemprop="review" itemscope itemtype="http://schema.org/Review">
...     <span itemprop="name">Value purchase</span> -
...     by <span itemprop="author">Lucas</span>,
...     <meta itemprop="datePublished" content="2011-03-25">March 25, 2011
...     <div itemprop="reviewRating" itemscope itemtype="http://schema.org/Rating">
...       <meta itemprop="worstRating" content = "1"/>
...       <span itemprop="ratingValue">4</span>/
...       <span itemprop="bestRating">5</span>stars
...     </div>
...     <span itemprop="description">Great microwave for the price. It is small and
...     fits in my apartment.</span>
...   </div>
...   ...
... </div>
... """
>>> sel = Selector(text=doc, type="html")
>>> for scope in sel.xpath('//div[@itemscope]'):
...     print "current scope:", scope.xpath('@itemtype').extract()
...     props = scope.xpath('''
...                 set:difference(./descendant::*/@itemprop,
...                                .//*[@itemscope]/*/@itemprop)''')
...     print "    properties:", props.extract()
...     print

current scope: [u'http://schema.org/Product']
    properties: [u'name', u'aggregateRating', u'offers', u'description', u'review', u'review']

current scope: [u'http://schema.org/AggregateRating']
    properties: [u'ratingValue', u'reviewCount']

current scope: [u'http://schema.org/Offer']
    properties: [u'price', u'availability']

current scope: [u'http://schema.org/Review']
    properties: [u'name', u'author', u'datePublished', u'reviewRating', u'description']

current scope: [u'http://schema.org/Rating']
    properties: [u'worstRating', u'ratingValue', u'bestRating']

current scope: [u'http://schema.org/Review']
    properties: [u'name', u'author', u'datePublished', u'reviewRating', u'description']

current scope: [u'http://schema.org/Rating']
    properties: [u'worstRating', u'ratingValue', u'bestRating']

>>>
```
首先，遍历了itemscope元素，针对每个itemscope查找itemprops并排除那些包含在其他itemscop中的itemprops。

**关于XPath的一些建议**
[一篇来自ScrapingHub的博客](https://blog.scrapinghub.com/2014/07/17/xpath-tips-from-the-web-scraping-trenches/?_ga=2.21172475.1955907946.1512143556-1857011771.1512143556)
[XPath文档](http://www.zvon.org/comp/r/tut-XPath_1.html)


使用text节点的时候需要注意，当你将text内容作为参数传递给XPath string function时，避免使用.//text()，用.代替即可。
因为表达式.//text()产生一个text元素的集合node-set,当node-set转换为string的时候，比如传递给contains()或starts-width()，将导致只会传递第一个元素的值。
```python
>>> from scrapy import Selector
>>> sel = Selector(text='<a href="#">Click here to go to the <strong>Next Page</strong></a>')
>>> sel.xpath('//a//text()').extract() # take a peek at the node-set
[u'Click here to go to the ', u'Next Page']
>>> sel.xpath("string(//a[1]//text())").extract() # convert it to string
[u'Click here to go to the ']
```
将一个node节点转换为string,将提取出该节点下的所有text
```python
>>> sel.xpath("//a[1]").extract() # select the first node
[u'<a href="#">Click here to go to the <strong>Next Page</strong></a>']
>>> sel.xpath("string(//a[1])").extract() # convert it to string
[u'Click here to go to the Next Page']
```
所以，选择含有Next Page文本的a标签，如果这样写：
```python
>> sel.xpath("//a[contains(.//text(),'Next Page')]").extract()
[]
```
将不会有任何输出，因为原意是想先获取a的所有文本，然后检测是否包含'Next Page',
但是此处的.//text()转换为string只会输出[u'Click here to go to the '],并不包含'Next Page'。所以，应该这样写：
```python
>> sel.xpath("//a[contains(.,'Next Page')]").extract()
[u'<a href="#">Click here to go to the <strong>Next Page</strong></a>']
```

注意区分 //node[1] 和 (//node)[1]   
`//node[1]`选择所有匹配节点各自父节点的第一个子节点
`(//node)[1]`选择文档中的所有匹配节点，然后返回第一个
例：
```python
>>> from scrapy import Selector
>>> sel = Selector(text="""
....:     <ul class="list">
....:         <li>1</li>
....:         <li>2</li>
....:         <li>3</li>
....:     </ul>
....:     <ul class="list">
....:         <li>4</li>
....:         <li>5</li>
....:         <li>6</li>
....:     </ul>""")
>>> xp = lambda x: sel.xpath(x).extract()
>>> xp("//li[1]")
[u'<li>1</li>', u'<li>4</li>']
>>> xp("(//li)[1]")
[u'<li>1</li>']
>>> xp("//ul/li[1]")
[u'<li>1</li>', u'<li>4</li>']
>>> xp("(//ul/li)[1]")
[u'<li>1</li>']
```
使用class查询时，考虑使用CSS    
因为一个元素能够包含多个css，XPath选择元素相对css来说是很冗长的：
```python
*[contains(concat(' ', normalize-space(@class), ' '), ' someclass ')]
```
如果你使用`@class='someclass'`，将会丢失许多含有其他class的元素，如果使用`contains(@class,'someclass')`，将有可能包含多余的class含有someclass子字符串的元素。
Scrapy允许链式调用selectors，所以你可以先用css选择然后再用xpath。
```python
>>> from scrapy import Selector
>>> sel = Selector(text='<div class="hero shout"><time datetime="2014-07-23 19:00">Special date</time></div>')
>>> sel.css('.shout').xpath('./time/@datetime').extract()
[u'2014-07-23 19:00']
```
### 内置的Selectors参考

#### Selector 对象
```python
class scrapy.selector.Selector(response=None,text=None,type=None)
```
Selector的实例是包装在response上用于提取指定的内容。       
`response`:一个 `HtmlResponse`或`XmlResponse`对象，用于选择和导出数据。         
`text`:unicode字符串或utf-8编码的文本，当`response`不存在的情况下。同时使用`text`和`response`是不可行的。   
`type`:定义选择器类型:"html"，"xml"或"None"(默认)

如果`type`为`None`时，选择器自动根据`response`选择最合适的类型，或如果类型为`text`时将默认为`"html"`。      
如果`type`为`None`，传递了`response`，选择器类型将从`response`类型中推算：
- `"html"`：`HtmlResponse`
- `"xml"`：`XmlResponse`
- `"html"`：anything

否则，如果`type`设定了，选择器类型将被强制指定为type，不再进行检测。

> xpath(query)

> css(query)

> extract()

> re(regex)

> register_namespace(prefix,url)

> remove_namespaces()

> __nonzero__()
是否选中内容


#### SelectorList objects
```python
class scrapy.selector.SelectorList
```

`SelectorList`类是`list`的一个子类，提供了一些附加的方法。

> xpath(query)

> css(query)

> extract()

> re()

#### 基于HTML Response的Selector例子
假定sel是用一个`HtmlResponse`实例化的`Selector`
```python
sel = Selector(html_response)
sel.xpath("//h1")
sel.xpath("//h1").extract()  # includes h1
sel.xpath("//h1/text()").extract() # excludes h1
# 遍历所有的p标签，打印它们的类属性
for node in sel.xpath("//p"):
    print node.xpath("@class").extract()
```

#### 基于XML Response的Selector例子
假设sel是用`XmlResponse`实例化的`Selector`
```python
sel = Selector(xml_response)
sel.xpath("//product")
```
从指定文档提取所有价格，需要使用命名空间：
```python
sel.register_namespace("g","http://base.google.com/ns/1.0")
sel.xpath("//g:price").extract()
```

**移除命名空间**

在Scrapy项目中，为了写更多简单便捷的XPaths,经常需要移除命名空间，仅剩元素名称。
`Selector.remove_namespaces()`

```python
>> scrapy shell https://github.com/blog.atom
>> response.xpath("//link")
[]
# 因为Atom XML命名空间扰乱了节点
>>> response.selector.remove_namespaces()
>>> response.xpath("//link")
[<Selector xpath='//link' data=u'<link xmlns="http://www.w3.org/2005/Atom'>,
 <Selector xpath='//link' data=u'<link xmlns="http://www.w3.org/2005/Atom'>,
 ...
]
```
不默认移除命名空间的原因有二：
1. 移除命名空间需要遍历所有的文档，对于爬虫来说这是一个相当费时且昂贵的操作。
2. 有些时候需要使用命名空间来避免名称冲突。

# Items
## 声明Itmes
使用class和`Field`对象来声明一个Item，如下所示：
```python
import scrapy

Class Product(scrapy.Item):
    name = scrapy.Field()
    price = scrapy.Field()
    stock = scrapy.Field()
    last_updated = scrapy.Field(serializer=str)
```

    注意：Scrapy中的Items定义和Django中Models定义很像，不同的是Items中没有多种字段类型，只有简单的`scrapy.Field`

## Item Fields
`Field`对象为每个字段指定metadata，例如上例中`last_updated`字段的serializer方法。

可以为每个字段指定任何类型的metadata,Field对象并没有限制接收的values，所以，这里并没有列出所有的`metadata keys`。在Field对象中定义的每个字段对应不同的功能，你也可以根据你的需要定义别的字段。`Field`对象的主要目标是提供一种在一个地方定义所有元数据(metadata)的方法。你可以查阅相关文档来使用metadata。

值得注意的是`Field`对象用来声明item字段的时候，该字段并不是作为类的属性，
相反，可以通过`Item.fields`(此处Item对应Product)属性来访问。(类似dict而不是object)

## 使用Items
这里有一些使用items的通用案例，使用上面声明的`Product`，你将会发现API非常类似`dict API`

### 创建items
```python
>>> product = Product(name='Desktop PC',price=1000)
>>> print product
Product(name='Desktop PC',price=1000)
```

### 获取字段值
```python
>> product['name']
Desktop PC
>>> product.get('name')
Desktop PC
>>> product['price']
1000
>>> product['last_updated']
Traceback (most recent call last):
    ...
KeyError: 'last_updated'
>>> product.get('last_updated', 'not set')
not set
>>> product['lala'] # getting unknown field
Traceback (most recent call last):
    ...
KeyError: 'lala'
>>> product.get('lala', 'unknown field')
'unknown field'
>>> 'name' in product  # is name field populated?
True
>>> 'last_updated' in product  # is last_updated populated?
False
>>> 'last_updated' in product.fields  # is last_updated a declared field?
True
>>> 'lala' in product.fields  # is lala a declared field?
False
```

### 设置字段值
```python
>>> product['last_updated'] = 'today'
>>> product['last_updated']
today

>>> product['lala'] = 'test' # setting unknown field
Traceback (most recent call last):
    ...
KeyError: 'Product does not support field: lala'
```

### 访问所有值
类似使用字典的API
```python
>>> product.keys()
['price','name']

>>> product.items()
[('price', 1000), ('name', 'Desktop PC')]
```

### 其他通用的任务
**复制items**
```python
>>> product2 = Product(product)
>>> print product2
Product(name='Desktop PC', price=1000)

>>> product3 = product2.copy()
>>> print product3
Product(name='Desktop PC', price=1000)
```

**items to dicts**
```python
>>> dict(product) # create a dict from all populated values
{'price': 1000, 'name': 'Desktop PC'}
```

**dicts to items**
```python
>>> Product({'name': 'Laptop PC', 'price': 1500})
Product(price=1500, name='Laptop PC')

>>> Product({'name': 'Laptop PC', 'lala': 1500}) # warning: unknown field in dict
Traceback (most recent call last):
    ...
KeyError: 'Product does not support field: lala'
```

## 扩展Items
可以通过继承Item来创建新的Item,以便增加字段或改变某些字段的信息。
```python
class DiscountedProduct(Product):
    discount_percent = scrapy.Field(serializer=str)
    discount_expiration_date = scrapy.Field()
```
你也可以使用前面定义的字段元数据来扩展字段元数据，添加或改变原来的值。
```python
class SpecificProduct(Product):
    name = scrapy.Field(Product.fields['name'], serializer=my_serializer)
```
此处扩展了Product的name字段的元数据，并在原来的基础上增加了serializer元数据。

## Item对象
`class scrapy.item.Item([arg])`
    从所给的参数中返回一个可选的初始化Item。
    Items复制了标准的dict API,包括它的构造函数。只是添加了`fields`属性。
    > fields    
        包含了所有声明字段的字典。字段的名称作为键，声明的`Field`对象作为值。

## Field对象
`class scrapy.item.Field([arg])`
    `Field`类只是内置dict类的一个别名，没有提供任何额外的功能或属性。换句话说Field只是普通的Python字典。一个单独用类属性来声明Item的类。

# Item Loaders
Item Loaders为构建`scraped Itmes`提供了便捷的途径。即使能够使用Item的类字典API来构建，但是Item Loaders在爬取过程中提供了许多便捷的API来构建items，通过一些自动化的通用任务，比如:在分发之前解析原始提取到的数据。

换句话说，Items为爬取到的数据提供容器，而`Item Loaders`提供便捷的途径来构造这个容器。

`Item Loaders`被设计为灵活、高效和简单的机制来扩展和覆盖不同字段的解析规则，无论是爬虫还是源格式(HTML，XML)维护起来都很方便。

## 使用Item Loaders来构建Items
使用Item Loader前需要先实例化，你可以使用类字典(Item或者dict)或Item Loader构造器使用ItemLoader.default_item_class指定的属性来自动实例化Item。

然后，开始收集数据到Item Loader，通常使用Selectors。你可以添加多个值到相同的item字段，Item Loader会用合适的方法来处理。

这里有一个经典的Item Loader使用案例，使用前面章节定义的Product Item:
```python
from scrapy.loader import ItemLoader
from myproject.items import Product

def parse(self,response):
    l = ItemLoader(item=Product(),response=response)
    l.add_xpath('name','//div[@class="product_name"]')
    l.add_xpath('name','//div[@class="product_title"]')
    l.add_xpath('price','//p[@id="price"]')
    l.add_css('stock','p#stock')
    l.add_value('last_updated','today')
    return l.load_item()
```
从上面的代码可以看到，name字段从不同的页面提取了2次：
1.`//div[@class="product_name"]`
2.`//div[@class="product_title"]`

换句话说，被指定给name字段的数据通过add_xpath()方法从2个XPath路径提取。

然后，同样的方法添加price和stock(stock使用CSS选择器add_css()方法添加)，最后用add_value直接给last_updated赋值'today'。

最后，当所有数据收集完成，`ItemLoader.load_item()`方法被调用，并返回用前面的`add_xpath()`,`add_css()`,`add_value()`提取的数据填充的item。

## 输入输出处理
每个Item Loader为每个Item 字段都有一个输入处理器和一个输出处理器。输入处理器在收到数据的时候通过`add_xpath()`,`add_css()`,`add_value()`方法尽快提取数据，输入处理器的处理结果将被收集并存储在ItemLoader中。待所有数据收集完成，`ItemLoader.load_item()`方法将被调用，构建并返回Item对象。此时，伴随着前面提取的数据输出处理器将被调用。输出处理器的结果将是Item的最终值。

下面通过一个例子来阐明输入、输出处理器针对特定字段是怎样被调用的(其他字段是同样的原理)：
```python
l = ItemLoader(Product(),some_selector)
l.add_xpath('name',xpath1) # 1
l.add_xpath('name',xpath2) # 2
l.add_css('name',css) # 3
l.add_value('name','test') # 4
return l.load_item() # 5
```

1. 数据从`xpath1`被提取，然后传递给name字段的输入处理器，
输入处理器的结果被收集并保持在Item Loader中（并没有赋值给item)。
2. 同上，数据提取后appended到1提取到的数据中。
3. 同上，提取方法改变而已，数据提取后appended到1、2提取到的数据中。
4. 同上，只是这里的value被转换为一个可迭代的元素，因为输入处理器只能接受可迭代的参数。数据提取后appended到1、2、3提取到的数据中。
5. 1/2/3/4步中提取的数据被传递给输出处理器，输出处理器的结果将被赋值给item。

值得注意的是，处理器只是可调用的对象，这些对象伴随着要解析的数据被调用，并返回一个已解析的值。因此，您可以使用任何函数作为输入或输出处理器。唯一的要求是它们必须接受一个(并且只有一个)可迭代的参数。

    注意：输入、输出处理器必须接受一个迭代器作为它的第一个参数。那些输出方法可任意，输入处理器的结果将被添加至一个内部的list(在Loader中)，包含收集到的该字段的值
    。输出处理器的值最终将被赋给item。

最后，Scrapy自带了一些通用的处理器。

## 声明Item Loaders
Item Loaders像Items一样使用类定义语法来声明。
```python
from scrapy.loader import ItemLoader
from scrapy.loader.processors import TakeFirst,MapCompose,Join

class ProductLoader(ItemLoader):
    defaule_output_processor = TakeFirst()
    name_in = MapCompose(unicode.title)
    name_out = Join()
    price_in = MapCompose(unicode.strip)
    # ...
```

如你所见，输入处理器使用`_in`后缀来声明，而输出处理器使用`_out`后缀。你也可以通过`ItemLoader.default_input_processor`和`ItemLoader.default_output_processor`定义默认的输入/输出处理器。

## 定义输入输出处理器
[官网](https://docs.scrapy.org/en/latest/topics/loaders.html#declaring-input-and-output-processors)

<span id="feed_export"></span>
# Feed exports 
> New in version 0.10.

实现爬虫最常用的一个特性，用于存储爬取到的数据，通常会使用爬取到的数据生成一个“export file”（通常叫作“export feed”）。

Scrapy通过Feed Exports提供了开箱即用的功能，允许你将scraped items生成多种序列化的feed格式，并在后端存储。

## 序列化格式
feed exports使用[`Item exporters`](#item_exporters)序列化爬取到的数据。这些格式开箱即用:

     - JSON
     - JSON lines
     - CSV
     - XML 
但是，你也可以扩展支持的格式，通过`FEED_EXPORTERS`设置。

### JSON
 - `FEED_FORMAT`:`json`
 - Exporter used:`JsonItemExporter`
 - JSON with large feeds.[warning](https://docs.scrapy.org/en/latest/topics/exporters.html#json-with-large-data)

### JSON lines
 - `FEED_FORMAT`:`jsonlines`
 - Exporter used:`JsonLinesItemExporter`

### CSV
 - `FEED_FORMAT`:`csv`
 - Exporter used:`CsvItemExporter`
 - 通过`FEED_EXPORT_FIELDS`指定导出的列和顺序。其他格式也可以使用这个选项，但是CSV不像其他格式，它使用的是固定的头部。

### XML
 - `FEED_FORMAT`:`xml`
 - Exporter used:`XmlItemExporter`

### Pickle
 - `FEED_FORMAT`:`pickle`
 - Exporter used:`PickleItemExporter`

### Marshal
 - `FEED_FORMAT`:`marshal`
 - Exporter used:`MarshalItemExporter`

## Storages
使用URI定义存储feed的位置(通过`FEED_URI`设置)。feed exports支持多种后端存储格式，通过URI方案定义。
后端开箱即用的存储格式：
- 本地文件系统
- FTP
- S3(需要botocore 或 boto)
- 标准输出

如果依赖的额外库不可用的话，有的后端存储将不可用。例如：S3后端只有当botocore和boto库都已安装才可用。(Scrapy只在Python 2上支持boto)

### Storage URI参数
存储URI还包含在创建是被替换的参数，被替换的参数如下：
- `%(time)s` 当feed被创建时用时间戳替换
- `%(name)s%`被爬虫名称替换

其他的参数将会被爬虫的同名属性替换，如`%(site_id)s`在feed被创建的时候将会被`spider.site_id`属性替换。

下面有一些例子来解释：
- 使用FTP存储，每个爬虫一个目录
  - `ftp://user:password@ftp.example.com/scraping/feeds/%(name)s/%(time)s.json`

- 使用S3存储，每个爬虫一个目录   
  - `s3://mybucket/scraping/feeds/%(name)s/%(time)s.json`

## Storage backends
### 本地文件系统
feeds存储在本地系统：
- URI scheme:文件
- URI例子：`file:///tmp/export.csv`
- 额外的库：none
注意：使用本地文件系统的时候，如果指定了绝对路径`(/tmp/export.csv)`，可以忽略`scheme`，但是仅在Unix系统上有效。

### FTP
feeds存储在FTP服务器上
- URI shceme:`ftp`
- Example URL:`ftp://user:pass@ftp.example.com/path/to/export.csv`
- 额外的库：none

### S3
feeds存储在Amazon S3上。
- URI scheme:`s3`
- Example URIs:
    - `s3://mybucket/path/to/export.csv`
    - `s3://aws_key:aws_secret@mybucket/path/to/export.csv`
- 需要额外的库：`botocore`或`boto`

AWS证书可以在URI中以`user/password`传输，或者可以通过以下设置传输：
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

### 标准输出
feeds被写进Scrapy进程的标准输出流中。
- URI scheme:`stdout`
- Example URI:`stdout:`
- 需要额外的库：none

### 设置
feed导出配置项：
- `FEED_URI`(强制的)
- `FEED_FORMAT`
- `FEED_STORAGES`
- `FEED_EXPORTERS`
- `FEED_STORE_EMPTY`
- `FEED_EXPORT_ENCODING`
- `FEED_EXPORT_FIELDS`
- `FEED_EXPORT_INDENT`

#### FEED_URI
默认：`None`
导出feed的URI，关于URI schemes的资料查看[Storage backends]()
这个设置对于导出feed是必须的。

#### FEED_FORMAT
序列化feed用的格式，查看[Serialization formats]

#### FEED_EXPORT_ENCODING
Default:`None`
被用于feed的编码

如果没有设置或设置为None，将使用UTF-8作为除了JSON格式输出的编码，JSON使用安全数字编码(\uXXXX序列)是有历史原因的。
如果你愿意，使用`utf-8`作为JSON编码格式也是可以的。

#### FEED_EXPORT_FILEDS
Default:`None`

被导出字段列表选项，例如:
`FEED_EXPORT_FIELDS=["foo","bar","baz"]`

使用`FEED_EXPORT_FIELDS`选项来定义导出的字段和顺序。

当`FEED_EXPORT_FIELDS`是空的或None时，Scrapy使用在dicts中定义的字段或Item子类。

如果导出需要一个固定字段的集合(如：CSV)，但`FEED_EXPORT_FIELDS`是空或None时，Scrapy将通过导出数据推导字段名，目前使用第一个item的字段名。

#### FEED_EXPORT_INDENT
Default:`0`
输出文件不同层级的缩进空格数量。如果`FEED_EXPORT_INDENT`是一个非负整数，然后数组元素和对象成员将按照设定的缩进进行展示。缩进级别为0或负数，将会输出每个item到新的行。
当前仅仅`JsonItemExporter`和`XmlItenExporter`可用。例如当你导出`.json`或`.xml`格式时。

#### FEED_STORE_EMPTY
Default:`False`
是否允许导出空的feeds(如：没有items的feeds)

#### FEED_STORAGES
Default:`{}`

项目提供的的额外feed存储后端支持。键为URI schemes，值为存储类的路径。

##### FEED_STORAGES_BASE
Default:
```python
{
    '':'scrapy.extensions.feedexport.FileFeedStorage',
    'file': 'scrapy.extensions.feedexport.FileFeedStorage',
    'stdout': 'scrapy.extensions.feedexport.StdoutFeedStorage',
    's3': 'scrapy.extensions.feedexport.S3FeedStorage',
    'ftp': 'scrapy.extensions.feedexport.FTPFeedStorage',
}
```
Scrapy内置的一个包含feed后端存储的字典。你可以在FEED_STORAGES中配置值为None来禁用一个选项。例如：禁用内置的FTP后端存储，不是替换，把下面的代码放入`settings.py`中：
```python
FEED_STORAGES={
    'ftp':None
}
```

#### FEED_EXPORTERS
Default:{}
项目提供的额外exporters字典。键为序列化的格式，值为Item exporter类的路径。

##### FEED_EXPORTERS_BASE
Default:
```python
{
    'json': 'scrapy.exporters.JsonItemExporter',
    'jsonlines': 'scrapy.exporters.JsonLinesItemExporter',
    'jl': 'scrapy.exporters.JsonLinesItemExporter',
    'csv': 'scrapy.exporters.CsvItemExporter',
    'xml': 'scrapy.exporters.XmlItemExporter',
    'marshal': 'scrapy.exporters.MarshalItemExporter',
    'pickle': 'scrapy.exporters.PickleItemExporter',
}
```
Scrapy提供的内置feed exporters字典。你可以在FEED_EXPORTERS中禁止某些exporters。例如：禁止内置的CSV exporter(而不是替换)，把下面的代码放入`settings.py`:
```
FEED_EXPORTERS={
    'csv':None,
}
```

<span id="item_exporters"></span>
# Item Exporters
经常需要把爬取到的数据导出，以便其他应用使用，毕竟这是爬虫的目的。

Scrapy提供了一些不同导出格式(XML,CSV or JSON)的Item Exporters。

## 使用Item Exporters
如果你很忙，只是想用Item Exporter导出爬取到的数据，那么请看[`Feed export`](#feed_export)
