FROM openjdk:8

RUN wget -q https://services.gradle.org/distributions/gradle-3.3-bin.zip \
    && unzip gradle-3.3-bin.zip -d /opt \
    && rm gradle-3.3-bin.zip
    
RUN wget  -O Dynatrace-OneAgent-Linux-1.125.174.sh "https://efh46650.live.dynatrace.com/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=yVFSemp9QKq7Z-McuTFX9&arch=x86"

RUN wget https://ca.dynatrace.com/dt-root.cert.pem ; ( echo 'Content-Type: multipart/signed; protocol="application/x-pkcs7-signature"; micalg="sha-256"; boundary="--SIGNED-INSTALLER"'; echo ; echo ; echo '----SIGNED-INSTALLER' ; cat Dynatrace-OneAgent-Linux-1.125.174.sh ) | openssl cms -verify -CAfile dt-root.cert.pem > /dev/null

RUN /bin/sh Dynatrace-OneAgent-Linux-1.125.174.sh APP_LOG_CONTENT_ACCESS=1 


ENV GRADLE_HOME /opt/gradle-3.3
ENV PATH $PATH:/opt/gradle-3.3/bin

COPY . .

RUN gradle build

ENV JAVA_OPTS=""

EXPOSE 8080

ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar build/libs/demoapp-0.0.1-SNAPSHOT.jar" ]

