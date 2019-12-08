#!/bin/bash
#######################################################
# Name: onekey_bulid_selfyum.sh 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 
# Version: v0.0.1 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
# Function: Build your own local private software warehouse automatically 
# Author: alichina <Mail：sun946020@126.com | 微信公众号：sunleestudio> 
# Create Date: 2019-11-10 
# Description: Basic publishing 
#######################################################

OS=centos							#变量定义：操作系统类型
VERSION=7							#变量定义：操作系统版本
ARCH=x86_64							#变量定义：平台架构类型
REPO_DIR=/etc/yum.repo.d/					#变量定义：YUM源配置文件保存路径
BASE_DIR=/repos/centos/7/base					#变量定义：本地Base软件包存放路径
EPEL_DIR=/repos/centos/7/epel					#变量定义：本地EPEL软件包存放路径
APACHE_ROOT=/repos						#变量定义：Apache虚拟主机根目录
#中国科学技术大学源地址：mirrors.ustc.edu.cn
#清华大学源地址：mirrors.tuna.tsinghua.edu.cn
BASE_URL=mirrors.ustc.edu.cn
EPEL_URL=mirrors.ustc.edu.cn/epel
#BASE_URL=mirrors.tuna.tsinghua.edu.cn				#函数定义：BASE源的公网地址
#EPEL_URL=mirrors.tuna.tsinghua.edu.cn/epel			#函数定义：EPEL源的公网地址

#Install all depended-upon package(安装必要的软件包)
rpm -qa | grep rsync && echo "The package already installed" || yum install -y rsync
rpm -qa | grep createrepo && echo "The package already installed" || yum install -y createrepo

#Synchronize base package to local specified path(同步Base源到本地指定路径)
[ -d ${BASE_DIR}/os/${ARCH} ] && echo "Directory already exists" || mkdir -p ${BASE_DIR}/os/${ARCH}
rsync -avz --delete --exclude='repodata' rsync://${BASE_URL}/${OS}/${VERSION}/os/${ARCH}/ ${BASE_DIR}/os/${ARCH} \
	&& createrepo ${BASE_DIR}/os/${ARCH}/ || echo "ERROR:Please try again later" && exit 1

[ -d ${BASE_DIR}/updates/$ARCH ] && echo "Directory already exists" || mkdir -p $BASE_DIR/updates/$ARCH
rsync -avz --delete --exclude='repodata' rsync://${BASE_URL}/${OS}/${VERSION}/updates${ARCH}/ ${BASE_DIR}/updates/$ARCH/ \
	&& createrepo ${BASE_DIR}/updates/$ARCH/ || echo "ERROR:Please try again later" && exit 2

[ -d ${BASE_DIR}/extras/$ARCH ] && echo "Directory already exists" || mkdir -p $BASE_DIR/extras/$ARCH
rsync -avz --delete --exclude='repodata' rsync://${BASE_URL}/${OS}/${VERSION}/extras/$ARCH/ ${BASE_DIR}/extras/$ARCH/ \
	&& createrepo ${BASE_DIR}/extras/$ARCH/ || echo "ERROR:Please try again later" && exit 3

[ -d ${BASE_DIR}/centosplus/$ARCH ] && echo "Directory already exists" || mkdir -p $BASE_DIR/centosplus/$ARCH
rsync -avz --delete --exclude='repodata' rsync://${BASE_URL}/${OS}/${VERSION}/centosplus/$ARCH/ $BASE_DIR/centosplus/$ARCH/ \
	&& createrepo $BASE_DIR/centosplus/$ARCH/ || echo "ERROR:Please try again later" && exit 4

[ -d $EPEL_DIR/$ARCH ] && echo 'Directory already exists' || mkdir -p $EPEL_DIR/$ARCH
rsync -avz --delete --exclude='repodata' rsync://$EPEL_URL/$VERSION/$ARCH/ $EPEL_DIR/$ARCH/ \
	&& createrepo $EPEL_DIR/$ARCH/ || echo "ERROR:Please try again later" && exit 5

[ -d $EPEL_DIR/SRPMS ] && echo 'Directory already exists' || mkdir -p $EPEL_DIR/SRPMS
rsync -avz --delete --exclude='repodata' rsync://$EPEL_URL/$VERSION/SRPMS/ $EPEL_DIR/SRPMS/ \
	&& createrepo $EPEL_DIR/SRPMS/ || echo "ERROR:Please try again later" && exit 6

#rsync -avz --delete --exclude='repodata' $BASE_URL/$OS/RPM-GPG-KEY-CentOS-$VERSION $APACHE_ROOT/$OS/

#Building httpd local web serve(搭建httpd本地Web服务器)
rpm -qa | grep httpd && echo "The package already installed" || yum install -y httpd
cat > /etc/httpd/conf.d/repos.conf <<EOF
Listen 8888
<VirtualHost *:8888>
	DocumentRoot /repos
	ServerName localhost
</VirtualHost>

<Directory /repos>
	Options Indexes FollowSymLinks
	AllowOverride none
	Require all granted
</Directory>
EOF

#Configure related services(配置相关服务)
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config && setenforce 0

#service iptables stop && service httpd restart
systemctl stop firewalld && systemctl disable firewalld
systemctl restart httpd && systemctl enable httpd && \
  	  echo 'Congratulations on your successful configuration.You can visit:"httpd://{youripaddress} to view it."' || \
  	  echo 'Error, please check the relevant configuration.'
