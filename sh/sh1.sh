#!/bin/bash

echo I am pds
name="bad boy"
#以上语句将 /etc 下目录的文件名循环出来。
for file in `ls /etc`;do
	echo file
done

for skill in Ada Coffe Action Java;do
	echo "name is $skill"
done

#使用 readonly 命令可以将变量定义为只读变量，只读变量的值不能被改变。

readonly id=1

#使用 unset 命令可以删除变量,变量被删除后不能再次使用。unset 命令不能删除只读变量

unset readonly

#拼接字符串

readonly your_name=pds
# 使用双引号拼接
greeting="hello, "$your_name" !"
greeting_1="hello, ${your_name} !"
echo $greeting  $greeting_1
# 使用单引号拼接
greeting_2='hello, '$your_name' !'
greeting_3='hello, ${your_name} !'
echo $greeting_2  $greeting_3

#获取字符串长度

str="pds is boy"
echo ${#str}

#提取子字符串

str1="i love you"
echo ${str1:1:4}

#查找子字符串
#查找字符 i 或 o 的位置(哪个字母先出现就计算哪个)：

#string="runoob is a great site"
#echo `expr index "$string" io`

#定义数组

arry=(o d s i love you)
arry[0]="123"

#读取数组

value=${arry[2]}

# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}


#多行注释

:<<EOF
注释内容...
注释内容...
注释内容...
EOF


#EOF 也可以使用其他符号:

:<<'
注释内容...
注释内容...
注释内容...
'

:<<!
注释内容...
注释内容...
注释内容...
!






