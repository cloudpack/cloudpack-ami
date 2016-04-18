rpm -ivh http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm
sed -i -e 's:enabled=.*:enabled=0:g' /etc/yum.repos.d/mysql*.repo 
