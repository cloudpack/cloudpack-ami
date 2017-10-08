yum -y update

yum -y install --enablerepo=epel \
	lsof \
	dracut-modules-growroot 

sed -i.bak -e 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' -e 's@\(.*\)swap\(.*\)@#\1swap\2@g' /etc/fstab
swapoff -a
lvremove -f vg_root lv_swap

sed -i 's:\(.*\)rd_LVM_LV=vg_root/lv_swap\(.*\):\1\2:g' /boot/grub/grub.conf
#sed -i '/^GRUB_CMDLINE_LINUX/s/"$/ net.ifnames=0"/' /etc/default/grub
#sed -i.bak -e 's/\(.*\)linux16\(.*\)/\1linux16\2 maxcpus=18/g' /boot/grub2/grub.cfg
#grep net.ifnames /etc/default/grub || sed -i '/^GRUB_CMDLINE_LINUX/s/\"$/ net.ifnames=0 biosdevname=0 ipv6.disable=1\"/g' /etc/default/grub
#grub2-mkconfig -o /boot/grub2/grub.cfg
dracut --force --add growroot /boot/initramfs-$(uname -r).img
