# 配置GDB调试显示的漂亮点
G_SRC_FILE=$1

echo "installing depends ..."
yum update -y 
# gettext： 在编译git的时候需要执行msgfmt命令
# cmake：需要使用openssl-devel
# yum install -y wget mlocate which vim zsh gettext openssl-devel

echo "import keys ..."
wget http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

yum install -y centos-release-scl scl-utils-build 
echo "==> install devltoolset-11!"
yum install -y devtoolset-11
yum autoremove -y
echo "==> depends installed!"

# scl enable devtoolset-11 bash 
source /opt/rh/devtoolset-11/enable

# gcc 版本号
# GCC_VER=`gcc -dumpversion`

### configure C compiler
export compiler=$(which gcc)
### get version code
MAJOR=$(echo __GNUC__ | $compiler -E -xc - | tail -n 1)
MINOR=$(echo __GNUC_MINOR__ | $compiler -E -xc - | tail -n 1)
PATCHLEVEL=$(echo __GNUC_PATCHLEVEL__ | $compiler -E -xc - | tail -n 1)
GCC_VER="$MAJOR.$MINOR.$PATCHLEVEL"

# 安装新的git
echo "==> building git ..."
cd ${G_SRC_FILE}/git-2.37.1/
./configure --prefix=/usr/local
# 无gui编译
make -j$nproc NO_TCLTK=1 && make install

# install cmake
echo "==> building cmake ..."
cd ${G_SRC_FILE}/cmake-3.23.3/ 
./bootstrap --parallel=$nproc --prefix=/usr/local
make -j$nproc && make install

# install python
echo "==> building python ..."
cd ${G_SRC_FILE}/Python-3.8.10/
./configure --enable-optimizations --with-ssl --prefix=/usr/local/python3.8.10
make -j$nproc && make install
# 设置路径
ln -s /usr/local/python3.8.10/bin/python3 /usr/local/bin/python3
ln -s /usr/local/python3.8.10/bin/pip3 /usr/local/bin/pip3

# install boost
echo "==> building boost ..."
cd ${G_SRC_FILE}/boost_1_79_0/ 
./bootstrap.sh --with-libraries=all --with-toolset=gcc 
./b2 toolset=gcc-${GCC_VER} && ./b2 install --prefix=/usr

# 删除本地的安装文件，确保镜像大小较小
cd ${G_SRC_FILE}/../
rm -rf ${G_SRC_FILE}
