#!/usr/bin/env bash

echo "Pre-Install common"
sudo yum -y -q install  python3-pip.noarch curl net-tools yum-utils device-mapper-persistent-data lvm2

echo "Adding apt-keys"
curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

echo "Updating apt-get"
sudo yum -y -q update

echo "Installing default-java"
sudo yum -y -q install java-1.8.0-openjdk-devel

echo "Install npm and yarn"
sudo apt-get install -y -q yarn nodejs

echo "Installing git"
sudo yum -y -q install git

echo "Installing git-ftp"
sudo yum -y install git-ftp

echo "Setup for docker installation"
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --enable docker-ce-nightly

echo "Starting docker installation..."
sudo yum -y -q install docker-ce docker-ce-cli containerd.io

echo "Enable and starting Docker"
sudo systemctl start docker

echo "Installing jenkins"
sudo yum -y -q install jenkins
# sed -i 's/HTTP_PORT=8080/HTTP_PORT=8090/g' /etc/default/jenkins
sudo service jenkins start

sleep 1m

echo "Downloading and Installing Maven"
echo "Downloading now ....."
sudo get https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -P /tmp > /dev/null 2>&1

echo "Starting installing..."
sudo tar xf /tmp/apache-maven-*.tar.gz -C /opt > /dev/null 2>&1
sudo ln -s /opt/apache-maven-3.6.0 /opt/maven
echo "export JAVA_HOME=/usr/lib/jvm/default-java" > /etc/profile.d/maven.sh
echo "export M2_HOME=/opt/maven" >> /etc/profile.d/maven.sh
echo "export MAVEN_HOME=/opt/maven" >> /etc/profile.d/maven.sh
echo "export PATH=${M2_HOME}/bin:${PATH}" >> /etc/profile.d/maven.sh
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh
sudo apt install maven > /dev/null 2>&1
echo "DONE with Installation of maven"


echo "Password is:"
JENKINSPWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo $JENKINSPWD

echo "URL address"
URL=$(sudo ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "http://"$URL":8080"