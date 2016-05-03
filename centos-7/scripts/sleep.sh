ping -c 1 www.yahoo.com
while [ $? -ne 0 ];do
	sleep 10
	ping -c 1 www.yahoo.com
done
