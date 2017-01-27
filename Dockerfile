#Base Image
FROM ubuntu:16.04

#Set the maintainer
MAINTAINER chris.krisdan@google.com

#Install packages 
RUN apt-get update && apt-get install -y curl build-essential supervisor
	
# Create Directory for supervisor logs
RUN mkdir -p /var/log/supervisor

#Copy the supervisor configuration file into the image
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#############################################
### Install Oracle JDK 8 manually - START ###
#############################################

#Untar the jdk into the /opt/ directory
ADD jdk1.8.0_121.tar.gz /opt/

# Set jdk 8 as the default version and set the $PATH variable
RUN update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_121/bin/java 100 \
 	&& update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_121/bin/javac 100 \
 	&& java -version

#############################################
### Install Oracle JDK 8 manually - END   ###
#############################################



############################################################
###  Install Android Command Line tools securely - START ###
############################################################

#Untar Android tools into the /opt/ directory
ADD tools.tar.gz /opt/android/

#Set symbolic links to make the sdk and sdk manager executable from anywhere on the system
RUN ln -s /opt/android/tools/android /usr/local/bin/android \
	&& ln -s /opt/android/tools/bin/sdkmanager /usr/local/bin/sdkmanager

#Copy the list of sdk packages to install
COPY sdk-packages /opt/android/tools/sdk-packages.list

#Install SDK packages and agree to the Licence
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | sdkmanager --package_file="/opt/android/tools/sdk-packages.list" --include_obsolete \
    && sdkmanager --list
	
############################################################
###  Install Android Command Line tools securely  - END  ###
############################################################



#########################################
###  Install Node js securely - START ###
#########################################

ADD node-v6.9.4-linux-x64.tar.gz /opt/node/

RUN ln -s /opt/node/node-v6.9.4-linux-x64/bin/npm /usr/local/bin/npm && \
	ln -s /opt/node/node-v6.9.4-linux-x64/bin/node /usr/local/bin/node

# Set the npm prefix to the correct location and update npm
RUN npm config set prefix /usr/local && \
	npm install -g npm

#########################################
###   Install Node js securely  - END ###
#########################################



#########################################
###  Install Cordova securely - START ###
#########################################

#COPY bashrc.txt /root/.bashrc

# Install Cordova Ionic
RUN npm install -g cordova ionic

#########################################
###   Install Cordova securely  - END ###
#########################################



###################################################
###  Install Generator-m-ionic securely - START ###
###################################################

#Install Generator-M-ionic
#RUN npm install --global generator-m-ionic bower yo gulp

###################################################
###   Install Generator-m-ionic securely  - END ###
###################################################


#Make port 3001 on the image available to access the SDK through
EXPOSE 8100

#Create Volume
VOLUME /var/local/app

#Run Supervisor as a process
CMD ["/usr/bin/supervisord"]