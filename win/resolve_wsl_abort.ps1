# 适应于Linux的子系统已终止，已退出进程，代码为 4294967295
gsudo

#停止LxssManager服务
net stop LxssManager  

sleep 5
#启动LxssManager服务
net start LxssManager  
