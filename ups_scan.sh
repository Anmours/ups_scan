#!/bin/env bash
## ups监控脚本

##################-- 脚本说明 --##############################################
## 群辉ds918+ 6.2.3自用，其他版本和平台自测
# 脚本内容概述
#   1. 每分钟Ping IP1，如果正常不做任何操作，仅写入日志；
#   2. 不正常接着Ping IP2，两者均不正常，判断为停电，写日志并尝试发邮件通知；
#   3. 8 分钟后重新检查 IP1 + IP2 ，如果正常，判断恢复市电，写日志并尝试发邮件通知；
#   4. 不正常则立即执行关机指令，写日志并尝试发邮件通知；
#   6. 每次运行脚本时判断临时文件中日志大小如果超过100k写入宿主机并清空临时文件；
#   *写日志操作均为写入临时文件，不会影响硬盘休眠。
#   *发送邮件需要网络支持，环境不支持请注释或删除发送邮件语句
##################-- 脚本说明 --##############################################


###################-- 配置区 --################################################
Monitor1=192.168.31.50	#被测IP 1
Monitor2=192.168.31.51	#被测IP 2

name1=云台	#设备名称1
name2=空调	#设备名称2

DelayTime=480s		 #复检等待时间

#启用临时文件路径，以支持硬盘休眠
tmpfile=/tmp/ups/ups.log		    #临时文件路径
logfile=/volume1/ups/ups.log	    #宿主机日志路径
logfile_route=/volume1/ups/log/ #宿主机历史日志目录

#邮件通知脚本文件路径
stop_mail=/volume1/ups/mail_py/stop_mail.py	        #停电通知邮件脚本
recovery_mail=/volume1/ups/mail_py/recovery_mail.py #恢复正常通知邮件脚本
shutdown_mail=/volume1/ups/mail_py/shutdown_mail.py #关机通知脚本
####################-- 配置区 --##############################################


#判断临时文件中 运行日志的大小，超过100k写入宿主机历史目录并清空当前文件  1分钟运行一次，24小时 大概几十k吧。
if [[ $(du $tmpfile | awk -F ' ' '{print$1}') -gt "100" ]]
    then
    cp -f $tmpfile $logfile_route$(date +%Y%m%d%H%M)_ups.log
    :>$tmpfile
fi

#监控 UPS
if ping $Monitor1 -W 2 -w 2 -c 2 | grep ' bytes from ' > /dev/null  #ping设备1中是否带bytes from字样
then	#true
    echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：检查 [$name1] 正常。" | tee -a  $tmpfile	#写日志
else	#false
    if ping $Monitor2 -W 2 -w 2 -c 2 | grep ' bytes from ' > /dev/null #ping设备2
    then
        echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：检查 [$name1] 失败，检查 [$name2] 正常。" | tee -a  $tmpfile	#写日志
        echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：您的 [$name1] 设备异常，请确认其状态.." | tee -a  $tmpfile	#写日志
    else
        synologset1 sys warn 0x11600036		#写入群辉系统日志 已断开市电
        echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：检查 [$name1 和 $name2]全失败，UPS已经断开市电，$DelayTime 后复检····" | tee -a  $tmpfile    #写日志
        python3 $stop_mail  #执行py脚本发送邮件通知 已断开市电
        
        sleep $DelayTime #休眠设定的时间
        
        if ping $Monitor1 -W 2 -w 2 -c 2 | grep ' bytes from ' > /dev/null	#到达休眠时间，重新ping设备1
        then  #true
            synologset1 sys warn 0x11600037	#写入群辉系统日志 恢复市电
            echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：检查 [$name1]成功，已恢复市电，退出复检。" | tee -a  $tmpfile #写日志
            python3 $recovery_mail  #执行py脚本发送邮件通知 恢复市电
        else	#false
            if ping $Monitor2 -W 2 -w 2 -c 2 | grep ' bytes from ' > /dev/null # 继续ping设备2
            then #true
                synologset1 sys warn 0x11600037	#写入群辉系统日志 恢复电力
                echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：检查 [$name1]失败，检查 [$name2] 正常。" | tee -a  $tmpfile	#写日志
				echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：您的 [$name1] 设备异常，请确认其状态.." | tee -a  $tmpfile	    #写日志
                python3 $recovery_mail  #执行py脚本发送邮件通知 恢复市电
            else #false
                synologset1 sys warn 0x11600035 #写入群辉系统日志 即将关机
                echo "$(date -d today +"%Y-%m-%d %H:%M:%S")：检查 [$name1 和 $name2] 均失败，控制NAS关机。" | tee -a  $tmpfile   #写日志
                python3 $shutdown_mail 	#执行py脚本发送邮件通知 NAS已关机
                sleep 3s  #等待3s
                # cp -f $tmpfile $logfile	# 关机前复制临时中的日志到宿主机 #群辉通过关机触发脚本实现，其他平台取消注释
                shutdown -P +0	#+0或now代表立即关机，+1 一分钟后关机，自行定义
            fi
        fi
    fi
fi
exit 0
