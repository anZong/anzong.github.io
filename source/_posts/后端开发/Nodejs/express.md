---
title: Express
categories: 
    -  后端开发
date: 2018-08-20
---

# 安装 Express
```javascript
cnpm install express --save
```

需要和express框架一起安装的模块：

- body-parser
node.js中间件，用于处理json,raw,text和url编码的数据。
四种不同的处理方法：
`bodyParser.json(options)`          处理json数据
`bodyParser.raw(options)`           Buffer流数据
`bodyParser.text(options)`          文本数据
`bodyParser.urlencoded(options)`    UTF-8的编码数据

三种用法：
1.  底层中间件用法：这将拦截和解析所有的请求；即全局的。
```javascript
var express = require('express')
var bodyParser = require('body-parser')

var app = express()

app.use(bodyParser.urlencoded({extended:false}))
app.use(bodyParser.json())
//全局拦截
app.use((req,res)=>{
    res.setHeader('Content-Type','text/plain')
    res.write('you posted:\n')
    res.end(JSON.stringify(req.body,null,2))
})
```
2.  特定路由下的中间件用法：对特定路由下的特定请求，只有请求该路由时，中间件才会拦截和解析该请求，即局部的，也是最常用的一个方式。
```javascript
var express = require('express')
var bodyParser = require('body-parser')

var app = express()
// create application/json parser
var jsonParser = bodyParser.json()
// create application/x-www-form-urlencoded parser
var urlencodedParser = bodyParser.urlencoded({ extended: false })
// POST /login gets urlencoded bodies
app.post('/login', urlencodedParser, function (req, res) {
 if (!req.body) return res.sendStatus(400)
 res.send('welcome, ' + req.body.username)
})
// POST /api/users gets JSON bodies
app.post('/api/users', jsonParser, function (req, res) {
 if (!req.body) return res.sendStatus(400)
 // create user in req.body
})
```
3.  设置Content-Type 属性；用于修改和设定中间件解析的body类容类型。
```javascript
// parse various different custom JSON types as JSON
app.use(bodyParser.json({ type: 'application/*+json' });
 
// parse some custom thing into a Buffer
app.use(bodyParser.raw({ type: 'application/vnd.custom-type' }));
 
// parse an HTML body into a string
app.use(bodyParser.text({ type: 'text/html' }));
```

- cookie-parser
这就是一个解析Cookie的工具。通过req.cookies可以取到传过来的cookie，并把它们转成对象
- multer
express官方推荐的文件上传中间件


```javascript
cnpm install body-parser cookie-parser multer --save
```
