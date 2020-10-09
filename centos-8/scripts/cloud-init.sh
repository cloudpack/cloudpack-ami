dnf -y install --enablerepo=epel \
	cloud-init \
	cloud-utils-growpart \
	python38 \
	python38-pip \
	python3-boto3
#pip3.8 install -U awscli
#dnf -y install aws-cli

systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service

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

runcmd:
  - [ cloud-init-per, once, grow_sd,   growpart,   /dev/xvda, 2 ]
  - [ cloud-init-per, once, grow_nvme,   growpart,   /dev/nvme0n1, 2 ]
  - [ cloud-init-per, once, pv_sd,   pvresize,   /dev/xvda2 ]
  - [ cloud-init-per, once, pv_nvme,   pvresize,   /dev/nvme0n1p2 ]
  - [ cloud-init-per, once, grow_LV,   lvextend,   -l, +100%FREE, /dev/mapper/vg_root-lv_root ]
  - [ cloud-init-per, once, grow_fs,   xfs_growfs, /dev/mapper/vg_root-lv_root ]
EOT
