#!/bin/bash

#显示结果定向至文件

echo "It is a test" > ./myfile

#显示命令执行结果

echo `date`

printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg  
printf "%-10s %-8s %-4.2f\n" 郭靖 男 66.1234 
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543 
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876 


#%s %c %d %f都是格式替代符
#%-10s 指一个宽度为10个字符（-表示左对齐，没有则表示右对齐），任何字符都会被显示在10个字符宽的字符内，如果不足则自动以空格填充，超过也会将内容全部显示出
#%-4.2f 指格式化为小数，其中.2指保留2位小数。


#数值测试,Shell中的 test 命令用于检查某个条件是否成立，它可以进行数值、字符和文件三个方面的测试。

#-eq	等于则为真
#-ne	不等于则为真
#-gt	大于则为真
#-ge	大于等于则为真
#-lt	小于则为真
#-le	小于等于则为真

num1=100
num2=100
if test $[num1] -eq $[num2]
then
    echo '两个数相等！'
else
    echo '两个数不相等！'
fi

#代码中的 [] 执行基本的算数运算

a=5
b=6

result=$[a+b] # 注意等号两边不能有空格
echo "result 为： $result"

num1="ru1noob"
num2="runoob"
if test $num1 = $num2
then
    echo '两个字符串相等!'
else
    echo '两个字符串不相等!'
fi

cd /bin
if test -e ./bash
then
    echo '文件已存在!'
else
    echo '文件不存在!'
fi







