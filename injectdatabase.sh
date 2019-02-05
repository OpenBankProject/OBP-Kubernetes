#! /bin/sh

if [ -z $DB_USER ] || [ -z $DB_PASS ] || [ -z $DB_NAME ] || [ -z $DB_HOST ]
then
    echo "\$DB_USER and/or \$DB_PASS not set."
else

    #TODO Obsolete this script by setting these
    # env vars via System.getenv() in client code.

    unzip /var/lib/jetty/webapps/ROOT.war -d /var/lib/jetty/webapps
    # Enable postgres
    sed -i 's/#db.driver=org.postgresql.Driver/db.driver=org.postgresql.Driver/g' /var/lib/jetty/webapps/WEB-INF/classes/props/default.props
    # Connection string
    sed -i 's/#db.url=jdbc:postgresql/db.url=jdbc:postgresql/g' /var/lib/jetty/webapps/WEB-INF/classes/props/default.props

    # Inject postgres hostname
    sed -i 's/postgresql:\/\/localhost/postgresql:\/\/'"$DB_HOST"'/g' /var/lib/jetty/webapps/WEB-INF/classes/props/default.props
    # Inject db name
    sed -i 's/dbname/'"$DB_NAME"'/g' /var/lib/jetty/webapps/WEB-INF/classes/props/default.props
    # Inject db username
    sed -i 's/dbusername/'"$DB_USER"'/g' /var/lib/jetty/webapps/WEB-INF/classes/props/default.props
    # Inject db password
    sed -i 's/&password=thepassword/\&password='"$DB_PASS"'/g' /var/lib/jetty/webapps/WEB-INF/classes/props/default.props
    # Remove original war file
    rm /var/lib/jetty/webapps/*.war
    # Repackage war file
    #jar -cvf /var/lib/jetty/webapps/ROOT.war /var/lib/jetty/webapps/*
    cd /var/lib/jetty/webapps/
    zip -r /var/lib/jetty/webapps/ROOT.war ./*
    cd -
fi

#Call original jetty:jre8-alpine entrypoint so it does what it needs to do
/docker-entrypoint.sh
