#!/bin/bash
#######################################################
# Name: onekey_install_docker.sh 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 
# Version: v0.0.1 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　
# Function: Automatic deployment and installation of docker-ce based on CentOS 7.x system
# Author: alichina <Mail：sun946020@126.com | 微信公众号：sunleestudio>
# Create Date: 2019-12-06
# Description: Basic publishing 
#######################################################

function INSTALL {
# Step 1：卸载系统中旧的Docker
rpm -qa | grep docker | xargs yum remove -y

# Step 2：安装所需的依赖软件包
yum install -y yum-utils device-mapper-persistent-data lvm2

# Step 3: 配置Docker安装源
#yum-config-manager -add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo \
	&& yum makecache fast

# Step 4：安装Docker
yum install -y docker-ce docker-ce-cli containerd.io

# Step 5：启动docker服务，并为设置开机自启动
systemctl start docker && systemctl enable docker \
	&& docker version
}

function UNINSTALL {
# Step 1：停止Docker服务
systemctl stop docker

# Step 2：卸载Docker软件
rpm -qa | grep docker | xargs yum remove -y

# Step 3：删除Docker运行生成的相关数据
rm -rf /var/lib/docker
}

echo '
		Please enter the action you want to perform:"install" | "uninstall"
		请输入您要执行的操作：“安装install” 或者 “卸载uninstall”'

read -p "Please enter the action you want to perform: " action

case $action in
	install)
		INSTALL
	;;
	uninstall)
		UNINSTALL && echo 'Docker uninstall Successfully'
	;;
	*)
		echo '
			The action you entered is not supported. 
			Please enter the following format: install | uninstall'
		exit 1
esac
