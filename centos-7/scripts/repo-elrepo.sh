rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
sed -i 's:enabled=.*:enabled=0:' /etc/yum.repos.d/elrepo*.repo
