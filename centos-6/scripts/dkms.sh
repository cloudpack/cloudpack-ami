yum -y install gcc make gcc-c++ kernel-devel-`uname -r` perl
yum -y install --enablerepo=epel dkms

# http://blog.father.gedow.net/2016/03/15/enhanced-networking/ を参照　多謝
# ixgbevfソースのダウンロード（dkmsの都合で /usr/src である必要アリ）
cd /usr/src
curl -s -O -L https://sourceforge.net/projects/e1000/files/ixgbevf%20stable/4.0.3/ixgbevf-4.0.3.tar.gz
tar xzf ixgbevf-4.0.3.tar.gz
cd ixgbevf-4.0.3
 
# dkms用の設定
cat <<'EOT'> dkms.conf
PACKAGE_NAME="ixgbevf"
PACKAGE_VERSION="4.0.3"
CLEAN="cd src/; make clean"
MAKE="cd src/; make BUILD_KERNEL=${kernelver}"
BUILT_MODULE_LOCATION[0]="src/"
BUILT_MODULE_NAME[0]="ixgbevf"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="ixgbevf"
AUTOINSTALL="yes"
EOT
# インストール
dkms add     -m ixgbevf -v 4.0.3
dkms build   -m ixgbevf -v 4.0.3
dkms install -m ixgbevf -v 4.0.3

# モジュールが更新されたのを確認                                                
modinfo ixgbevf       
