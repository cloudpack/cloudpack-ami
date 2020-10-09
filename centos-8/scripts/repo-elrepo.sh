rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
dnf install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
#sed -i 's:enabled=.*:enabled=0:' /etc/dnf.repos.d/elrepo*.repo
exit 0
