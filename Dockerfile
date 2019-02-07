FROM jetty:jre8-alpine
COPY *.war /var/lib/jetty/webapps/ROOT.war
