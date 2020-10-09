# http://blog.father.gedow.net/2016/03/15/enhanced-networking/ を参照　多謝
# ixgbevfソースのダウンロード（dkmsの都合で /usr/src である必要アリ）
DRIVER=ixgbevf
PACKAGE=ixgbevf
VERSION=4.8.1
cd /usr/src
#curl -s -O -L https://sourceforge.net/projects/e1000/files/ixgbevf%20stable/${VERSION}/${DRIVER}-${VERSION}.tar.gz
curl -L -o "ixgbevf-${VERSION}.tar.gz" "https://downloads.sourceforge.net/project/e1000/ixgbevf%20stable/${VERSION}/ixgbevf-${VERSION}.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fe1000%2Ffiles%2Fixgbevf%2520stable%2F${VERSION}%2Fixgbevf-${VERSION}.tar.gz%2Fdownload%3Fuse_mirror%3Djaist&ts=`date +%s`"
tar xzf ${DRIVER}-${VERSION}.tar.gz
cd ${DRIVER}-${VERSION}
 
# dkms用の設定
cat <<EOT > dkms.conf
PACKAGE_NAME="${PACKAGE}"
PACKAGE_VERSION="${PACKAGE}"
CLEAN="cd src/; make clean"
MAKE="cd src/; make BUILD_KERNEL=\${kernelver}"
BUILT_MODULE_LOCATION[0]="src/"
BUILT_MODULE_NAME[0]="${PACKAGE}"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="${PACKAGE}"
AUTOINSTALL="yes"
EOT
# インストール
dkms add     -m ${PACKAGE} -v ${VERSION}
dkms build   -m ${PACKAGE} -v ${VERSION}
dkms install -m ${PACKAGE} -v ${VERSION}

dracut --force --regenerate-all
# モジュールが更新されたのを確認                                                
modinfo ${PACKAGE}
