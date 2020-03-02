FROM eu.gcr.io/larkworthy-tester/camunda/camunda-bpm-platform:7.12.0
# https://forum.camunda.org/t/apt-get-is-missing-on-camunda-bpm-platform-7-9-0-image/7789
USER root 
RUN apk add --no-cache wget
USER camunda
RUN rm /camunda/lib/postgresql-9.3-1102-jdbc4.jar 
RUN wget --directory-prefix=/camunda/lib https://github.com/GoogleCloudPlatform/cloud-sql-jdbc-socket-factory/releases/download/v1.0.15/postgres-socket-factory-1.0.15-jar-with-driver-and-dependencies.jar
