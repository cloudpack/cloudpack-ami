yum -y install epel-release
sed -i 's:enabled=.*:enabled=0:' /etc/yum.repos.d/epel*.repo
yum -y update

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` perl
yum -y install --enablerepo=epel \
	cloud-init \
	cloud-utils \
	cloud-utils-growpart \
	lsof \
	dkms \
	python-pip
pip install -U urllib3 pip
pip install -U awscli

sed -i.bak 's@\(.*\)name: \(.*\)@\1name: cloudpack@g' /etc/cloud/cloud.cfg
sed -i.bak 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' /etc/fstab
dracut --force --add growroot /boot/initramfs-$(uname -r).img

systemctl enable NetworkManager-wait-online.service
systemctl disable wpa_supplicant.service
systemctl disable firewalld.service
systemctl disable kdump.service
systemctl disable sendmail.service

# http://blog.father.gedow.net/2016/03/15/enhanced-networking/ を参照　多謝
# ixgbevfソースのダウンロード（dkmsの都合で /usr/src である必要アリ）
cd /usr/src
curl -O -L http://downloads.sourceforge.net/project/e1000/ixgbevf%20stable/3.1.2/ixgbevf-3.1.2.tar.gz
tar xzf ixgbevf-3.1.2.tar.gz
cd ixgbevf-3.1.2
 
# dkms用の設定
cat <<'EOT' > dkms.conf
PACKAGE_NAME="ixgbevf"
PACKAGE_VERSION="3.1.2"
CLEAN="cd src/; make clean"
MAKE="cd src/; make BUILD_KERNEL=${kernelver}"
BUILT_MODULE_LOCATION[0]="src/"
BUILT_MODULE_NAME[0]="ixgbevf"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="ixgbevf"
AUTOINSTALL="yes"
EOT
# インストール
dkms add     -m ixgbevf -v 3.1.2
dkms build   -m ixgbevf -v 3.1.2
dkms install -m ixgbevf -v 3.1.2
 
# モジュールが更新されたのを確認
modinfo ixgbevf
