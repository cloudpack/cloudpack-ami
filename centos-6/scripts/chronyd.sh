yum install -y --enablerepo=epel chrony
chkconfig chronyd on

echo "leapsecmode slew" >> /etc/chrony.conf
echo "maxslewrate 1000" >> /etc/chrony.conf
echo "smoothtime 400 0.001 leaponly" >> /etc/chrony.conf

