# build
# docker build -t devcos:1.7 -o type=local,dest=../c7g11 --shm-size 2147483648 .
# =====================
# run
# --shm-size 2147483648         /dev/shm 大小
# -v /d/dshare:/mnt/data        注意：windows下的挂载路径形式 /d/dshare
# docker run -it --privileged --shm-size 2147483648 -v /d/dshare:/mnt/data --name [name] [image-id] /bin/zsh
# docker run -it --privileged --shm-size 2147483648 --sysctl net.core.rmem_max=8388608 -v /d/dshare:/mnt/data --name devcos 8363908678f7
# docker run -it --privileged --net=host --shm-size 21474836480 --sysctl kernel.msgmax=65536 --sysctl fs.mqueue.msg_max=10000 --sysctl kernel.shmmni=40960 -v /d/dshare:/mnt/data --name devcos_allport_shm 18294fe2e99e

# 设置宿主机的参数： 
# 注意，如果是windows docker destop，还需要在/etc/profile 中加上 sysctl -p 让以下设置生效
# vim /etc/sysctl.conf
# --------------------------------
# # content of this file will override /etc/sysctl.d/*
# net.core.rmem_max = 8388608
# # kernel.shmmni=4096
# # kernel.shmmax=17179869184
# # kernel.shmall=8388608
# # kernel.sem=<SEMMSL> <SEMMNS> <SEMOPM> <SEMMNI>
# # kernel.sem=250 1024000 32 4096
# kernel.msgmni=32768
# kernel.msgmax=65536
# kernel.msgmnb=1048576
# # net.core.rmem_default=256960
# net.core.rmem_max=8388608
# # net.core.wmem_default=256960
# # net.core.wmem_max=256960

# docker run -it --privileged --net=host --ipc=host --shm-size 21474836480 -v /d/dshare:/mnt/data --name devcos_allport_shm 18294fe2e99e

FROM centos:7
LABEL org.opencontainers.image.authors="qiuchengw@163.com"

ENV container docker
RUN echo 'root:root' | chpasswd

# 修改源
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo

# systemd服务启动相关的
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done)
RUN rm -f /etc/systemd/system/*.wants/* \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# 配置环境
ENV G_APP_DIR="/opt/app/"
ENV G_SRCFILE_DIR="/opt/appsrc"
ENV G_HOME_DIR="/root"

# 设置时区
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新源，安装相应工具
# 不清楚是什么情况，以下这种方式安装devtoolset总是会失败，所以使用外部脚本执行的方式进行安装
RUN set -evx -o pipefail && yum clean all && yum makecache && yum update -y \
        && yum install -y wget \
                mlocate \
                which \
                vim \
                dos2unix \
                zsh \
                openssh-server \
                openssl-devel \
                gettext \
                bzip2-devel \
                libffi-devel \
                net-tools \
                ncurses-devel \
                readline-devel \
                xz lzma xz-devel sqlite-devel gdbm-devel \
                java-1.8.0-openjdk-devel \
        && yum autoremove -y

# 配置GDB，让调试显示的漂亮点
COPY gdb_printer /${G_APP_DIR}/
COPY .gdbinit ${G_HOME_DIR}/
# 复制pip源设置
COPY pip.conf ${G_HOME_DIR}/.pip/

# 安装新的git
ADD git-2.37.1.tar.gz ${G_SRCFILE_DIR}/
# 安装cmake
ADD cmake-3.23.3.tar.gz ${G_SRCFILE_DIR}/
# 配置安装boost
ADD boost_1_79_0.tar.gz ${G_SRCFILE_DIR}/
# 安装Python
ADD Python-3.8.10.tgz ${G_SRCFILE_DIR}/

# 使用脚本再来一次执行安装
COPY build.sh ${G_SRCFILE_DIR}/
RUN set -evx -o pipefail && cd ${G_SRCFILE_DIR}/ && dos2unix ./build.sh && ./build.sh ${G_SRCFILE_DIR}

# 环境变量
# 配置zsh 和 oh-my-zsh 放到root目录下，没有其它的用户
ADD ohmyzsh.tar.gz ${G_HOME_DIR}/
RUN set -evx -o pipefail \
        && cp ${G_HOME_DIR}/.oh-my-zsh/templates/zshrc.zsh-template ${G_HOME_DIR}/.zshrc \
        && sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting z /' ${G_HOME_DIR}/.zshrc \
        && echo 'export PYTHON3_HOME=/usr/local/python3.8.10' \
        && echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PYTHON3_HOME/lib' \
        && echo 'export PATH=$PATH:$PYTHON3_HOME/bin' \
        && echo 'source /opt/rh/devtoolset-11/enable' >> ${G_HOME_DIR}/.zshrc \
        && chsh -s /bin/zsh

# 配置sshd
# SSH login fix. Otherwise user is kicked off after login
RUN set -evx -o pipefail \
        && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
        && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# 端口2022
EXPOSE 2022

# 启用systemd
CMD ["/sbin/init"]

# 删除 apt/lists，可以减少最终镜像大小
# RUN rm -rf /${G_SRCFILE_DIR} 
WORKDIR ${G_HOME_DIR}
# ENTRYPOINT ["/bin/zsh"]

