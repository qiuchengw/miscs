FROM centos:7
LABEL org.opencontainers.image.authors="qiuchengw@qiuchengw.com"

# 用 root 用户操作
USER root
ENV G_CONF_DIR="/configs"
ENV G_SRC_FILE="/opt/appsrc"

# 修改yum源
# COPY CentOS-Base.repo /etc/yum.repos.d/
# # RUN yum clean all && yum makecache
# RUN cat /etc/yum.repos.d/CentOS-Base.repo

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo

# 设置时区
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新源，安装相应工具
# 安装高版本的gcc devtoolset
RUN yum update -y && yum install -y wget centos-release-scl scl-utils-build devtoolset-11 \
    mlocate \
    which \
    vim

RUN updatedb && locate gcc
# RUN whereis gcc |xargs echo
# # RUN ["/opt/rh/devtoolset-11/enable"]
# # RUN ["gcc", "--version"]

# # ADD gcc-12.1.0.tar.xz ${G_SRC_FILE}/gcc/

# # 配置GDB调试显示的漂亮点
# COPY gdb_printer /${G_CONF_DIR}/
# COPY .gdbinit ~/

# # 安装新的git
# ADD build.sh ${G_SRC_FILE}/
# RUN cd ${G_SRC_FILE}/ && ./build.sh

# ADD git-2.37.1.tar.gz ${G_SRC_FILE}/
# RUN cd ${G_SRC_FILE}/git-2.37.1/ && \
#     ./configure prefix=/usr/local/git/ && \
#     make -j$nproc && make install

# # 安装cmake
# ADD cmake-3.23.3.tar.gz ${G_SRC_FILE}/
# RUN cd ${G_SRC_FILE}/cmake-3.23.3/ && source /opt/rh/devtoolset-11/enable && \
#     ./configure prefix=/usr/local/cmake/ && \
#     make -j$nproc && make install

# # 配置安装boost
# ADD boost_1_79_0.tar.gz ${G_SRC_FILE}/
# RUN cd ${G_SRC_FILE}/boost_1_79_0/ && /opt/rh/devtoolset-11/enable && \
#     ./bootstrap.sh --with-libraries=all --with-toolset=gcc-11.2.1 && ./b2 prefix=/usr/local/cmake/ && \
#     make -j$nproc && make install

# #  安装 zsh，以后进入容器中时，更加方便地使用 shell
# RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
#     cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
#     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
#     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
#     sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting z /' ~/.zshrc && \
#     chsh -s /bin/zsh

# # 创建 me 用户
# # RUN useradd --create-home --no-log-init --shell /bin/zsh -G sudo me && \
# #     adduser me sudo && \
# #     echo 'me:password' | chpasswd

# # 为 me 安装 omz
# RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
#     cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
#     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
#     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
#     sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting z /' ~/.zshrc

# # Add NVM binaries to root's .bashrc
# USER root
# RUN echo '' >> ~/.zshrc && \
#     echo 'export PATH="/usr/local/cmake/bin:/usr/local/cmake/git:$PATH"' >> ~/.zshrc && \
#     echo '' >> ~/.zshrc

# # Add PATH for node & YARN
# ENV PATH /usr/local/cmake/bin:/usr/local/cmake/git:$PATH

# # 删除 apt/lists，可以减少最终镜像大小
# RUN rm -rf /var/lib/yum/lists/* && \
#     rm -rf /${G_SRC_FILE} 

# WORKDIR /root

