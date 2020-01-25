FROM maven

EXPOSE 8080

COPY target/*.jar service.jar


ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","service.jar"]
