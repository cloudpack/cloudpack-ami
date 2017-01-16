rpm -ivh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
sed -i -e 's:enabled=.*:enabled=0:g' /etc/yum.repos.d/mysql*.repo 
