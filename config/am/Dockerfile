#FROM forgerock-docker-public.bintray.io/forgerock/am:7.0.0-SNAPSHOT
# todo - replace with FBC

#FROM gcr.io/forgerock-io/am:7.0.0
# This is an experimental FBC image
FROM gcr.io/engineering-devops/am:7.0-FBC-test

# This is where you would copy in custom web.xml, add jar files, javascript, etc.
# The AM war is expanded to /usr/local/tomcat/webapps/am

# COPY web.xml /usr/local/tomcat/webapps/am/WEB-INF

COPY openam /home/forgerock/openam