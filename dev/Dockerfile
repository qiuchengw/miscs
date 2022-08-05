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
ENV G_APP_DIR="/opt/app/"
ENV G_SRCFILE_DIR="/opt/appsrc"
ENV G_HOME_DIR="/root"

# 修改yum源
# COPY yum.repos.d/* /etc/yum.repos.d/
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://mirror.centos.org|baseurl=https://mirrors.tuna.tsinghua.edu.cn|g' \
        -i.bak \
        /etc/yum.repos.d/CentOS-*.repo
RUN set -evx -o pipefail && yum clean all && yum makecache fast

# 设置时区
ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新源，安装相应工具
# 安装高版本的gcc devtoolset
# 不清楚是什么情况，以下这种方式安装devtoolset总是会失败，所以使用外部脚本执行的方式进行安装
RUN set -evx -o pipefail && yum update -y \
        && yum install -y wget \
                mlocate \
                which \
                vim \
                dos2unix \
                zsh \
                openssh-server \
                java-1.8.0-openjdk-devel

# 配置GDB，让调试显示的漂亮点
COPY gdb_printer /${G_APP_DIR}/
COPY .gdbinit ~/

# 安装新的git
ADD git-2.37.1.tar.gz ${G_SRCFILE_DIR}/
# 安装cmake
ADD cmake-3.23.3.tar.gz ${G_SRCFILE_DIR}/
# 配置安装boost
ADD boost_1_79_0.tar.gz ${G_SRCFILE_DIR}/

# 使用脚本再来一次执行安装
COPY build.sh ${G_SRCFILE_DIR}/
RUN set -evx -o pipefail && cd ${G_SRCFILE_DIR}/ && dos2unix ./build.sh && ./build.sh ${G_SRCFILE_DIR}

# RUN cd ${G_SRCFILE_DIR}/git-2.37.1/ && source /opt/rh/devtoolset-11/enable && \
#     ./configure prefix=/usr/local/git/ && \
#     make -j$nproc && make install

# 安装cmake
# ADD cmake-3.23.3.tar.gz ${G_SRCFILE_DIR}/
# RUN cd ${G_SRCFILE_DIR}/cmake-3.23.3/ && scl enable devtoolset-11 bash && \
#     ./configure prefix=/usr/local/cmake/ && \
#     make -j$nproc && make install

# 配置安装boost
# ADD boost_1_79_0.tar.gz ${G_SRCFILE_DIR}/
# RUN cd ${G_SRCFILE_DIR}/boost_1_79_0/ && /opt/rh/devtoolset-11/enable && \
#     ./bootstrap.sh --with-libraries=all --with-toolset=gcc-11.2.1 && ./b2 prefix=/usr

# 创建 me 用户
# RUN useradd --create-home --no-log-init --shell /bin/zsh -G sudo me && \
#     adduser me sudo && \
#     echo 'me:password' | chpasswd

# 配置zsh 和 oh-my-zsh 放到root目录下，没有其它的用户
ADD ohmyzsh.tar.gz ${G_HOME_DIR}/
RUN set -evx -o pipefail \
        && cp ${G_HOME_DIR}/.oh-my-zsh/templates/zshrc.zsh-template ${G_HOME_DIR}/.zshrc \
        && sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting z /' ${G_HOME_DIR}/.zshrc \
        && chsh -s /bin/zsh

# 配置sshd
# SSH login fix. Otherwise user is kicked off after login
RUN set -evx -o pipefail \
        && mkdir /var/run/sshd \
        && sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
        && echo 'root:screencast' | chpasswd \
        && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
# 端口2022
EXPOSE 2022
CMD ["/usr/sbin/sshd", "-D"]

# Add PATH for node & YARN

# 删除 apt/lists，可以减少最终镜像大小
RUN rm -rf /${G_SRCFILE_DIR} 

WORKDIR ${G_HOME_DIR}

# ENTRYPOINT ["source","/opt/rh/devtoolset-11/enable"]

