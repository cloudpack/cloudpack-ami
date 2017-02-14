yum -y update

yum -y install --enablerepo=epel \
	lsof \
	dracut-modules-growroot 

sed -i.bak 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' /etc/fstab
dracut --force --add growroot /boot/initramfs-$(uname -r).img
