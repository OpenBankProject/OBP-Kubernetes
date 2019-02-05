FROM jetty:jre8-alpine
USER root
RUN apk --no-cache add zip
USER jetty
COPY *.war /var/lib/jetty/webapps/ROOT.war
COPY injectdatabase.sh /var/lib/jetty/webapps/injectdatabase.sh
ENTRYPOINT ["/var/lib/jetty/webapps/injectdatabase.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]
