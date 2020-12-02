#!/bin/bash

# $0  脚本名称
# $1-9　　　　　   脚本执行时的参数1到参数9
# $?  脚本的返回值　　　　
# $#  脚本执行时，输入的参数的个数
# $@  输入的参数的具体内容（将输入的参数作为一个多个对象，即是所有参数的一个列表）
# $*  输入的参数的具体内容（将输入的参数作为一个单词）

# 用户名
MYSQL_USER='root'

# 密码
MYSQL_PWD='123456'

# 主机地址/IP
MYSQL_HOST='127.0.0.1'

# 端口
MYSQL_PORT='3306'

# 数据连接
MYSQL_CONN="/usr/bin/mysqladmin -u${MYSQL_USER} -p${MYSQL_PWD} -h${MYSQL_HOST} -P${MYSQL_PORT}"

# 参数是否正确
if [ $# -ne "1" ];then 
    echo "arg error!" 
fi 

# 获取数据
case $1 in 
    Uptime) 
        result=`${MYSQL_CONN} status|cut -f2 -d":"|awk '{print $1}'`
        echo $result 
        ;; 
    Com_update) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_update"|cut -d"|" -f3` 
        echo $result 
        ;; 
    Slow_queries) 
        result=`${MYSQL_CONN} status |cut -f5 -d":"|cut -f1 -d"O"` 
        echo $result 
        ;; 
    Com_select) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_select"|cut -d"|" -f3` 
        echo $result 
                ;; 
    Com_rollback) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_rollback"|cut -d"|" -f3` 
                echo $result 
                ;; 
    #查询
    Questions) 
        result=`${MYSQL_CONN} status|cut -f4 -d":"|cut -f1 -d"S"` 
                echo $result 
                ;; 
    Com_insert) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_insert"|cut -d"|" -f3` 
                echo $result 
                ;; 
    Com_delete) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_delete"|cut -d"|" -f3` 
                echo $result 
                ;; 
    Com_commit) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_commit"|cut -d"|" -f3` 
                echo $result 
                ;; 
    #发送的流量
    Bytes_sent) 
        result=`${MYSQL_CONN} extended-status |grep -w "Bytes_sent" |cut -d"|" -f3` 
                echo $result 
                ;; 
    #接收的流量
    Bytes_received) 
        result=`${MYSQL_CONN} extended-status |grep -w "Bytes_received" |cut -d"|" -f3` 
                echo $result 
                ;; 
    Com_begin) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_begin"|cut -d"|" -f3` 
                echo $result 
                ;;
    QPS )
        Uptime=`${MYSQL_CONN} status|cut -f2 -d":"|awk '{print $1}'`
        Questions=`${MYSQL_CONN} status | awk '{print $6}'`
        result=`awk 'BEGIN{printf "%.2f\n",'$Questions'/'$Uptime'}'`
	declare -i result
        echo $result
        ;;
    TPS )
        Uptime=`${MYSQL_CONN} status|cut -f2 -d":"|awk '{print $1}'`
        rollback=`${MYSQL_CONN} extended-status | awk '/\<Com_rollback\>/{print $4}'`
        commit=`${MYSQL_CONN} extended-status | awk '/\<Com_commit\>/{print $4}'`
        result=`awk 'BEGIN{printf "%.2f\n",'$(($rollback+$commit))'/'$Uptime'}'`
	declare -i result
        echo $result
        ;;
    TARGET )
        Reads=`${MYSQL_CONN} extended-status|awk '/Innodb_buffer_pool_reads/{print $4}'`
        Requests=`${MYSQL_CONN} extended-status|awk '/nnodb_buffer_pool_read_requests/{print $4}'`
        result=`awk 'BEGIN{printf "%.2f\n",'$Reads'/'$Requests*100'}'`
	declare -i result
        echo $result
        ;;
    DB_Size )
        result=`mysql -u${MYSQL_USER} -h${MYSQL_HOST} -p${MYSQL_PWD} -P${MYSQL_PORT} -Dinformation_schema -e "select concat(round(sum(data_length/1024/1024),2)) as data from tables" |awk 'NR==2{print $1}'`
	declare -i result
        echo $result
        ;;
    DB_zabbix_size )
        result=`mysql -u${MYSQL_USER} -h${MYSQL_HOST} -p${MYSQL_PWD} -P${MYSQL_PORT} -Dinformation_schema -e "select concat(round(sum(data_length/1024/1024),2)) as data from tables where table_schema='zabbix'" | awk 'NR==2{print $1}'`
	declare -i result
        echo $result
        ;;
        *) 
        echo "Usage:$0(DB_Size|DB_zabbix_size|TARGET|QPS|TPS|Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|Com_begin)" 
        ;; 
esac

