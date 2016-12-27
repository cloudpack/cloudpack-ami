yum -y update

yum -y install --enablerepo=epel \
	lsof \
	dracut-modules-growroot \
	python-pip
pip install -U urllib3 pip
pip install -U awscli

sed -i.bak 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' /etc/fstab
dracut --force --add growroot /boot/initramfs-$(uname -r).img
