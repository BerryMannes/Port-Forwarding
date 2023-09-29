#!/bin/bash 
# Debain Ubuntu自动安装zerotier 并设置的为planet服务器 
# 下面一条代码取消注释后为自动获取Addr服务器公网ip
ip=`wget http://ipecho.net/plain -O - -q ; echo` 
# 下面一条代码取消注释后为手动设置Addr服务器公网ip
# ip=`223.6.6.6` 
# 设置https访问端口
httpsprot=3443
# 设置服务端口
serverport=9993
addr=$ip/$serverport
yum install gcc gcc-c++ -y
yum install git -y
yum install json-devel -y
echo "**************************************************************************************************************" 
echo "**********************************Deabin Unbuntu自动安装Zerotier-Planet服务器**********************************" 
echo "**************************************************************************************************************" 
curl -s https://install.zerotier.com/ | sudo bash 
cd /opt && git clone -v https://ghproxy.com/https://github.com/BerryMannes/ZeroTierOne.git --depth 1 
cd /var/lib/zerotier-one && zerotier-idtool initmoon identity.public >moon.json
cd / && git clone https://gitee.com/opopop880/docker-zerotier-planet.git
mv ./docker-zerotier-planet ./app
  echo "{
  \"stableEndpoints\": [
    \"$ip/9993\"
  ]
}
" >/app/patch/patch.json
cd /app/patch && python3 patch.py 
cd /var/lib/zerotier-one && zerotier-idtool genmoon moon.json && mkdir moons.d && cp ./*.moon ./moons.d
cd /opt/ZeroTierOne/attic/world/ && sh build.sh
sleep 8s
cd /opt/ZeroTierOne/attic/world/ && ./mkworld
mkdir /app/bin -p && cp world.bin /app/bin/planet
cd /app/bin/
\cp -r ./planet /var/lib/zerotier-one/
\cp -r ./planet /root
systemctl restart zerotier-one.service
wget https://gitee.com/opopop880/ztncui/attach_files/932633/download/ztncui-0.8.6-1.x86_64.rpm
rpm -ivh ztncui-0.8.6-1.x86_64.rpm
cd /opt/key-networks/ztncui/
echo 'HTTP_PORT=3443' >.env
echo 'NODE_ENV=production' >>.env
echo 'HTTP_ALL_INTERFACES=true' >>.env
systemctl restart ztncui
rm -rf /opt/ZeroTierOne
echo "****************************************************************************************************************" 
echo "*********************************************恭喜您，系统安装成功！*********************************************" 
echo "访问地址：https://yourip:3443" 
echo "初始账号：admin" 
echo "初始密码：password" 
echo "新Planet文件在/root目录" 
echo "请在安全组和防火墙放行TCP：3443和TCP/UDP:9993" 
echo "************************一键安装脚本由https://github.com/BerryMannes/Port-Forwarding/提供***********************" 
echo "****************************************************************************************************************" 
