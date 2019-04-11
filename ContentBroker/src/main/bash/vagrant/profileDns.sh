#!/bin/bash
#export M2_HOME=/usr/local/maven
#export PATH=${M2_HOME}/bin:/ci/iRODS/clients/icommands/bin:${PATH}
#export PATH=${M2_HOME}/bin:${PATH}


host=localhost
port=3126
user=
password=

#export HTTP_PROXY="http://$user:$password@$host:$port"
#export HTTPS_PROXY="https://$user:$password@$host:$port"

#export no_proxy="127.0.0.1,localhost"
#export JAVA_OPTS=" -Dhttps.proxyHost=$host -Dhttps.proxyPort=$port -Dhttps.proxyUser=$user -Dhttps.proxyPassword=$password -Dhttp.proxyHost=$host -Dhttp.proxyPort=$port -Dhttp.proxyUser=$user -Dhttp.proxyPassword=$password -Dhttp.nonProxyHosts='localhost|127.0.0.1'"

#export GRAILS_OPTS=$JAVA_OPTS
#export JAVA_HOME=/usr/java/jdk1.6.0_45/
#export JAVA_HOME=/usr/java/jdk1.8.0_25/
export FEDORA_HOME=/ci/fedora
export CATALINA_HOME=/usr/share/tomcat
export BUILD_NUMBER=123
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=256m"

umask 002
