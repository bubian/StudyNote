#!/bin/bash

demoFun(){
    echo "这是我的第一个 shell 函数!"
}
echo "-----函数开始执行-----"
demoFun
echo "-----函数执行完毕-----"


funWithReturn(){
    echo "这个函数会对输入的两个数字进行相加运算..."
    echo "输入第一个数字: "
    read aNum
    echo "输入第二个数字: "
    read anotherNum
    echo "两个数字分别为 $aNum 和 $anotherNum !"
    return $(($aNum+$anotherNum))
}
funWithReturn
echo "输入的两个数字之和为 $? !"


funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}
funWithParam 1 2 3 4 5 6 7 8 9 34 73


#Shell 输入/输出重定向

#command > file	将输出重定向到 file。
#command < file	将输入重定向到 file。
#command >> file	将输出以追加的方式重定向到 file。
#n > file	将文件描述符为 n 的文件重定向到 file。
#n >> file	将文件描述符为 n 的文件以追加的方式重定向到 file。
#n >& m	将输出文件 m 和 n 合并。
#n <& m	将输入文件 m 和 n 合并。
#<< tag	将开始标记 tag 和结束标记 tag 之间的内容作为输入。


#需要注意的是文件描述符 0 通常是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）。


#Here Document
#Here Document 是 Shell 中的一种特殊的重定向方式，用来将输入重定向到一个交互式 Shell 脚本或程序。

cat << EOF
欢迎来到
菜鸟教程
www.runoob.com
EOF


#/dev/null 文件
#如果希望执行某个命令，但又不希望在屏幕上显示输出结果，那么可以将输出重定向到 /dev/null：


#/dev/null 是一个特殊的文件，写入到它的内容都会被丢弃；如果尝试从该文件读取内容，那么什么也读不到。但是 /dev/null 文件非常有用，将命令的输出重定向到它，会起到"禁止输出"的效果。

#如果希望屏蔽 stdout 和 stderr，可以这样写：

$ command > /dev/null 2>&1
#注意：0 是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）。


#这里的&没有固定的意思

#放在>后面的&，表示重定向的目标不是一个文件，而是一个文件描述符，内置的文件描述符如下

#1 => stdout
#2 => stderr
#0 => stdin
#换言之 2>1 代表将stderr重定向到当前路径下文件名为1的regular file中，而2>&1代表将stderr重定向到文件描述符为1的文件(即/dev/stdout)中，这个文件就是stdout在file system中的映射

#而&>file是一种特殊的用法，也可以写成>&file，二者的意思完全相同，都等价于

#>file 2>&1
#此处&>或者>&视作整体，分开没有单独的含义

#顺序问题：

#find /etc -name .bashrc > list 2>&1
# 我想问为什么不能调下顺序,比如这样
#find /etc -name .bashrc 2>&1 > list
#这个是从左到右有顺序的

#第一种

#xxx > list 2>&1
#先将要输出到stdout的内容重定向到文件，此时文件list就是这个程序的stdout，再将stderr重定向到stdout，也就是文件list

#第二种

#xxx 2>&1 > list
#先将要输出到stderr的内容重定向到stdout，此时会产生一个stdout的拷贝，作为程序的stderr，而程序原本要输出到stdout的内容，依然是对接在stdout原身上的，因此第二步重定向stdout，对stdout的拷贝不产生任何影响



