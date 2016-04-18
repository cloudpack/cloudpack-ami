rpm -ivh https://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm
sed -i 's:enabled=.*:enabled=0:' /etc/yum.repos.d/pgdg-95-centos.repo
