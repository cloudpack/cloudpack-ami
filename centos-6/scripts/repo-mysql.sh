rpm -ivh http://dev.mysql.com/get/mysql57-community-release-el6-7.noarch.rpm
sed -i.bak \
  -e '/\[mysql56-community\]/,/gpgcheck=1/ s:enabled=.*:enabled=0:g' \
  -e '/\[mysql57-community\]/,/gpgcheck=1/ s:enabled=.*:enabled=0:g' \
  /etc/yum.repos.d/mysql-community.repo 
