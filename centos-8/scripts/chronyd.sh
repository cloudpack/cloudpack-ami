#dnf install -y --enablerepo=epel chrony
systemctl enable chronyd.service
CONF=/etc/chrony.conf

sed -i -e '/server /D' -e '/makestep /D' ${CONF}
cat << EOT >> ${CONF}
leapsecmode slew
maxslewrate 83333
smoothtime 400 0.001 leaponly
makestep 600 30
server 169.254.169.123 prefer iburst
EOT
