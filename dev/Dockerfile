# # 启用buildx插件，适用于v19.03+ 
# docker buildx create --use --name larger_log --node larger_log0 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760 
# # 检查当前的构建器实例
# docker buildx inspect larger_log --bootstrap

# # 编译生成
# docker buildx build -t ponycool/${IMAGE}-${VERSION} --load ./ 

FROM centos:7
LABEL org.opencontainers.image.authors="qiuchengw@qiuchengw.com"

# 用 root 用户操作
USER root
ENV G_CONF_DIR="/configs"
ENV G_SRC_FILE="/opt/appsrc"

# 修改yum源
# COPY yum.repos.d/* /etc/yum.repos.d/
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo
RUN yum clean all && yum makecache

# 设置时区
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新源，安装相应工具
# 安装高版本的gcc devtoolset
# 不清楚是什么情况，以下这种方式安装devtoolset总是会失败，所以使用外部脚本执行的方式进行安装
# RUN yum update -y && yum install -y wget centos-release-scl scl-utils-build devtoolset-11 \
#         mlocate \
#         which \
#         vim

# 配置GDB，让调试显示的漂亮点
COPY gdb_printer /${G_CONF_DIR}/
COPY .gdbinit ~/

# 安装新的git
ADD git-2.37.1.tar.gz ${G_SRC_FILE}/
# 安装cmake
ADD cmake-3.23.3.tar.gz ${G_SRC_FILE}/
# 配置安装boost
ADD boost_1_79_0.tar.gz ${G_SRC_FILE}/

# 使用脚本再来一次执行安装
COPY build.sh ${G_SRC_FILE}/
RUN cd ${G_SRC_FILE}/ && ./build.sh ${G_SRC_FILE}

# RUN cd ${G_SRC_FILE}/git-2.37.1/ && source /opt/rh/devtoolset-11/enable && \
#     ./configure prefix=/usr/local/git/ && \
#     make -j$nproc && make install

# 安装cmake
# ADD cmake-3.23.3.tar.gz ${G_SRC_FILE}/
# RUN cd ${G_SRC_FILE}/cmake-3.23.3/ && scl enable devtoolset-11 bash && \
#     ./configure prefix=/usr/local/cmake/ && \
#     make -j$nproc && make install

# 配置安装boost
# ADD boost_1_79_0.tar.gz ${G_SRC_FILE}/
# RUN cd ${G_SRC_FILE}/boost_1_79_0/ && /opt/rh/devtoolset-11/enable && \
#     ./bootstrap.sh --with-libraries=all --with-toolset=gcc-11.2.1 && ./b2 prefix=/usr

# 创建 me 用户
# RUN useradd --create-home --no-log-init --shell /bin/zsh -G sudo me && \
#     adduser me sudo && \
#     echo 'me:password' | chpasswd

ENV G_APP_DIR="/opt/app"

# 配置zsh 和 oh-my-zsh
# ADD ohmyzsh.tar.gz ~
# RUN cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
#     sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting z /' ~/.zshrc && \
#     chsh -s /bin/zsh

# Add PATH for node & YARN
ENV PATH /usr/local/cmake/bin:/usr/local/cmake/git:$PATH

# 删除 apt/lists，可以减少最终镜像大小
RUN rm -rf /${G_SRC_FILE} 

WORKDIR /root

ENTRYPOINT ["source","/opt/rh/devtoolset-11/enable"]

