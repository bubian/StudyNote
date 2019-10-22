#!/bin/bash

#if 语句语法格式：

#if condition
#then
#    command1 
#    command2
#    ...
#    commandN 
#fi

#写成一行（适用于终端命令提示符）：

if [ $(ps -ef | grep -c "ssh") -gt 1 ]; then echo "true"; fi

a=10
b=20
if [ $a == $b ]
then
   echo "a 等于 b"
elif [ $a -gt $b ]
then
   echo "a 大于 b"
elif [ $a -lt $b ]
then
   echo "a 小于 b"
else
   echo "没有符合的条件"
fi

#for 循环

#for var in item1 item2 ... itemN
#do
#    command1
#    command2
#    ...
#    commandN
#done

#写成一行：

#for var in item1 item2 ... itemN; do command1; command2… done;


for loop in 1 2 3 4 5
do
    echo "The value is: $loop"
done


int=1
while(( $int<=5 ))
do
    echo $int
    let "int++"
done


echo '按下 <CTRL-D> 退出'
echo -n '输入你最喜欢的网站名: '
while read FILM
do
    echo "是的！$FILM 是一个好网站"
done


#无限循环
#无限循环语法格式：

#while :
#do
#    command
#done
#或者

#while true
#do
#    command
#done
#或者

#for (( ; ; ))


until [ ! $a -lt 10 ]
do
   echo $a
   a=`expr $a + 1`
done



echo '输入 1 到 4 之间的数字:'
echo '你输入的数字为:'
read aNum
case $aNum in
    1)  echo '你选择了 1'
    ;;
    2)  echo '你选择了 2'
    ;;
    3)  echo '你选择了 3'
    ;;
    4)  echo '你选择了 4'
    ;;
    *)  echo '你没有输入 1 到 4 之间的数字'
    ;;
esac


while :
do
    echo -n "输入 1 到 5 之间的数字:"
    read aNum
    case $aNum in
        1|2|3|4|5) echo "你输入的数字为 $aNum!"
        ;;
        *) echo "你输入的数字不是 1 到 5 之间的! 游戏结束"
            break
        ;;
    esac
done



while :
do
    echo -n "输入 1 到 5 之间的数字: "
    read aNum
    case $aNum in
        1|2|3|4|5) echo "你输入的数字为 $aNum!"
        ;;
        *) echo "你输入的数字不是 1 到 5 之间的!"
            continue
            echo "游戏结束"
        ;;
    esac
done






