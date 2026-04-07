FROM quay.io/keycloak/keycloak:26.1.2

COPY keycloak-theme.jar /opt/keycloak/providers/
COPY keycloak-to-rabbit-3.0.5.jar /opt/keycloak/providers/

RUN /opt/keycloak/bin/kc.sh build
