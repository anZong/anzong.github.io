---
title: webpack
tags: 
    - 工具
categories: 
    - 前端开发
date: 2017-11-04
---
# 入口(Entry)   
入口起点告诉webpack从哪里开始
```js
//webpack.config.js
module.exports = {
    entry:'./path/to/my/entry/file.js'
}

```

# 出口(Output)  
将所有资源assets归拢在一起后，还需要告诉 webpack 在哪里打包应用程序。webpack 的 output 属性描述了如何处理归拢在一起的代码(bundled code)。
```js
//webpack.config.js
const path = require('path');

module.exports = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  }
};
```
<!-- more -->
在上面的例子中，我们通过 output.filename 和 output.path 属性，来告诉 webpack bundle 的名称，以及我们想要生成(emit)到哪里。
# loader    
webpack 的目标是，让 webpack 聚焦于项目中的所有资源(asset)，而浏览器不需要关注考虑这些（明确的说，这并不意味着所有资源(asset)都必须打包在一起）。webpack 把每个文件(.css, .html, .scss, .jpg, etc.) 都作为模块处理。然而 webpack 自身只理解 JavaScript。

webpack loader 在文件被添加到依赖图中时，其转换为模块。

在更高层面，在 webpack 的配置中 loader 有两个目标。

识别出(identify)应该被对应的 loader 进行转换(transform)的那些文件。(test 属性)
转换这些文件，从而使其能够被添加到依赖图中（并且最终添加到 bundle 中）(use 属性)
```js
//webpack.config.js
const path = require('path');

const config = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  },
  module: {
    rules: [
      { test: /\.txt$/, use: 'raw-loader' }
    ]
  }
};

module.exports = config;
```
以上配置中，对一个单独的 module 对象定义了 rules 属性，里面包含两个必须属性：test 和 use。这告诉 webpack 编译器(compiler) 如下信息：

> “嘿，webpack 编译器，当你碰到在 require()/import 语句中被解析为 '.txt' 的路径时，在你对它打包之前，先使用 raw-loader 转换一下。”

重要的是要记得，在 webpack 配置中定义 loader 时，要定义在 module.rules 中，而不是 rules。然而，在定义错误时 webpack 会给出严重的警告。
# 插件(plugins)
然而由于 loader 仅在每个文件的基础上执行转换，而 插件(plugins) 更常用于（但不限于）在打包模块的 “compilation” 和 “chunk” 生命周期执行操作和自定义功能（查看更多）。webpack 的插件系统极其强大和可定制化。

想要使用一个插件，你只需要 require() 它，然后把它添加到 plugins 数组中。多数插件可以通过选项(option)自定义。你也可以在一个配置文件中因为不同目的而多次使用同一个插件，这时需要通过使用 new 来创建它的一个实例。
```js
//webpack.config.js
const HtmlWebpackPlugin = require('html-webpack-plugin'); //installed via npm
const webpack = require('webpack'); //to access built-in plugins
const path = require('path');

const config = {
  entry: './path/to/my/entry/file.js',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'my-first-webpack.bundle.js'
  },
  module: {
    rules: [
      { test: /\.txt$/, use: 'raw-loader' }
    ]
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin(),
    new HtmlWebpackPlugin({template: './src/index.html'})
  ]
};

module.exports = config;

```

更多详细内容查看[官网](https://doc.webpack-china.org)


### 插件
```
html-webpack-plugin: index.html自动插入js
clean-webpack-plugin: 清理文件夹
WebpackManifestPlugin: 文件映射提取到json
```

### 开发
开发工具：  
inline-source-map （不能用于生产环境）    
webpack-dev-server（开启开发服务器，如果现在修改和保存任意源文件，web服务器就会自动重新加载编译后的代码。)     
webpack-dev-middleware
