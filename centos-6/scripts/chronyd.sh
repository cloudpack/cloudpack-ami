yum install -y --enablerepo=epel chrony
chkconfig chronyd on
CONF=/etc/chrony.conf

echo "leapsecmode slew" >> ${CONF}
echo "maxslewrate 1000" >> ${CONF}
echo "smoothtime 400 0.001 leaponly" >> ${CONF}
sed -e '/server /D' ${CONF}
echo "server 169.254.169.123 prefer iburst" >> ${CONF}
