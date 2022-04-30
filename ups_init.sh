#!/bin/env bash
##开机触发脚本初始化监控环境
tmpfile=/tmp/ups/ups.log		#临时文件路径
logfile=/volume1/ups/ups.log	#宿主机日志路径

cp -f /volume1/ups/ups_scan.sh /tmp/ups #复制监控脚本到临时文件
# [[ $(du $logfile | awk -F ' ' '{print$1}') -gt "100" ]] && true > $logfile #判断日志大于100K则清空   #已移动至主脚本中判断
cp -f $logfile $tmpfile #复制宿主机log到临时文件继续写
chmod 777 $tmpfile #赋予777权限