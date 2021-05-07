---
title: WebSocket
tags: 
    - 网络通信
date: 2017-10-24
---

# WebSocket协议的使用方法

>引用自[阮一峰的博客](http://www.ruanyifeng.com/blog/2017/05/websocket.html)

>  http协议通信只能由客户端发起


websocket没有产生之前，客户端要实时获取服务器状态，只能采用轮询的方式。应用场景：聊天室

> websocket诞生于2008年，2011年成为国际标准

特点：服务器可以向客户端推送消息，客户端也可以向服务器推送，实现双向通信。属于服务器推送技术的一种。


## http和websocket的对比
#### 特点：  
1.建立在 TCP 协议之上，服务器端的实现比较容易。     
2.与 HTTP 协议有着良好的兼容性。默认端口也是80和443，并且握手阶段采用 HTTP协议，因此握手时不容易屏蔽，能通过各种 HTTP 代理服务器。    
3.数据格式比较轻量，性能开销小，通信高效。    
4.可以发送文本，也可以发送二进制数据。      
5.没有同源限制，客户端可以与任意服务器通信。    
6.协议标识符是ws（如果加密，则为wss），服务器网址就是 URL。   

<!-- more -->
## 客户端实现
```
var ws = new WebSocket("wss://echo.websocket.org");

ws.onopen = function(evt) { 
  console.log("Connection open ..."); 
  ws.send("Hello WebSockets!");
};

ws.onmessage = function(evt) {
  console.log( "Received Message: " + evt.data);
  ws.close();
};

ws.onclose = function(evt) {
  console.log("Connection closed.");
};  
```

### 客户端API
1、WebSocket构造函数
```
var ws =new WebSocket('ws://localhost:8080');
```
ws所有的方法和属性参见[这里](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket#Method_overview)

2、WebSocket.readyState     
共有四种：      
- CONNECTING：值为0，表示正在连接。       
- OPEN：值为1，表示连接成功，可以通信了。     
- CLOSING：值为2，表示连接正在关闭。      
- CLOSED：值为3，表示连接已经关闭，或者打开连接失败。  

```
switch (ws.readyState) {
  case WebSocket.CONNECTING:
    // do something
    break;
  case WebSocket.OPEN:
    // do something
    break;
  case WebSocket.CLOSING:
    // do something
    break;
  case WebSocket.CLOSED:
    // do something
    break;
  default:
    // this never happens
    break;
}
```

3、WebSocket监听事件
- ws.onopen()   
    指定连接成功后的回调函数
    ```
    ws.onopen = function(){
        ws.send('Hello Server!')
    }
    ```
- ws.onclose()
    指定关闭连接后的回调函数
    ```
    ws.onclose = function(evt){
        var code = event.code;
        var reason = event.reason;
        var wasClean = event.wasClean;
    }
    ```
- ws.onmessage()
    指定收到服务器数据后的回调函数
    ```
    ws.onmessage = function(event) {
        var data = event.data;
        // 处理数据,有可能收到的是二进制数据
        if(typeof data === String) {
            console.log("Received data string");
        }
    
        if(data instanceof ArrayBuffer){
            var buffer = data;
            console.log("Received arraybuffer");
        }
    };
    ```
    除了动态判断收到的数据类型，也可以使用==binaryType==属性，显式指定收到的二进制数据类型。
    ```
    // 收到的是 blob 数据
    ws.binaryType = "blob";
    ws.onmessage = function(e) {
      console.log(e.data.size);
    };
    
    // 收到的是 ArrayBuffer 数据
    ws.binaryType = "arraybuffer";
    ws.onmessage = function(e) {
      console.log(e.data.byteLength);
    };
    ```
- ws.onerror()
    实例对象的onerror属性，用于指定报错时的回调函数。
    ```
    socket.onerror = function(event) {
      // handle error event
    };
    ```

4、WebSocket的方法
- ws.send()
    实例对象的send()方法用于向服务器发送数据
    ```
    (1)发送文本
    
        ws.send('your message');
    
    (2)发送Blob对象(发送文件)
    
        var file = document
          .querySelector('input[type="file"]')
          .files[0];
        ws.send(file);
        
    (3)发送ArrayBuffer对象(发送图片等二进制)
        
        // Sending canvas ImageData as ArrayBuffer
        var img = canvas_context.getImageData(0, 0, 400, 320);
        var binary = new Uint8Array(img.data.length);
        for (var i = 0; i < img.data.length; i++) {
          binary[i] = img.data[i];
        }
        ws.send(binary.buffer);
    ```
5、WebSocket.bufferedAmount     
实例对象的bufferedAmount属性，表示还有多少字节的二进制数据没有发送出去。它可以用来判断发送是否结束。
```
var data = new ArrayBuffer(10000000);
socket.send(data);

if (socket.bufferedAmount === 0) {
  // 发送完毕
} else {
  // 发送还没结束
}
```

## 服务端实现
查看[wiki](https://en.wikipedia.org/wiki/Comparison_of_WebSocket_implementations)文档

常见Node实现的三种方案：
- [µWebSockets](https://github.com/uNetworking/uWebSockets)
- [Socket.IO](https://socket.io/)
- [WebSocket-Node](https://github.com/theturtle32/WebSocket-Node)

### Python实现
[socket握手](http://www.360doc.com/content/16/1228/09/1355383_618340627.shtml)         

```
配置：
config = {
    'HOST':'127.0.0.1',
    'PORT':8888,
    'LISTEN_CLIENT':10,
    'KEY':'391f10fadc339e9ec5fa15af60030ac1',
    'SIZE':1024,
    'GUID':'258EAFA5-E914-47DA-95CA-C5AB0DC85B11',
    'TIME_OUT':1000,
    'HANDSHAKE_STRING':"HTTP/1.1 101 Switching Protocols\r\n" \
                        "Upgrade:websocket\r\n" \
                        "Connection: Upgrade\r\n" \
                        "Sec-WebSocket-Accept: {1}\r\n" \
                        "WebSocket-Location: ws://{2}/chat\r\n" \
                        "WebSocket-Protocol:chat\r\n\r\n"
}
```

1、服务端创建和销毁socket

```
import socket
//TCP
 ws = socket.socket(AF_INET,SOCK_STREAM)
//UDP
 ws = socket.socket(AF_INET,SOCK_DGRAM)

//关闭socket
 ws.close()
 或者
 ws.shutdown(arg)
    0:阻止socket 接收数据
    1:阻止发送
    2:阻止接收和发送
```
2、绑定IP：端口
```
    //监听本地8080端口发过来的数据
    ws.bind('127.0.0.1',8080)
    //监听任何IP地址的8080端口
    ws.bind('',8080)
```
3、监听
```
    //监听数量,这个数值表示在等待队列中允许放置的进来的连接总数。当等待队列已满时，如果有更多的连接到达，那么远程端将被告知连接被拒绝
    ws.listen(5)
```
4、接收数据
```
    循环监听
    white True:
        #   接收数据，返回socket q(data) 和 地址v(ip:port)   
        client,address = ws.accept()
        
```



### Python实现客户端
```
import socket

client = socket.socket(AF_INET,SOCK_STREAM)
client.connect(('127.0.0.1',8080))

```

通信：
```
 ws.send('hello,I am Server!')
 //recv(bufsize[,flags]),
 flags:
    MSG_OOB:处理带外数据（既TCP紧急数据）。
    MSG_DONTROUTE:不使用路由表；直接发送到接口。
    MSG_PEEK:返回等待的数据且不把它们从队列中删除。
 q.recv(1024)
```




## WebSocketd
WebSocket服务器：[WebSocketd](http://websocketd.com/)
>后台脚本不限语言，标准输入（stdin）就是 WebSocket 的输入，标准输出（stdout）就是 WebSocket 的输出。

