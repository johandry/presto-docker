FROM openjdk:alpine

LABEL Maintainer="Johandry Amador <ja186051@teradata.com>"
LABEL Description="Presto Server"
LABEL Version="0.2.0"

ENV PRESTO_VERSION=0.167-t.0.3
# ENV PRESTO_MD5SUM=d96ad91c6325834b8ed610d09af5493e

# For development and to make it faster, download the tar.gz file and use COPY.
# When ready, it's better to use ADD.
ADD http://teradata-presto.s3.amazonaws.com/presto/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz /tmp
# COPY presto-server-${PRESTO_VERSION}.tar.gz /tmp

# Is an upgrade required?
RUN apk --no-cache upgrade

# Dependencies: python > 2.4 and uuidgen (in package util-linux)
RUN apk add --no-cache python py-pip ca-certificates python-dev util-linux && pip install --upgrade pip

# Only if 'presto' user is required, install:
# /usr/sbin/useradd
# /usr/sbin/groupadd

# Copy default Presto configuration files and simple/default connectors
COPY config/* /usr/lib/presto/etc/
COPY catalog/* /usr/lib/presto/etc/catalog/

# Install Presto Server:
WORKDIR /tmp
RUN echo \
  # Untar presto-server
  && tar xzf presto-server-${PRESTO_VERSION}.tar.gz \
  # Create 'presto' user and group:
  # Is this really required in a container? If so, replace them with USER because groupadd and useradd are not available in alpine
  # && getent group presto >/dev/null || /usr/sbin/groupadd -r presto \
  # && getent passwd presto >/dev/null || /usr/sbin/useradd --comment "Presto" -s /sbin/nologin -g presto -r -d /var/lib/presto presto \
  # Create destination directories and link to presto configuration
  && install -d -m=755 /var/lib/presto \
  && install -d -m=755 /var/log/presto \
  # Not required, done with the COPY above
  # && mkdir -p /usr/lib/presto/etc \
  && ln -s /usr/lib/presto/etc /etc/presto \
  # Move directories from untar'd file to /usr/lib/presto
  && mv /tmp/presto-server-${PRESTO_VERSION}/bin /usr/lib/presto \
  # Make sure launcher scripts are executable
  && find /usr/lib/presto/bin -type f -exec chmod 0755 {} \; \
  && mv /tmp/presto-server-${PRESTO_VERSION}/lib /usr/lib/presto \
  && mv /tmp/presto-server-${PRESTO_VERSION}/plugin /usr/lib/presto/lib \
  && mkdir -p /usr/shared/doc/presto \
  && mv /tmp/presto-server-${PRESTO_VERSION}/README.txt /usr/shared/doc/presto \
  && rm -rf presto-server-${PRESTO_VERSION} presto-server-${PRESTO_VERSION}.tar.gz \
  # Write the JAVA_HOME to /etc/presto/env.sh
  && echo "JAVA8_HOME=${JAVA_HOME}" > /etc/presto/env.sh \
  # Required only if presto user was created. Make sure those directory exists.
  # && chown -R presto:presto /var/lib/presto \
  # && chown -R presto:presto /var/log/presto \
  # && chown -R presto:presto /etc/presto \
  && echo

COPY etc/init.d/presto /etc/init.d/presto
RUN chmod 0755 /etc/init.d/presto
COPY entrypoint.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/entrypoint.sh
COPY startup.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/startup.sh

EXPOSE 8080
WORKDIR /etc/presto

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD /usr/local/bin/startup.sh
