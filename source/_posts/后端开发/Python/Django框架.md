---
title: Django框架
categories: 
    - 后端开发
date: 2017-10-18 16:23
---

>Python的web框架有Django、Tornado、Flask等多种  
Django的优势：ORM、模型绑定、模版引擎、缓存、Session

## **框架知识点：**    
- [ ] 流程
- [ ] 基本配置
- [ ] 路由系统
- [ ] 视图view
- [ ] 模版
- [ ] Model模型
- [ ] 中间件
- [ ] Form
- [ ] 认证系统
- [ ] CSRF
- [ ] 分页
- [ ] Cookie
- [ ] Session
- [ ] 缓存
- [ ] 序列化
- [ ] 信号
- [ ] admin
- [ ] 事务（Transaction）
- [ ] 装饰器
- [ ] 模块
- [ ] Q

<!-- more -->
## 装饰器
- 函数装饰器
- 类装饰器

### 函数装饰器

> 装饰器本身也是一个函数，它的作用是在不改动其他函数代码的前提下为其增加额外的功能，装饰器的返回值也是一个函数。

- 带参数的装饰器
- 不带参数的装饰器

#### 不带参数的装饰器
```
def foo():
    print 'i am foo'
```
需求：要记录foo的执行日志
```
def foo():
    print 'i am foo'
    log.info('foo is running')
```
一个函数有这个需求还好办，如果有10个函数都需要记录日志，这样写不仅费事，而且很不优雅。
改进：
```
def add_logging(func):
    func()
    log.info('foo is running')

add_logging(foo)
```
这样是可以，但是改变了原来的逻辑，原先执行foo()变成了执行add_logging(foo)
为了让代码更优雅，装饰器诞生了。    
```
简单的装饰器:

def add_logging(func):
    def _func(*args,**kws):
        log.info(func.__name__ + ' is running')
        return func
    return _func

def foo():
    print 'i am foo'

foo = add_logging(foo)
foo()
```
每次都要进行foo = add_logging(foo)的赋值操作，会显得麻烦。    
装饰器的语法糖@符号，在定义函数的时候使用，避免再次赋值
```
@add_logging
def foo():
    print 'i am foo'

foo()
```

#### 带参数的装饰器
在上面的例子中，装饰器的唯一参数就是执行业务的函数。装饰器语法允许我们在调用时，提供其他参数。这样就为装饰器的编写提供了更大的灵活性。
```
def add_logging(level):
    def _func(func):
        def __func(*args,**kws):
            log.info(func.__name__ + ' is running')
            return func
        return __func
    return _func


@add_logging(level='1')
def foo():
    print 'i am foo'
```
---
## 模块
- inspect


### inspect
1. 对是否是模块，框架，函数等进行类型检查。
2. 获取源码
3. ==获取类或函数的参数的信息==
4. 解析堆栈

-------------------------
## 数据库事务[Database transactions](https://docs.djangoproject.com/en/1.11/topics/db/transactions/)

数据库事务(Database Transaction) ，是指作为单个逻辑工作单元执行的一系列操作，要么完全地执行，要么完全地不执行。 事务处理可以确保除非事务性单元内的所有操作都成功完成，否则不会永久更新面向数据的资源。通过将一组相关操作组合为一个要么全部成功要么全部失败的单元，可以简化错误恢复并使应用程序更加可靠。一个逻辑工作单元要成为事务，必须满足所谓的ACID（原子性、一致性、隔离性和持久性）属性。事务是数据库运行中的逻辑工作单位，由DBMS中的事务管理子系统负责事务的处理。

#### 举例：
设想网上购物的一次交易，其付款过程至少包括以下几步数据库操作：
一、更新客户所购商品的库存信息
二、保存客户付款信息--可能包括与银行系统的交互
三、生成订单并且保存到数据库中
四、更新用户相关信息，例如购物数量等等
正常的情况下，这些操作将顺利进行，最终交易成功，与交易相关的所有数据库信息也成功地更新。但是，如果在这一系列过程中任何一个环节出了差错，例如在更新商品库存信息时发生异常、该顾客银行帐户存款不足等，都将导致交易失败。一旦交易失败，数据库中所有信息都必须保持交易前的状态不变，比如最后一步更新用户信息时失败而导致交易失败，那么必须保证这笔失败的交易不影响数据库的状态--库存信息没有被更新、用户也没有付款，订单也没有生成。否则，数据库的信息将会一片混乱而不可预测。
数据库事务正是用来保证这种情况下交易的平稳性和可预测性的技术。

#### 使用：
```
from django.db import transaction

with transaction.atomic():
    pass

```
--------------------------------------
## django定时任务(unix环境)         
[传送门](https://pypi.python.org/pypi/django-crontab)
```
pip install django-crontab

```
settings.py配置：
INSTALLED_APPS添加
```
'django_crontab'
```
同样在settings文件中添加：
```
CRONJOBS=[
    ('*/10 * * * *','app.cron.checkOrderToCancel',[],{},'')
]   

``` 

app应用中新建文件cron.py:

```
def checkOrderToCancel():
    pass
```







