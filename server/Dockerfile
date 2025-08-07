FROM openjdk:8-jdk-slim AS builder

# Accept build arguments
ARG DATABASE_HOST
ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASSWORD

# Set as environment variables for the build process
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USER=$DATABASE_USER
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD

RUN apt-get update && apt-get install -y \
    ant \
    wget \
    maven \
    && rm -rf /var/lib/apt/lists/*

COPY pom.xml /server/pom.xml
WORKDIR /server
RUN mvn -f /server/pom.xml dependency:copy-dependencies -DoutputDirectory=/server/lib

COPY . /server

RUN ant

FROM openjdk:8-jre-slim

COPY --from=builder /server/red5.jar .
COPY --from=builder /server/red5/conf conf
COPY --from=builder /server/red5/webapps webapps

# COPY --from=builder /server/lib/activation-*.jar lib
COPY --from=builder /server/lib/animal-sniffer-annotations-*.jar lib
COPY --from=builder /server/lib/annotations-api-*.jar lib
# COPY --from=builder /server/lib/ant-*.jar lib
# COPY --from=builder /server/lib/ant-launcher-*.jar lib
COPY --from=builder /server/lib/antlr-*.jar lib
COPY --from=builder /server/lib/aopalliance-*.jar lib
COPY --from=builder /server/lib/asm-*.jar lib
# COPY --from=builder /server/lib/avalon-framework-*.jar lib
COPY --from=builder /server/lib/catalina-*.jar lib
COPY --from=builder /server/lib/cglib-*.jar lib
# COPY --from=builder /server/lib/checker-qual-*.jar lib
COPY --from=builder /server/lib/commons-beanutils-*.jar lib
COPY --from=builder /server/lib/commons-codec-*.jar lib
COPY --from=builder /server/lib/commons-collections-*.jar lib
COPY --from=builder /server/lib/commons-httpclient-*.jar lib
COPY --from=builder /server/lib/commons-lang-*.jar lib
COPY --from=builder /server/lib/commons-logging-*.jar lib
COPY --from=builder /server/lib/dom4j-*.jar lib
COPY --from=builder /server/lib/ecj-*.jar lib
COPY --from=builder /server/lib/ehcache-*.jar lib
COPY --from=builder /server/lib/el-api-*.jar lib
# COPY --from=builder /server/lib/error_prone_annotations-*.jar lib
# COPY --from=builder /server/lib/failureaccess-*.jar lib
COPY --from=builder /server/lib/freemarker-*.jar lib
# COPY --from=builder /server/lib/google-java-format-*.jar lib
# COPY --from=builder /server/lib/groovy-all-*.jar lib
COPY --from=builder /server/lib/guava-*.jar lib
COPY --from=builder /server/lib/hibernate-commons-annotations-*.jar lib
COPY --from=builder /server/lib/hibernate-core-*.jar lib
COPY --from=builder /server/lib/hibernate-entitymanager-*.jar lib
COPY --from=builder /server/lib/hibernate-jpa-*.jar lib
COPY --from=builder /server/lib/hibernate-tools-*.jar lib
COPY --from=builder /server/lib/hibernate-validator-*.jar lib
COPY --from=builder /server/lib/hibernate-c3p0-*.jar lib
# COPY --from=builder /server/lib/j2objc-annotations-*.jar lib
COPY --from=builder /server/lib/jasper-*.jar lib
COPY --from=builder /server/lib/jasper-el-*.jar lib
# COPY --from=builder /server/lib/jasper-jdt-*.jar lib
# COPY --from=builder /server/lib/javac-shaded-*.jar lib
COPY --from=builder /server/lib/javassist-*.jar lib
# COPY --from=builder /server/lib/javax.transaction-api-*.jar lib
COPY --from=builder /server/lib/jcl104-over-slf4j-*.jar lib
COPY --from=builder /server/lib/jetty-*.jar lib
COPY --from=builder /server/lib/jetty-util-*.jar lib
COPY --from=builder /server/lib/jmxtools-*.jar lib
COPY --from=builder /server/lib/jsp-api-*.jar lib
COPY --from=builder /server/lib/jsr305-*.jar lib
COPY --from=builder /server/lib/jta-*.jar lib
COPY --from=builder /server/lib/juli-*.jar lib
# COPY --from=builder /server/lib/junit-*.jar lib
# COPY --from=builder /server/lib/jython-*.jar lib
# COPY --from=builder /server/lib/listenablefuture-*.jar lib
COPY --from=builder /server/lib/log4j-*.jar lib
COPY --from=builder /server/lib/log4j-over-slf4j-*.jar lib
COPY --from=builder /server/lib/logback-classic-*.jar lib
COPY --from=builder /server/lib/logback-core-*.jar lib
COPY --from=builder /server/lib/logkit-*.jar lib
COPY --from=builder /server/lib/mail-*.jar lib
COPY --from=builder /server/lib/mina-core-*.jar lib
COPY --from=builder /server/lib/mina-filter-ssl-*.jar lib
COPY --from=builder /server/lib/mina-integration-jmx-*.jar lib
COPY --from=builder /server/lib/mina-integration-spring-*.jar lib
COPY --from=builder /server/lib/mysql-connector-java-*.jar lib
COPY --from=builder /server/lib/quartz-*.jar lib
COPY --from=builder /server/lib/servlet-api-*.jar lib
COPY --from=builder /server/lib/simple-xml-*.jar lib
COPY --from=builder /server/lib/slf4j-api-*.jar lib
COPY --from=builder /server/lib/spring-beans-*.jar lib
COPY --from=builder /server/lib/spring-context-*.jar lib
COPY --from=builder /server/lib/spring-core-*.jar lib
COPY --from=builder /server/lib/spring-support-*.jar lib
COPY --from=builder /server/lib/spring-web-*.jar lib
COPY --from=builder /server/lib/stax-*.jar lib
COPY --from=builder /server/lib/stax-api-*.jar lib
# COPY --from=builder /server/lib/tools-*.jar lib
COPY --from=builder /server/lib/whirlycache-*.jar lib
COPY --from=builder /server/lib/ws-commons-util-*.jar lib
COPY --from=builder /server/lib/xercesImpl-*.jar lib
COPY --from=builder /server/lib/xml-apis-*.jar lib
COPY --from=builder /server/lib/xmlrpc-client-*.jar lib
COPY --from=builder /server/lib/xmlrpc-common-*.jar lib
COPY --from=builder /server/lib/xmlrpc-server-*.jar lib
COPY --from=builder /server/lib/xpp3-*.jar lib
COPY --from=builder /server/lib/c3p0-*.jar lib
COPY --from=builder /server/lib/mchange-commons-java-*.jar lib

CMD ["java", "-Djava.security.manager", "-Djava.security.policy=conf/red5.policy", "-cp", "red5.jar:conf:lib/*:$CLASSPATH", "org.red5.server.Standalone"]