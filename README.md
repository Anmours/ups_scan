# 群辉NAS小工具——后备式UPS实现停电自动关机脚本
- 使用ping局域网在线设备的功能实现判断是否停电，如果停电，间隔8分钟再次检查，如果还是未ping通，控制NAS关机。
- 环境：群辉ds918+ 6.2.3，其他版本和平台自测;

## 运行
### 一、获取文件
- 下载或者拉取本库文件
- 第一次部署手动创建一下ups.log
- 完整文件结构

![图片](https://user-images.githubusercontent.com/76721799/166112404-8ce7b40a-6506-4529-adb0-6455a7df655d.png)


## 二、修改配置
- 修改.sh脚本文件中的配置区为自己的配置（sh文件中每一行都有注释，自己看着改）。


- ups_scan.sh 中需改的内容
```
Monitor1=192.168.31.50	#被测IP 1
Monitor2=192.168.31.51	#被测IP 2

name1=云台	#设备名称1
name2=空调	#设备名称2

DelayTime=480s		 #复检等待时间，根据自己ups持续时间 加大或减少时间

#启用临时文件路径，以支持硬盘休眠
tmpfile=/tmp/ups/ups.log		    #临时文件路径
logfile=/volume1/ups/ups.log	    #宿主机日志路径
logfile_route=/volume1/ups/log/ #宿主机历史日志目录

#邮件通知脚本文件路径
stop_mail=/volume1/ups/mail_py/stop_mail.py	        #停电通知邮件脚本
recovery_mail=/volume1/ups/mail_py/recovery_mail.py #恢复正常通知邮件脚本
shutdown_mail=/volume1/ups/mail_py/shutdown_mail.py #关机通知脚本
```
- ups_init.sh 中需改的内容
```
tmpfile=/tmp/ups/ups.log       #临时文件路径
logfile=/volume1/ups/ups.log   #宿主机日志路径
```
- ups_down.sh 中需改的内容
```
tmpfile=/tmp/ups/ups.log		#临时文件路径
logfile=/volume1/ups/ups.log	#宿主机日志路径
```
> *注意：3个.sh中日志路径需完全一致，否则达不到预期效果

- 邮件py中需改的内容
```
msg_from = 'xxxx@qq.com'  # 发送方邮箱        
passwd = 'xx'             # 填入发送方邮箱的授权码        
msg_to = 'xx@qq.com'      # 收件人邮箱        
subject ='通知-已恢复市电供电' # 主题        
content = '您的NAS已恢复市电供电' #内容   
```
> 关于邮件通知：
由于我这台设备所在的环境是乡下，镇上有多条供电线路，导致虽然家里停电但是镇上供网的机房不会停电，只要家里光猫有电就能联网，所以我写了发送邮件通知，一般情况下像小区停电肯定是没网的，那么发送邮件的功能直接就报废，你们用的时候可以根据自己实际情况来修改脚本~

## 三、运行脚本
### 3.1设置开机触发ups_init.sh脚本，作用：初始化运行环境

![图片](https://user-images.githubusercontent.com/76721799/166104839-d040dc57-b4ca-41eb-aaa0-38f24ff93551.png)
![图片](https://user-images.githubusercontent.com/76721799/166104870-e0105e13-ff50-4c78-baa4-55c118363764.png)

### 3.2 设置运行监控脚本ups_scan.sh
#### 3.2.1脚本内容概述
1. 每分钟Ping IP1，如果正常不做任何操作，仅写入日志；
2. 不正常接着Ping IP2，两者均不正常，判断为停电，写日志并尝试发邮件通知；
3. 8分钟后重新检查 IP1 + IP2 ，如果正常，判断恢复市电，写日志并尝试发邮件通知；
4. 不正常则立即执行关机指令，写日志并尝试发邮件通知；
6. 每次运行脚本时判断临时文件中日志大小如果超过100k写入宿主机并清空临时文件；
7. *发送邮件需要网络支持，环境不支持请注释或删除发送邮件语句
> ***写日志操作均为写入临时文件中，不会影响硬盘休眠。**


#### 3.2.2设置运行脚本

- 根据需求设置定时脚本 我这里设置的每分钟

![图片](https://user-images.githubusercontent.com/76721799/166105372-8e88f68b-eb5d-4d1c-92be-fcb8151ba1c7.png)
![图片](https://user-images.githubusercontent.com/76721799/166105375-af8d8e94-a4bf-4969-b7ed-63b22277e263.png)
![图片](https://user-images.githubusercontent.com/76721799/166105401-f6d20788-7fe9-414e-8e1e-e1b9dc6c3a06.png)


### 3.3设置关机触发ups_down脚本，作用：拷贝临时文件中的日志到宿主机

![图片](https://user-images.githubusercontent.com/76721799/166104943-a3d67d72-9075-4c20-b6ff-463712820cad.png)
![图片](https://user-images.githubusercontent.com/76721799/166104953-4afa6cd7-f9bb-4307-bba3-1b4336d7a9ca.png)


### 3.4全部操作完成后，手动运行一次ups_init.sh 在开启定时任务ups_scan.sh 即可监控了
·
> 运行效果：

![图片](https://user-images.githubusercontent.com/76721799/166113289-048d32b3-0f97-481f-9a47-e0294515d7f6.png)
![图片](https://user-images.githubusercontent.com/76721799/166113354-d59db9b7-32ca-4479-b142-ea54516bee06.png)
（演示效果）
·

By：Anmours 

转载注明出处,谢谢
