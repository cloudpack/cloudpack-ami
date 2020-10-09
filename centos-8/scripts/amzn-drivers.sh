# http://blog.father.gedow.net/2016/03/15/enhanced-networking/ を参照　多謝
# amzn-driversソースのダウンロード（dkmsの都合で /usr/src である必要アリ）
DRIVER=amzn-drivers
PACKAGE=ena
VERSION=2.2.11
cd /usr/src
git clone https://github.com/amzn/amzn-drivers
mv ${DRIVER} ${DRIVER}-${VERSION}
cd ${DRIVER}-${VERSION}
 
# dkms用の設定
cat <<EOT > dkms.conf
PACKAGE_NAME="${PACKAGE}"
PACKAGE_VERSION="${VERSION}"
CLEAN="make -C kernel/linux/ena clean"
MAKE="make -C kernel/linux/ena/ BUILD_KERNEL=\${kernelver}"
BUILT_MODULE_NAME[0]="${PACKAGE}"
BUILT_MODULE_LOCATION="kernel/linux/${PACKAGE}"
DEST_MODULE_LOCATION[0]="/updates"
DEST_MODULE_NAME[0]="${PACKAGE}"
AUTOINSTALL="yes"
EOT
# インストール
dkms add     -m ${DRIVER} -v ${VERSION}
dkms build   -m ${DRIVER} -v ${VERSION}
dkms install -m ${DRIVER} -v ${VERSION}

cat << EOT > /etc/dracut.conf.d/nvme.conf
add_drivers+=" nvme "
EOT
dracut --force --regenerate-all
#dracut -v -f
# モジュールが更新されたのを確認                                                
modinfo ${PACKAGE}
