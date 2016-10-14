HOSTNAME=`hostname -f`
FILENAME=/etc/yum.repos.d/basho.repo
OS=el
DIST=6
PACKAGE_CLOUD_RIAK_DIR=https://packagecloud.io/install/repositories/basho/riak
curl -s "${PACKAGE_CLOUD_RIAK_DIR}/config_file.repo?os=${OS}&dist=${DIST}&name=${HOSTNAME}" | sed 's:enabled=.*:enabled=0:' > $FILENAME
