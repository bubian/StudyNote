#!/bin/bash

echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";

echo "Shell 传递参数实例！";
echo "第一个参数为：$1";

echo "参数个数为：$#";
echo "传递的参数作为一个字符串显示：$*";

#$* 与 $@ 区别：

#	相同点：都是引用所有参数。
#	不同点：只有在双引号中体现出来。假设在脚本运行时写了三个参数 1、2、3，，
#	则 " * " 等价于 "1 2 3"（传递了一个参数），而 "@" 等价于 "1" "2" "3"（传递了三个参数）。

echo "-- \$* 演示 ---"
for i in "$*"; do
    echo $i
done

echo "-- \$@ 演示 ---"
for i in "$@"; do
    echo $i
done

if [ -n $1 ] then
	echo "包含第一个参数"
else
	echo "没有包含第一参数"
fi

#expr 是一款表达式计算工具，使用它能完成表达式的求值操作。

val=`expr 2 + 2`
echo "两数之和为 : $val"

a=10
b=20

val=`expr $a + $b`
echo "a + b : $val"

val=`expr $a - $b`
echo "a - b : $val"

val=`expr $a \* $b`
echo "a * b : $val"

val=`expr $b / $a`
echo "b / a : $val"

val=`expr $b % $a`
echo "b % a : $val"

if [ $a == $b ]
then
   echo "a 等于 b"
fi
if [ $a != $b ]
then
   echo "a 不等于 b"
fi



#关系运算符只支持数字，不支持字符串，除非字符串的值是数字。

#下表列出了常用的关系运算符，假定变量 a 为 10，变量 b 为 20：


a=10
b=20

if [ $a -eq $b ]
then
   echo "$a -eq $b : a 等于 b"
else
   echo "$a -eq $b: a 不等于 b"
fi
if [ $a -ne $b ]
then
   echo "$a -ne $b: a 不等于 b"
else
   echo "$a -ne $b : a 等于 b"
fi
if [ $a -gt $b ]
then
   echo "$a -gt $b: a 大于 b"
else
   echo "$a -gt $b: a 不大于 b"
fi
if [ $a -lt $b ]
then
   echo "$a -lt $b: a 小于 b"
else
   echo "$a -lt $b: a 不小于 b"
fi
if [ $a -ge $b ]
then
   echo "$a -ge $b: a 大于或等于 b"
else
   echo "$a -ge $b: a 小于 b"
fi
if [ $a -le $b ]
then
   echo "$a -le $b: a 小于或等于 b"
else
   echo "$a -le $b: a 大于 b"
fi


#布尔运算符

# !	非运算，表达式为 true 则返回 false，否则返回 true。	[ ! false ] 返回 true。
# -o	或运算，有一个表达式为 true 则返回 true。	[ $a -lt 20 -o $b -gt 100 ] 返回 true。
# -a	与运算，两个表达式都为 true 才返回 true。	[ $a -lt 20 -a $b -gt 100 ] 返回 false。

#逻辑运算符


#&&	逻辑的 AND	[[ $a -lt 100 && $b -gt 100 ]] 返回 false
#||	逻辑的 OR	[[ $a -lt 100 || $b -gt 100 ]] 返回 true


#字符串运算符

#=	检测两个字符串是否相等，相等返回 true。	[ $a = $b ] 返回 false。
#!=	检测两个字符串是否相等，不相等返回 true。	[ $a != $b ] 返回 true。
#-z	检测字符串长度是否为0，为0返回 true。	[ -z $a ] 返回 false。
#-n	检测字符串长度是否为0，不为0返回 true。	[ -n "$a" ] 返回 true。
#str	检测字符串是否为空，不为空返回 true。	[ $a ] 返回 true。

#文件测试运算符

#-b file	检测文件是否是块设备文件，如果是，则返回 true。	[ -b $file ] 返回 false。
#-c file	检测文件是否是字符设备文件，如果是，则返回 true。	[ -c $file ] 返回 false。
#-d file	检测文件是否是目录，如果是，则返回 true。	[ -d $file ] 返回 false。
#-f file	检测文件是否是普通文件（既不是目录，也不是设备文件），如果是，则返回 true。	[ -f $file ] 返回 true。
#-g file	检测文件是否设置了 SGID 位，如果是，则返回 true。	[ -g $file ] 返回 false。
#-k file	检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true。	[ -k $file ] 返回 false。
#-p file	检测文件是否是有名管道，如果是，则返回 true。	[ -p $file ] 返回 false。
#-u file	检测文件是否设置了 SUID 位，如果是，则返回 true。	[ -u $file ] 返回 false。
#-r file	检测文件是否可读，如果是，则返回 true。	[ -r $file ] 返回 true。
#-w file	检测文件是否可写，如果是，则返回 true。	[ -w $file ] 返回 true。
#-x file	检测文件是否可执行，如果是，则返回 true。	[ -x $file ] 返回 true。
#-s file	检测文件是否为空（文件大小是否大于0），不为空返回 true。	[ -s $file ] 返回 true。
#-e file	检测文件（包括目录）是否存在，如果是，则返回 true。	[ -e $file ] 返回 true。


file="/var/www/runoob/test.sh"
if [ -r $file ]
then
   echo "文件可读"
else
   echo "文件不可读"
fi
if [ -w $file ]
then
   echo "文件可写"
else
   echo "文件不可写"
fi
if [ -x $file ]
then
   echo "文件可执行"
else
   echo "文件不可执行"
fi
if [ -f $file ]
then
   echo "文件为普通文件"
else
   echo "文件为特殊文件"
fi
if [ -d $file ]
then
   echo "文件是个目录"
else
   echo "文件不是个目录"
fi
if [ -s $file ]
then
   echo "文件不为空"
else
   echo "文件为空"
fi
if [ -e $file ]
then
   echo "文件存在"
else
   echo "文件不存在"
fi




