# 配置GDB调试显示的漂亮点
G_SRC_FILE="/opt/appsrc"
ls -a /opt/appsrc
# source /opt/rh/devtoolset-11/enable
exit 0

# 安装新的git
cd ${G_SRC_FILE}/git-2.37.1/ 
# source /opt/rh/devtoolset-11/enable 
./configure prefix=/usr/local/git/ 
make -j$nproc && make install

