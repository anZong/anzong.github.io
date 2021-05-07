---
title: swig语法
tags: 
    - 模版
date: 2017-10-17 16:23
---
# 一、起航
## 1、API
```
swig.init({
    allowErrors: false,
    autoescape: true,
    cache: true,
    encoding: 'utf8',
    filters: {},
    root: '/',
    tags: {},
    extensions: {},
    tzOffset: 0
})
```
<!-- more -->
### **options:**
- allowErrors: 默认值为 false。将所有模板解析和编译错误直接输出到模板。如果为 true，则将引发错误，抛出到 Node.js 进程中，可能会使您的应用程序崩溃。 
- autoescape: 默认true，强烈建议保持。字符转换表请参阅转义过滤器。   
    true: HTML安全转义    
    false: 不转义，除非使用转义过滤器或者转义标签   
    'js': js安全转义
- cache: 更改为 false 将重新编译每个请求的模板的文件。正式环境建议保持true。
- encoding: 模板文件编码
- root: 需要搜索模板的目录。如果模板传递给 swig.compileFile 绝对路径(以/开头)，Swig不会在模板root中搜索。如果传递一个数组，使用第一个匹配成功的数组项。
- tzOffset: 设置默认时区偏移量。此设置会使转换日期过滤器会自动的修正相应时区偏移量。
- filters:自定义过滤器或者重写默认过滤器，参见自定义过滤器指南。
tags: 自定义标签或者重写默认标签，参见自定义标签指南。
extensions: 添加第三方库，可以在编译模板时使用，参见参见自定义标签指南。

## 2、node.js

```
var tpl = swig.compileFile("path/to/template/file.html");
var renderedHtml = tpl.render({ vars: 'to be inserted in template' });
或者

var tpl = swig.compile("Template string here");
var renderedHtml = tpl({ vars: 'to be inserted in template' });
```

## 3、结合Express
```
npm install express
npm install consolidate

然后

app.engine('.html',cons.swig);
app.set('view engine',html);

```

## 4、浏览器
Swig浏览器版本的api基本与nodejs版相同，不同点如下：

- 不能使用swig.compileFile，浏览器没有文件系统    
- 你必须提前使用swig.compile编译好模板    
- 按顺序使用extends, import, and include，同时在swig.compile里使用参数templateKey来查找模板  
```
var template = swig.compile('<p>{% block content %}{% endblock %}</p>', { filename: 'main' });
var mypage = swig.compile('{% extends "main" %}{% block content %}Oh hey there!{% endblock %}', { filename: 'mypage' });
```


---

# 二、基础
## 1、变量
```
{{foo.bar}}或{{foo['bar']}}
```
如果变量未定义，输出空字符串
变量可以通过过滤器来修改：
```
{{ name|title }} was born on {{ birthday|date('F jS, Y') }}
// Jane was born on July 6th, 1985
```

## 2、逻辑标签
## 3、注释
## 4、空白
模板里的空白在最终输出时默认保留，如果需要去掉空白，可以在逻辑标签前后加上空白控制符'—'：
```
{% for item in seq -%}
    {{item}}
{%- endfor%}
```

---
# 三、模板继承
Swig使用extends和block来实现模板继承
```
<!--layout.html-->
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>{% block title %}My Site{% endblock %}</title>
    {% block head%}
        <link rel="stylesheet" href="main.css">
    {% endblock %}
</head>
<body>
    {% block content%}{%endblock%}
</body>
</html>


<!--index.html-->
{%extends 'layout.html'%}
{%block title%}My Page{%endblock%}
{%block head%}
    {%parent%}
    <link rel="stylesheet" href="custom.css">
{%endblock%}
{%block content%}
    <p>This is just a simple page.</p>
{%endblock%}
```
---
# 四、变量过滤器
用于修改变量。变量名称后用“|”字符分隔添加过滤器。也可以添加多个过滤器。
## 1、例子
```
{{ name|title }} was born on {{birthday|date('F jS,Y')}}
and has {{ bikes|length|default("zero")}} bikes.
```
也可以使用==filter标签==来为块内容添加过滤器
```
{% filter upper %}oh hi,swig!{% endfilter %}
```

## 2、内置过滤器
 - add(value):使变量与value相加，数值字符串会自动转换为数值
 - addslashes:用\转义字符串
 - caplitalize:大写首字母
 - data(format[,tzOffset]):转换日期为指定格式
 - format:格式
 - tzOffset:时区
 - default(value):默认值
 - escape([type]):转义字符
    - 默认: &,<,>,",'
    - js：&,<,>,",',=,-,;
 - first: 返回数组第一个值
 - join(glue):同[].join
 - json_encode([indent]):类似JSON.stringfy,indent为缩进空格数
 - last:返回数组最后一个值
 - length:返回变量的length,如果是object，返回key的数量
 - lower:同''.toLowerCase()
 - raw:指定输入不会被转义
 - replace(search,replace[,flags]):同''.replace
 - reverse:翻转数组
 - striptags:去除html/xml标签
 - title:大写首字母
 - uniq:数组去重
 - upper:同''.toUpperCase
 - url_encode:同encodeURIComponent
 - url_decode:同decodeURIComponent

## 3、自定义过滤器
创建一个myfilter.js然后引入到Swig的初始化函数中
```
swig.init({filters:require('myfilter')});
```
在myfilter.js里，每一个filter方法都是一个简单的js方法，下例是一个翻转字符串的filter:
```
exports.myfilter = function(input){
    return input.toString().split('').reverse().join('');
}

exports.prefix = function(input,prefix){
    return prefix.toString() + input.toString();
}
```
使用：
```
{{ name|myfilter }}
或者
{% filter myfilter %}
    I shall be filtered
{% endfilter %}
```

过滤器传参：
```
<!--字符串-->
{{ name|prefix('hello ') }}
或者
{%filter prefix 'hello '%} yang {% endfilter %}

<!--变量-->
{% filter prefix foo %}I will be prefixed with the value stored to `foo`.{% endfilter %}
```
## 4、标签
- extends: 使当前模板继承父模板，必须在文件最前面
    - 参数file:父模板相对模板root的相对路径
- block:定义一个块，使之可以被继承的模板重写，或者重写父模板的同名块
    - 参数name:定义一个块，使之可以被继承的模板重写，或者重写父模板的同名块
- parent:将父模块中同名块注入当前块中
- include:包含一个模板到当前位置，这个模板将使用当前上下文
    - 参数file:包含模板相对模板root的相对路径
    - 参数ignore missing:包含模板不存在也不会报错
    - 参数with x:设置x至根上下文对象以传递给模板生成。必须是一个键值对
    - 参数only:限制模板上下文中用with x定义的参数

> 本地申明的上下文变量，默认情况下不会传递给包含的模板。

```
        {% set foo = "bar" %}
        {% include "inc.html" %}
        {% for bar in thing %}
            {% include "inc.html" %}
        {% endfor %}
```
    错误:inc.html无法得到foo和bar
    
>   如果想把本地申明的变量引入到包含的模板中，可以使用with参数来把后面的对象创建到包含模板的上下文中

```
    {% set foo = { bar: "baz" } %}
    {% include "inc.html" with foo %}
    {% for bar in thing %}
        {% include "inc.html" with bar %}
    {% endfor %}
```
>   如果当前上下文中foo和bar可用，下面的情况，只有foo会被inc.html定义

```
    {% include "inc.html" with foo only %}
```
    only 必须作为最后一个参数，放在其他位置会被忽略。

- raw：停止解析标记中的任何内容，所有内容将原样输出
    - file:父模板相对模板 root 的相对路径
- for:遍历对象和数组
    - x:当前循环迭代名
    - in:语法标记
    - y:可迭代对象。可以使用过滤器修改

    ```
        {% for x in y %}    
            {% if loop.first %}<ul>{% endif %}    
                <li>{{ loop.index }} - {{ loop.key }}: {{ x }}</li>     
            {% if loop.last %}</ul>{% endif %}  
        {% endfor %}
    ```

>  loop.index：当前循环的索引（1开始） 
    loop.index0：当前循环的索引（0开始）    
    loop.revindex：当前循环从结尾开始的索引（1开始）    
    loop.revindex0：当前循环从结尾开始的索引（0开始）   
    loop.key：如果迭代是对象，是当前循环的键，否则同 loop.index 
    loop.first：如果是第一个值返回 true
    loop.last：如果是最后一个值返回 true
    loop.cycle：一个帮助函数，以指定的参数作为周期
    ```
        loop.cycle()     循环设置奇偶行的样式
        {% for item in items %}
            <li class="{{ loop.cycle('odd', 'even') }}">{{ item }}</li>
        {% endfor %}
    ```

> 在for标签里使用else，当people为undefined或null时执行else

```
    {% for person in people %}
        {{ person }}
    {% else %}
        There are no people yet!
    {% endfor %}
```

- if：条件语句
    - 参数:接受任何有效的javasript条件语句

    ```     
        {% if x %}{% endif %}
        {% if !x %}{% endif %}
        {% if not x %}{% endif %}
        {% if x and y %}{% endif %}
        {% if x && y %}{% endif %}
        {% if x && y %}{% endif %}
        {% if x or y %}{% endif %}
        {% if x || y %}{% endif %}
        {% if x || (y && z) %}{% endif %}
        {% if x [operator] y %}
            Operators: ==, !=, <, <= , >, >=, ===, !==
        {% endif %}
        {% if x == 'five' %}
            The operands can be also be string or number literals
        {% endif %}
        {% if x|length === 3 %}
            You can use filters on any operand in the statement.
        {% endif %}
        {% if x in y %}
            If x is a value that is present in y, this will return true.
        {% endif %}
    ```
    else和else if
    ```

        {% if foo %}
            Some content.
        {% else if "foo" in bar %}
            Content if the array `bar` has "foo" in it.
        {% else %}
            Fallback content.
        {% endif %}
    ```
- autoescape：改变当前变量的自动转义行为
    - on：当前内容是否转义Boolean
    - type：转义类型，js或者html，默认html

假设
```
    some_html_output = '<p>Hello "you" & \'them\'</p>';
```
然后
```
    {% autoescape false %}
        {{ some_html_output }}
    {% endautoescape %}
    {% autoescape true %}
        {{ some_html_output }}
    {% endautoescape %}
    {% autoescape true "js" %}
        {{ some_html_output }}
    {% endautoescape %}
```
输出
```
    <p>Hello "you" & 'them'</p>
     &lt;p&gt;Hello &quot;you&quot; &amp; &#39;them&#39; &lt;/p&gt;
     \u003Cp\u003EHello \u0022you\u0022 & \u0027them\u0027\u003C\u005Cp\u003E
```
- set：设置一个变量,在当前上下文中复用
    - name:变量名
    - =语法标记
    - value:变量值

```
    {% set foo = [0, 1, 2, 3, 4, 5] %} {% for num in foo %}
        <li>{{ num }}</li>
    {% endfor %}
```
- macro:创建自定义可复用的代码段
    - 参数...:用户自定义

```
    {% macro input type name id label value error %}
     <label for="{{ name }}">{{ label }}</label>
     <input type="{{ type }}" name="{{ name }}" id="{{ id }}" value="{{ value }}"{% if error %} class="error"{% endif %}>
    {% endmacro %}
```
使用:
```
    <div>
        {{ input("text", "fname", "fname", "First Name", fname.value, fname.errors) }}
    </div>
    <div>
        {{ input("text", "lname", "lname", "Last Name", lname.value, lname.errors) }}
    </div>
```
输出:
```
    <div>
        <label for="fname">First Name</label>
        <input type="text" name="fname" id="fname" value="Paul">
    </div>
    <div>
        <label for="lname">Last Name</label>
        <input type="text" name="lname" id="lname" value="" class="error">
    </div>
```
- import：允许引入另一个模板的宏进入当前上下文  
    - file:引入模板相对模板root的相对路径
    - as:语法标记
    - var:分配给宏的可访问上下文对象

```
    {% import 'formmacros.html' as form %}  
    {# this will run the input macro #}
    {{ form.input("text", "name") }}
    {# this, however, will NOT output anything because the macro is scoped to the "form"     object: #}
    {{ input("text", "name") }}
```
- filter:对整个块应用过滤器
    - filter_name:过滤器名字
    - ...:若干传给过滤器的参数

>   使用

```
    {% filter uppercase %}
        oh hi, {{ name }}
    {% endfilter %}
    {% filter replace "." "!" "g" %}
        Hi. My name is Paul.
    {% endfilter %}
```

>   输出

    OH HI, PAUL Hi! My name is Paul!

- spaceless:尝试移出html标签间的空格

> 使用

```
    {% spaceless %}
    {% for num in foo %}
        <li>{{ loop.index }}</li>
    {% endfor %}
    {% endspaceless %}
```

>   输出

    <li>1</li><li>2</li><li>3</li>
