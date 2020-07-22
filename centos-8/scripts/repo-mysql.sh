rpm -ivh https://dev.mysql.com/get/mysql80-community-release-el8-1.noarch.rpm
sed -i -e 's:enabled=.*:enabled=0:g' /etc/yum.repos.d/mysql*.repo 
