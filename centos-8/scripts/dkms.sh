dnf -y update
dnf -y install gcc make gcc-c++ kernel-devel-`uname -r` perl
dnf -y install --enablerepo=epel dkms
