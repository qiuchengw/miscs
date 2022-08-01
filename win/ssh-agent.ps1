# @REM 检查ssh-agent服务是否启动成功
get-service ssh*

# @REM 启动服务
# Set-Service -Name ssh-agent -StartupType Manual
Start-Service ssh-agent
Start-Sleep(3)

# @REM 执行ssh-add命令检查是否成功
ssh-add -l

# @REM 添加自己的key ：ssh-add