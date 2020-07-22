rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-8.0-2.el8.elrepo.noarch.rpm
sed -i 's:enabled=.*:enabled=0:' /etc/yum.repos.d/elrepo*.repo
