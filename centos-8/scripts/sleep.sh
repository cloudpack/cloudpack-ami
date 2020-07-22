IFCFG=/etc/sysconfig/network-scripts/ifcfg-eth0
sed -i -e 's:.*PEERDNS=.*::g' -e 's:^\(NM_CONTROLLED=.*\):#\1:g' ${IFCFG}
echo "PEERDNS=yes" >> ${IFCFG}
systemctl restart network

ping -c 1 www.yahoo.com
while [ $? -ne 0 ];do
	sleep 10
	ping -c 1 www.yahoo.com
done
