yum -y install --enablerepo=epel,extras \
	cloud-init \
	cloud-utils \
	cloud-utils-growpart \
	python-pip
pip install -U urllib3 pip
pip install -U awscli

chkconfig --add cloud-init-local
chkconfig --add cloud-init
chkconfig --add cloud-config
chkconfig --add cloud-final

sed -i.bak 's@\(\s\)name: \(.*\)@\1name: cloudpack@g' /etc/cloud/cloud.cfg

cat << EOT >> /etc/cloud/cloud.cfg.d/99-cloudpack.cfg
locale: en_US.UTF-8
datasource_list: [Ec2]
datasource:
  Ec2:
    metadata_urls: ['http://169.254.169.254']

fs_setup:
  - label: ephemeral1,
    filesystem: ext3
    extra_opts: [ "-E", "nodiscard" ]
    device: ephemeral1
    partition: auto

mounts:
  - [ /dev/xvdc, /mnt/ephemeral/1 ]

bootcmd:
  - [ cloud-init-per, once, grow_pv, growpart, /dev/xvda, 2 ]
  - [ cloud-init-per, once, reboot, reboot ]                                    
  - [ cloud-init-per, once, reboot_sleep, sleep, 1m ]
  - [ cloud-init-per, once, grow_VG, pvresize, /dev/xvda2 ]
  - [ cloud-init-per, once, grow_LV, lvextend, -l, +100%FREE, /dev/mapper/vg_root-lv_root ]
  - [ cloud-init-per, once, resize2fs_system, resize2fs, /dev/mapper/vg_root-lv_root ]
EOT

