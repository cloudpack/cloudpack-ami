date > /etc/cloudpack_box_build_time

mkdir -pm 700 /home/cloudpack/.ssh
curl -L https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/cloudpack/.ssh/authorized_keys
chmod 0600 /home/cloudpack/.ssh/authorized_keys
chown -R cloudpack:cloudpack /home/cloudpack/.ssh
