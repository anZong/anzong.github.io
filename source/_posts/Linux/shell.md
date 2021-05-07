---
title: Shell
tags: 
    - 工具
date: 2018-08-20
---
[基础知识](http://www.runoob.com/linux/linux-shell.html)

# shell标识
`#!/bin/bash`
`#!`告诉系统用后面指定路径中的程序来解释此脚本文件

# 运行方法
1. 作为可执行程序
```shell
chmod +x ./test.sh
./test.sh
```
2. 作为解释器参数
```shell
bash test.sh
```

# 变量
## 只读变量,不可修改
```shell
url='http://www.baidu.com'
readonly url
```
## 删除变量
```shell
unset variable_name
```
## 字符串
```shell
name="zong"
echo "name:${name}"
echo "len:${#name}"
echo "substr:${name:1:3}"
```

## 注释
```shell
:<<EOF
注释内容...
EOF
```

# 传递参数
```shell
#!/bin/bash
echo 'shell 传递参数实例：'
echo "执行文件名:$0"
echo "第一个参数:$1" 
echo "第一个参数:$2"  
echo "第一个参数:$3" 
echo "共$#个参数"
echo "所有参数:$*"
echo "所有参数:$@"
echo "脚本运行的当前进程ID:$$"
echo "后台运行的最后一个进程的ID号:$!"
echo "显示shell使用的当前选项:$-"
echo "最后命令的退出状态码:$?"

echo '$*和$@的区别:'
echo '$*:'
for i in "$*";
do
    echo ${i}
done

echo '$@:'
for i in "$@";
do 
    echo ${i}
done
```

# 数组
```shell
array=(val1 val2 val3 ...)
```
单独定义数组的各个分量：
```shell
array[2]=val2
```
读取数组
```shell
${array[1]}
```
获取数组长度
```shell
${#array[*]} 
or
${#array[@]}
```

# 基本运算符
`expr`和`awk`
```shell
#!/bin/bash

# 算术运算符
val=`expr 2 + 2`
echo $val
a=10
b=20
echo "a:$a"
echo "b:$b"
val=`expr $a + $b`
echo "a + b = $val"
val=`expr $a - $b`
echo "a - b = $val"
val=`expr $a \* $b` # 乘法，*号前必须加斜杠
echo "a * b = $val"
val=`expr $b / $a`
echo "b / a = $val"
val=`expr $a % $b`
echo "a % b = $val"

if [ $a == $b ]
then
    echo 'a == b'
fi

if [ $a != $b ]
then
    echo 'a != b'
fi

# linux中的表达式： `expr 表达式`
# mac中的表达式：$((表达式))
echo $(($a + $b))

# 关系运算符
if [ $a -eq $b ]
then
    echo 'a==b'
fi

if [ $a -ne $b ]
then
    echo 'a!=b'
fi

if [ $a -gt $b ]
then
    echo 'a>b'
fi

if [ $a -lt $b ]
then
    echo 'a<b'
fi

if [ $a -ge $b ]
then
    echo 'a>=b'
fi

if [ $a -le $b ]
then
    echo 'a<=b'
fi

:<<EOF
 布尔运算符
 !  非运算 [ !false ]  true
 -o 或运算 [ $a -lt 20 -o $b -gt 100 ] true
 -a 与运算 [ $a -lt 20 -a $b -gt 100 ] false
EOF

:<<EOF
逻辑运算符
&&  [[ $a -lt 100 && $b -gt 100 ]]
||  [[ $a -lt 100 || $b -gt 100 ]]
EOF

# 字符串运算符
:<<EOF
a='abc'
b='efg'

'a=b:' [ $a = $b ]
'a!=b:' [ $a != $b ]
'检测字符串长度是否为0:' [ -z $a ]
'检测字符串长度是否不为0:' [ -n $a ]
'检测字符串是否为空:' [ $a ]

# 文件测试运算符
'块设备:' [ -b $file ]
'字符设备:' [ -c $file ]
'目录:' [-d $file]
'普通文件:' [ -f $file ]
'是否是有名管道:' [ -p $file ]
'读:' [ -r $file ]
'写:' [ -w $file ]
'执行:' [ -x $file ]
'文件是否为空:' [ -s $file ]
'检测文件（目录）是否存在：'  [ -e $file ]
EOF
```
# printf命令
```shell
printf '语法：printf format-string [args...]\n'

format_str="%-10s %-8s %-4s\n"
format_num="%-10s %-8s %-4.2f\n"
printf "$format_str" 姓名 性别 体重Kg
printf "$format_num" 郭靖 男 66.1234
printf "$format_num" 黄蓉 女 32.1234
printf "$format_num" 杨过 男 65.1234
printf "$format_num" 小龙女 女 35.1234
```
# 流程控制
```shell
#!/bin/bash

#if else
a=10
if [ $a == 10 ]
then
    echo $a
else
    echo 'no $a'
fi

# for循环
for loop in 1 2 3 4 5
do
    echo $loop
done

# while循环
i=0
while((i<10)); do
    let "i++"
    echo ${i}
done

# 无限循环
:<<EOF
while true; do
    echo 'loop'
done

或者

for ((;;))
EOF

# util语句
j=0
until ((j>10)); do
    let "j++"
    echo ${j}
done

# case语句
echo '输入1到4之间的数字：'
echo '你输入的数字为：'
read num
case $num in 
    1) echo '你选择了1';;
    2) echo '你选择了2';;
    3) echo '你选择了3';;
    4) echo '你选择了4';;
esac

# 跳出循环
# break语句
while true; do
    echo -n '输入1-5之间的数字'
    read num
    case $num in
        1|2|3|4|5) echo "你输入了$num";;
        *) 
            echo '你输入的不是1-5之间的数字，程序退出'
            break
        ;;
    esac
done

#continue语句
while true; do
    echo -n '输入1-5之间的数字'
    read num
    case $num in
        1|2|3|4|5) echo "你输入了$num";;
        0)
            echo '程序结束'
            break
        ;;
        *) 
            echo '你输入的不是1-5之间的数字，程序退出'
            continue
        ;;
    esac
done
```
# 函数
```shell
#!/bin/bash

console(){
    echo 'console sth.'
    echo "参数:$1"
}

echo '输出函数：'
console
console zong

add(){
    echo '输入两个数进行加运算'
    echo '请输入第一个数:'
    read num1
    echo '请输入第二个数:'
    read num2
    return $(($num1+$num2))
}
add
echo "输入的两个数之和为：$?"
```

# 文件包含
```shell
. filename  # 注意点号(.)和文件名中间有一个空格
or 
source filename
```

