AWSZIP=awscliv2.zip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ${AWSZIP}
unzip ${AWSZIP}
sudo ./aws/install
/usr/local/bin/aws --version
rm ${AWSZIP}
rm -rf aws/

