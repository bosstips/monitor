#!/bin/bash

# $0  脚本名称
# $1-9　　　　　   脚本执行时的参数1到参数9
# $?  脚本的返回值　　　　
# $#  脚本执行时，输入的参数的个数
# $@  输入的参数的具体内容（将输入的参数作为一个多个对象，即是所有参数的一个列表）
# $*  输入的参数的具体内容（将输入的参数作为一个单词）

case $1 in 
    UV) 
        result=`awk '{print $1}'  /var/log/nginx/access.log|sort | uniq -c |wc -l`
        echo $result 
        ;; 
    PV)
        result=`awk '{print $7}'  /var/log/nginx/access.log|wc -l`
        echo $result 
        ;; 
        *) 
        echo "Usage:$0(PV|UV)" 
        ;; 
esac

