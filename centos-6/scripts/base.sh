yum -y install epel-release
yum -y update

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` perl
yum -y install cloud-init cloud-utils cloud-utils-growpart lsof dracut-modules-growroot

sed -i.bak 's@\(.*\)name: \(.*\)@\1name: cloudpack@g' /etc/cloud/cloud.cfg
sed -i.bak 's@\(.*\)/mnt\(.*\)@#\1/mnt\2@g' /etc/fstab
rpm -Uvh --force /tmp/bash-4.1.2-33.el6.1cloudpack.x86_64.rpm

# dkms準備
yum -y install dkms
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

cat << EOT >> /etc/yum.conf
exclude=kernel* bash*
EOT
