cat << EOT >> /etc/profile.d/motd.sh
CURL_CMD="curl --max-time 2 --connect-timeout 2 -s"
echo "####"
echo -e "#### You have logged in to \e[1mlocalhost.localdomain\e[m as \e[1m\$(id -n -u)\e[m successfully."
InstanceID=\$( \${CURL_CMD} 169.254.169.254/latest/meta-data/instance-id)
if [ \$? -eq 0 ]; then
	echo -e "#### This server is running on \e[1m\e[33mAWS\e[m."
	echo "####   Instance ID:       \$( \${CURL_CMD} 169.254.169.254/latest/meta-data/instance-id)"
	echo "####   Instance Type:     \$( \${CURL_CMD} 169.254.169.254/latest/meta-data/instance-type)"
	echo "####   Availability Zone: \$( \${CURL_CMD} 169.254.169.254/latest/meta-data/placement/availability-zone)"
	echo "####   Private IP:        \$( \${CURL_CMD} 169.254.169.254/latest/meta-data/local-ipv4)"
	public_ip=\$( \${CURL_CMD} 169.254.169.254/latest/meta-data/public-ipv4 | head -n 1 | grep -e "^[^<]")
	echo "####   Public IP:         \$public_ip"
else
	echo "####   Private IP:        \$(/sbin/ip -f inet addr show | gawk '\$0 ~ /inet/ {print \$2}'| grep -v "127.0.0.1")"
fi
echo "####"
EOT

cat << EOT >> /etc/profile.d/bash_completion.sh
# history にコマンド実行時刻を記録する
HISTTIMEFORMAT='%Y-%m-%dT%T%z '
HISTSIZE=1000000
EOT

rpm -Uvh --force /tmp/bash-*.rpm
