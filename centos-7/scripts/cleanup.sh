# Inspired from http://blog.suz-lab.com/2013/01/amicentos6update.html
yum -y clean all
rm -rf /tmp/*.rpm
rm -rf /tmp/rpsxps
rm -f /etc/ssh/ssh_host_*
rm -rf /var/lib/cloud/*
rm -rf /tmp/VBoxGuestAdditions*.iso
rm -rf /tmp/.vbox_version
rm /var/log/vboxadd-install.log
rm -rf /tmp/rubygems-*
rm /home/cloudpack/.vbox_version
cd /var/log
ls -F /var/log | grep -v / | xargs -L1 cp /dev/null
find /var/log/ -type f -name \*log | xargs -L1 cp /dev/null
for toremove in /var/log/audit/audit.log /root/.ssh/authorized_keys /root/.bash_history /home/cloudpack/.ssh/authorized_keys /home/cloudpack/.bash_history;do
	if [ -f ${toremove} ]; then cp /dev/null ${toremove};fi
done
exit 0
