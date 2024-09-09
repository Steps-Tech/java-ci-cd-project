#OS : CentOS-Stream-ec2-9-20221219.0-20230110.0.x86_64-aba856bc-78bf-441c-b25c-980bec33a53f-ami-099eb8ae347032773.4
#New Changes : java-17-openjdk java-17-openjdk-devel required to run Nexus 

#!/bin/bash
yum install java-1.8.0-openjdk.x86_64 wget -y   
dnf -y install java-17-openjdk java-17-openjdk-devel
mkdir -p /opt/nexus/   
mkdir -p /tmp/nexus/                           
cd /tmp/nexus/
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz
sleep 10
EXTOUT=`tar xzvf nexus.tar.gz`
NEXUSDIR=`echo $EXTOUT | cut -d '/' -f1`
sleep 5
rm -rf /tmp/nexus/nexus.tar.gz
cp -r /tmp/nexus/* /opt/nexus/
sleep 5
useradd nexus
chown -R nexus.nexus /opt/nexus 
cat <<EOT>> /etc/systemd/system/nexus.service
[Unit]                                                                          
Description=nexus service                                                       
After=network.target                                                            
                                                                  
[Service]                                                                       
Type=forking                                                                    
LimitNOFILE=65536                                                               
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start                                  
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop                                    
User=nexus                                                                      
Restart=on-abort                                                                
                                                                  
[Install]                                                                       
WantedBy=multi-user.target                                                      

EOT

echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc
systemctl daemon-reload
systemctl start nexus
systemctl enable nexus

###Installation On Ubuntu 22.04 : https://medium.com/@dikkumburage/how-to-install-nexus-repository-on-ubuntu-20-04-lts-4012e23698ad
apt update
apt upgrade
apt install openjdk-8-jre-headless
adduser --disabled-login --no-create-home --gecos "" nexus
cd /opt
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -zxvf latest-unix.tar.gz
mv nexus-3.72.0-04/ nexus
chown -R nexus:nexus /opt/nexus
chown -R nexus:nexus /opt/sonatype-work

vim  /opt/nexus/bin/nexus.rc
     run_as_user="nexus"
mkdir -p /nexus/bin	 
vim /nexus/bin/nexus.vmoptions
     -Xms1024m
	 -Xmx1024m
	 -XX:MaxDirectMemorySize=1024m
	 -XX:LogFile=./sonatype-work/nexus3/log/jvm.log
	 -XX:-OmitStackTraceInFastThrow
	 -Djava.net.preferIPv4Stack=true
	 -Dkaraf.home=.
	 -Dkaraf.base=.
	 -Dkaraf.etc=etc/karaf
	 -Djava.util.logging.config.file=/etc/karaf/java.util.logging.properties
	 -Dkaraf.data=./sonatype-work/nexus3
	 -Dkaraf.log=./sonatype-work/nexus3/log
	 -Djava.io.tmpdir=./sonatype-work/nexus3/tmp
	 

vim /etc/systemd/system/nexus.service
    [Unit]
	Description=nexus service
	After=network.target
	[Service]
	Type=forking
	LimitNOFILE=65536
	ExecStart=/opt/nexus/bin/nexus start
	ExecStop=/opt/nexus/bin/nexus stop
	User=nexus
	Restart=on-abort
	[Install]
	WantedBy=multi-user.target
	
systemctl daemon-reload
systemctl start nexus
systemctl enable nexus
systemctl status nexus
java -version
apt install openjdk-11-jdk -y
systemctl restart nexus
systemctl status nexus
   

