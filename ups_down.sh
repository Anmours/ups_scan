#!/bin/env bash
##关机触发脚本拷贝 临时文件 日志 至 宿主机
tmpfile=/tmp/ups/ups.log		#临时文件路径
logfile=/volume1/ups/ups.log	#宿主机日志路径
cp -f $tmpfile $logfile