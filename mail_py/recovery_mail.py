import smtplib
from email.mime.text import MIMEText
from email.header import Header

msg_from = 'xxxx@qq.com'  # 发送方邮箱        
passwd = 'xx'             # 填入发送方邮箱的授权码        
msg_to = 'xx@qq.com'      # 收件人邮箱        
subject ='通知-已恢复市电供电' # 主题        
content = '您的NAS已恢复市电供电' #内容    
host = 'smtp.qq.com' #发信域名

msg = MIMEText(content)        
msg['Subject'] = subject        
msg['From'] = msg_from
msg['To'] = msg_to        

s1 = smtplib.SMTP_SSL(host, 465)    #创建邮件服务
s1.login(msg_from, passwd)   	 	#登录
try:                      
 s1.sendmail(msg_from, msg_to, msg.as_string())            
 print("发送成功")        
except:            
 print("发送失败")        
finally:            
 s1.quit() 		#关闭服务
