---
layout: post
title: Hexo博客框架
date: 2018-08-15 11:30:26
tags:
	- 博客
---

# 安装Hexo
```bash
$ npm install -g hexo-cli
```

# 建站
```
$ hexo init <folder>
$ cd <folder>
$ npm install
```

# 新建文章
如果没有设置`layout`的话，默认使用`_config.yml`中的`default_layout`参数代替。如果标题包含空格，需使用引号括起来。
```
$ hexo new [layout] <title>
```

# 生成静态文件
```
$ hexo generate
参数
    -d, --deploy    文件生成后立即部署网站
    -w, --watch     监视文件变动    
```

该命令可以简写为
```
$ hexo g
```

# 发布
```
$ hexo publish [layout] <filename>
```

# 启动服务器
```
$ hexo server
默认情况下，访问网址为：`http://localhost:4000/`
参数
    -p, --port      重设端口
    -s, --static    只使用静态文件
    -l, --log       启动日记记录，使用覆盖记录格式
```

# 部署
```
$ hexo deploy
参数
    -g, --generate      部署之前预先生成静态文件
```

简写
```
$ hexo d
```

# 渲染文件
```
$ hexo render <files>[file2]...
参数
    -o,--output     设置输出路径
```

# 迁移
```
$ hexo migrate <type>
```

# 清除缓存
```
$ hexo clean
```

# 列出网站资料
```
$ hexo list <type>
```

# 显示Hexo版本
```
$ hexo version
```

# 使用主题next
```
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```