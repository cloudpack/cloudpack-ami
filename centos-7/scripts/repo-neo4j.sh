cat << EOT >  /etc/yum.repos.d/neo4j.repo
[neo4j]
name=Neo4j Yum Repo
baseurl=http://yum.neo4j.org
enabled=1
gpgcheck=1
EOT
