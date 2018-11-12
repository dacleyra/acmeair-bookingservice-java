FROM websphere-liberty:microProfile

# Install opentracing usr feature
#RUN wget -t 10 -x -nd -P /opt/ibm/wlp/usr https://github.com/WASdev/sample.opentracing.zipkintracer/releases/download/1.1/liberty-opentracing-zipkintracer-1.1-sample.zip && cd /opt/ibm/wlp/usr && unzip liberty-opentracing-zipkintracer-1.1-sample.zip && rm liberty-opentracing-zipkintracer-1.1-sample.zip

COPY --chown=1001:0 liberty-opentracing-zipkintracer-1.2-sample.zip /opt/ibm/wlp/usr/liberty-opentracing-zipkintracer-1.2-sample.zip
RUN cd /opt/ibm/wlp/usr && unzip liberty-opentracing-zipkintracer-1.2-sample.zip && rm liberty-opentracing-zipkintracer-1.2-sample.zip

COPY --chown=1001:0 /target/liberty/wlp/usr/servers/defaultServer /config/
COPY --chown=1001:0 src/main/liberty/config/server.xml /config/server.xml
COPY --chown=1001:0 /src/main/liberty/config/jvmbx.options /config/jvm.options
COPY --chown=1001:0 target/acmeair-bookingservice-java-2.0.0-SNAPSHOT.war /config/apps/

# Don't fail on rc 22 feature already installed
RUN installUtility install --acceptLicense apmDataCollector-7.4 && installUtility install --acceptLicense defaultServer || if [ $? -ne 22 ]; then exit $?; fi
RUN /opt/ibm/wlp/usr/extension/liberty_dc/bin/config_liberty_dc.sh -silent /opt/ibm/wlp/usr/extension/liberty_dc/bin/silent_config_liberty_dc.txt

# Upgrade to production license if URL to JAR provided
ARG LICENSE_JAR_URL
RUN \ 
  if [ $LICENSE_JAR_URL ]; then \
    wget $LICENSE_JAR_URL -O /tmp/license.jar \
    && java -jar /tmp/license.jar -acceptLicense /opt/ibm \
    && rm /tmp/license.jar; \
  fi


