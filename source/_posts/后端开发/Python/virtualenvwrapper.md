---
title: virtualenvwrapper
date: 2018-08-22 22:10:00
tags:
    - 工具
---

1.  安装virtualenv
```
sudo pip install virtualenv
```
2.  安装virtualenvwrapper
```
sudo pip install virtualenvwrapper
```
3.  编译virtualenvwrapper.sh
```
source /usr/local/bin/virtualenvwrapper.sh
```
4. 设置WORKON_HOME，每次启动shell都生效
```
nano ~/.bashrc

export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

source ~/.bashrc
```
5. 创建虚拟环境
```
mkvirtualenv py2env
```
6. 进入虚拟环境
```
workon py2env
```
7. 退出虚拟环境
```
deactivate
```
