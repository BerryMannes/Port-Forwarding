#!/bin/bash 
# Debain Ubuntu自动安装zerotier 并设置的为planet服务器 
# 下面一条代码取消注释后为自动获取Addr服务器公网ip
# ip=`wget http://ipecho.net/plain -O - -q ; echo` 
# 下面一条代码取消注释后为手动设置Addr服务器公网ip
ip=`39.103.212.40` 
# 设置https访问端口
httpsprot=9877
# 设置服务端口
serverport=9878
addr=$ip/$serverport
apt autoremove 
apt update -y 
apt install curl -y 
echo "**************************************************************************************************************" 
echo "**********************************Deabin Unbuntu自动安装Zerotier-Planet服务器**********************************" 
echo "**************************************************************************************************************" 
curl -s https://install.zerotier.com/ | sudo bash 
identity=`cat /var/lib/zerotier-one/identity.public` 
echo "identity :$identity" 
apt-get -y install build-essential 
apt-get install git -y 
git clone https://ghproxy.com/https://github.com/BerryMannes/ZeroTierOne.git 
cd ./ZeroTierOne/attic/world/ 
sed -i '/roots.push_back/d' ./mkworld.cpp 
sed -i '/roots.back()/d' ./mkworld.cpp 
sed -i '85i roots.push_back(World::Root());' ./mkworld.cpp 
sed -i '86i roots.back().identity = Identity(\"'"$identity"'\");' ./mkworld.cpp 
sed -i '87i roots.back().stableEndpoints.push_back(InetAddress(\"'"$addr"'\"));' ./mkworld.cpp 
source ./build.sh 
./mkworld 
mv ./world.bin ./planet 
\cp -r ./planet /var/lib/zerotier-one/ 
\cp -r ./planet /root 
systemctl restart zerotier-one.service 
wget https://ghproxy.com/https://raw.githubusercontent.com/BerryMannes/Port-Forwarding/main/ztncui/ztncui_0.8.6_amd64.deb
sudo dpkg -i ztncui_0.8.6_amd64.deb 
cd /opt/key-networks/ztncui/ 
echo "HTTPS_PORT = $httpsprot" >>./.env 
secret=`cat /var/lib/zerotier-one/authtoken.secret` 
echo "ZT_TOKEN = $secret" >>./.env 
echo "ZT_ADDR=$ip:$serverport" >>./.env 
echo "NODE_ENV = production" >>./.env 
echo "HTTP_ALL_INTERFACES=yes" >>./.env 
systemctl restart ztncui 
rm -rf /root/ZeroTierOne 
echo "****************************************************************************************************************" 
echo "*********************************************恭喜您，系统安装成功！*********************************************" 
echo "访问地址：https://$ip:$httpsprot" 
echo "初始账号：admin" 
echo "初始密码：password" 
echo "新Planet文件在/root目录" 
echo "请在安全组和防火墙放行TCP：$httpsprot和TCP/UDP:$serverport" 
echo "************************一键安装脚本由https://github.com/BerryMannes/Port-Forwarding/提供***********************" 
echo "****************************************************************************************************************" 
