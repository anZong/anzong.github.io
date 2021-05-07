---
layout: post
title: Node.js
date: 2018-08-15 13:35:44
tags:
    - javascript
---

# 交互式解释器
下划线变量（_）,可以使用下划线获取上一个表达式的运算结果
```javascript
> var x = 10
> var y = 20
>  x + y
>  var sum = _
>  console.log(sum)
30_
```

## REPL命令
```bash
ctrl+c              //退出当前终端
ctrl+c              //退出Node REPL 按下两次 
ctrl+d              //退出Node REPL
.help               //列出使用命令
.break              //退出多行表达式
.clear              //退出多行表达式
.save <filename>      //保存当前的Node REPL会话到指定文件
.load <filename>      //载入当前的Node REPL会话的文件内容
```
----------------------
# 回调函数
Node.js异步编程的直接体现就是回调。
回调函数接收错误对象作为第一个参数。
```
$ touch input.txt
$ nano input.txt
hello nodejs
```
## 阻塞代码实例
```javascript
var fs = require('fs');
var data = fs.readFileSync('input.txt');
console.log(data.toString());
console.log('程序执行结束');
```
输出
```
hello nodejs
程序执行结束
```
程序顺序执行，读取文件阻塞

## 非阻塞代码实例
```javascript
var fs = require('fs');
fs.readFile('input.txt',function(err,data){
    if(err)return console.log(err);
    console.log(data.toString());
});
console.log('程序执行结束');
```
输出
```
程序执行结束
hello nodejs
```
程序异步执行，文件读取完成后调用回调函数；后面的程序不会被阻塞。

-----------------------

# 事件
```javascript
//引入events模块
var events = require('events');
//创建eventEmitter对象
var eventEmitter = new events.EventEmitter();

//创建连接事件处理程序
var connectHandler = function connected(){
    console.log('连接成功.');
    //触发接收数据事件
    eventEmitter.emit('data_received');
}
//绑定connection事件处理程序
eventEmitter.on('connection',connectHandler);

//绑定接收数据事件
eventEmitter.on('data_received',function(){
    console.log('数据接收成功.')
})

//触发连接事件
eventEmitter.emit('connection');

console.log('程序执行完毕.');
```
## EventEmitter类
### 实例方法
#### addListener(event,listener)
为指定事件添加一个监听器到监听器数组的尾部
#### on(event,listener)
为指定事件注册一个监听器，接收一个字符串event和一个回调函数。
#### once(event,listener)
为指定事件注册一个单次监听器，即监听器最多只会触发一次，触发后立刻解除该监听器。
#### removeListener(event,listener)
移除指定事件的某个监听器，监听器必须是该事件已经注册过的监听器。
#### removeAllListeners([event])
移除所有事件的监听器，如果指定事件，则移除指定事件的所有监听器。
#### setMaxListeners(n)
设置事件默认（10）允许的最大监听器数量。
#### listeners(event)
返回指定事件的监听器数组。
#### emit(event,[arg1],[arg2],[...])
按照参数的顺序执行每个监听器，如果事件又注册监听器返回true，否则返回false。

### 类方法
#### listenerCount(emitter,event)
返回指定事件的监听器数量。

### 实例事件
#### newListener
该事件在添加新监听器时被触发
- event      字符串，事件名称
- listener   处理事件函数
 
#### removeListener
从指定监听器数组中删除一个监听器，此操作将会改变处于被删监听器后的那些监听器的索引。
- event     字符串，事件名称
- listener  处理事件函数


### error事件
EventEmitter类定义了一个特殊的事件error，包含了错误的语意。
当error被触发时，如果没有响应的监听器，Node.js会把它当作异常，退出程序并输出错误信息。
一般情况下需要为会触发error 事件的对象设置监听器，避免遇到错误后整个程序崩溃。
```javascript
var events = require('events');
var emitter = new events.EventEmitter();
emitter.emit('error');
```

###  继承EventEmitter
大多数时候我们不会直接使用 EventEmitter，而是在对象中继承它。包括 fs、net、 http 在内的，只要是支持事件响应的核心模块都是 EventEmitter 的子类。
为什么要这样做呢？原因有两点：
- 具有某个实体功能的对象实现事件符合语义， 事件的监听和发生应该是一个对象的方法。
- JavaScript 的对象机制是基于原型的，支持 部分多重继承，继承 EventEmitter 不会打乱对象原有的继承关系。
-----------------------
# Node.js Buffer（缓冲区）
> 在v6.0之前创建Buffer对象直接使用new Buffer()构造函数来创建对象实例，但是Buffer对内存的权限操作相比很大，可以直接捕获一些敏感信息，所以在v6.0以后，官方文档里面建议使用 Buffer.from() 接口去创建Buffer对象。

## 创建Buffer类
Buffer 提供了以下 API 来创建 Buffer 类：
  -  Buffer.alloc(size[, fill[, encoding]])： 返回一个指定大小的 Buffer 实例，如果没有设置 fill，则默认填满 0
  -  Buffer.allocUnsafe(size)： 返回一个指定大小的 Buffer 实例，但是它不会被初始化，所以它可能包含敏感的数据
  -  Buffer.allocUnsafeSlow(size)
  -  Buffer.from(array)： 返回一个被 array 的值初始化的新的 Buffer 实例（传入的 array 的元素只能是数字，不然就会自动被 0 覆盖）
  -  Buffer.from(arrayBuffer[, byteOffset[, length]])： 返回一个新建的与给定的 ArrayBuffer 共享同一内存的 Buffer。
  -  Buffer.from(buffer)： 复制传入的 Buffer 实例的数据，并返回一个新的 Buffer 实例
  -  Buffer.from(string[, encoding])： 返回一个被 string 的值初始化的新的 Buffer 实例

## 写入缓冲区
```
buf.write(string[,offset[,length]][,encoding])
返回值：返回实际写入的大小，如果buffer空间不足，则只会写入部分字符。
```

## 从缓冲区读取数据
```
buf.toString([encoding[,start[,end]]])
```
返回值：解码缓冲区数据并使用指定的编码返回字符串。

## 将Buffer转换为JSON对象
```
buf.toJSON()
```
返回值：返回JSON对象

## 缓冲区合并
```
Buffer.concat(list[,totalLength])
参数：
    - list 用户合并的Buffer对象数组列表
    - totalLength 指定合并后Buffer对象的总长度 
```

## 缓冲区比较
```
buf.compare(otherBuffer);
```

## 拷贝缓冲区
```
buf.copy(targetBuffer[,targetStart[,sourceStart[,sourceEnd]]])
参数：
  - targetBuffer - 要拷贝的 Buffer 对象。
  - targetStart - 数字, 可选, 默认: 0
  - sourceStart - 数字, 可选, 默认: 0
  - sourceEnd - 数字, 可选, 默认: buffer.length
```

## 缓冲区裁剪
```
buf.slice([start[,end])
```

## 缓冲区长度
```
buf.length;
```
-----------------------

# Node.js Stream 流
## Stream
四种流类型：
- Readable - 可读操作。
- Writable - 可写操作。
- Duplex - 可读可写操作.
- Transform - 操作被写入数据，然后读出结果。

所有的Stream对象都是EventEmitter的实例。常用的事件有：
- data - 当有数据可读时触发。
- end - 没有更多的数据可读时触发。
- error - 在接收和写入过程中发生错误时触发。
- finish - 所有数据已被写入到底层系统时触发。

### 从流中读取数据
```javascript
var fs = require('fs');
var data = '';
var readerStream = fs.createReadStream('input.txt');
readerStream.setEncoding('UTF8');
readerStream.on('data',function(chunk){
        data+=chunk;
})
readerStream.on('end',function(){
        console.log(data);
})
readerStream.on('error',function(err){
        console.log(err.stack);
})
console.log('programing is end.');
```
### 写入流
```javascript
var fs = require('fs');
var data = 'hello nodejs,i am stream.';
var writeStream = fs.createWriteStream('output.txt');
writeStream.write(data,'UTF8');
writeStream.end();
writeStream.on('finish',()=>{
        console.log('write finished.');
})
writeStream.on('error',(err)=>{
        console.log(err.stack);
})
console.log('programing end.');
```

## 管道(pipe)
实现大文件的复制。
```javascript
var fs = require('fs');
var readerStream = fs.createReadStream('input.txt');
var writeStream = fs.createWriteStream('output.txt');
//管道操作
readerStream.pipe(writeStream);
console.log('program end.');
```
## 链式流
链式是通过连接输出流到另外一个流并创建多个流操作链的机制。链式流一般用于管道操作。
接下来我们就是用管道和链式来压缩和解压文件。
压缩文件
```javascript
var fs = require('fs');
var zlib = require('zlib');
var readerStream = fs.createReadStream('input.txt');
var writeStream = fs.createWriteStream('input.txt.gz');
readerStream.pipe(zlib.createGzip()).pipe(writeStream);
console.log('program end.');
```
解压文件
```javascript
var fs = require('fs');
var zlib = require('zlib');
var readerStream = fs.createReadStream('input.txt.gz');
var writeStream = fs.createWriteStream('input1.txt');
readerStream.pipe(zlib.createGunzip()).pipe(writeStream);
console.log('program end.');
```

-----------------------
# Node.js 路由
`server.js`
```javascript
var http = require('http');
var url = require('url');
const PORT = 3000;
var start = function(route){
  var onRequest = function(request,response){
  var pathname = url.parse(request.url).pathname;
    route(pathname);
  }
  http.createServer(onRequest).listen(PORT);
  console.log(`Server start http://localhost:${PORT}`);
}
exports.start = start;
```
`router.js`
```javascript
var route = function(pathname){
  console.log(pathname);
}
exports.route = route;
```
`index.js`
```javascript
var server = require('./server');
var router = require('./router');
server.start(router.route);
```
-----------------------
# Node.js Express 框架
-----------------------

# 模块系统
## 模块系统的加载优先级
![模块系统的加载优先级](https://www.runoob.com/wp-content/uploads/2014/03/nodejs-require.jpg)
## http模块
### 安装
```javascript
$ npm install http
```
### 使用
```javascript
// 引入required模块
var http = require("http");
//创建服务器，接收请求与响应请求
http.createServer(function(request,response){
    //发送HTTP头部
    //HTTP状态值：200   ：OK
    //内容类型：text/plain
    response.writeHead(200,{'Content-Type':'text/plain'});

    //发送响应数据
    response.end('Hello World\n');
}).listen(8888)
```

## web框架模块express    
### 安装
```bash
$ npm install express       //全局安装
//  安装失败
npm err! Error: connect ECONNREFUSED 127.0.0.1:8087
//  解决办法
$ npm config set proxy null
//  卸载模块
$ npm uninstall express
//  更新模块
$ npm update express
//  搜索模块
$ npm search express
```

### 使用
```javascript
var express = require('express');
```
-----------------------
