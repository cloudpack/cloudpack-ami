yum -y install epel-release
sed -i 's:enabled=.*:enabled=0:' /etc/yum.repos.d/epel*.repo
