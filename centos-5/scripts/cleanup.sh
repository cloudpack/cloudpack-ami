yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso
rm -rf /tmp/rubygems-*

# Inspired from http://blog.suz-lab.com/2013/01/amicentos6update.html
yum clean all
rm -f /etc/ssh/ssh_host_*
rm -rf /var/lib/cloud
ls -F /var/log | grep -v / | xargs -L1 cp /dev/null
find /var/log/ -type f -name \*log | xargs -L1 cp /dev/null
cp /dev/null /var/log/audit/audit.log
cp /dev/null /root/.ssh/authorized_keys
cp /dev/null /root/.bash_history
cp /dev/null /home/cloudpack/.ssh/authorized_keys
cp /dev/null /home/cloudpack/.bash_history
