cat << EOT > /etc/yum.repos.d/mongodb-org-3.0.repo
[mongodb-org-3.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.0/x86_64/
gpgcheck=0
enabled=0
EOT
