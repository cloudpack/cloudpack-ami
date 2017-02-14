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

sed -i.bak 's@\(.*\)name: \(.*\)@\1name: cloudpack@g' /etc/cloud/cloud.cfg

#pip install -U urllib3 urllib3-mock apiclient

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
EOT
