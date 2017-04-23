FROM openjdk:alpine

LABEL Maintainer="Johandry Amador <ja186051@teradata.com>"
LABEL Description="Presto CLI"
LABEL Version="0.2.0"

ENV PRESTO_VERSION=0.167-t.0.3

# For development and to make it faster, download the tar.gz file and use COPY.
# When ready, it's better to use ADD.
ADD http://teradata-presto.s3.amazonaws.com/presto/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar /usr/local/bin/presto-cli-${PRESTO_VERSION}
# COPY presto-cli-${PRESTO_VERSION}-executable.jar /tmp
RUN chmod 0755 /usr/local/bin/presto-cli-${PRESTO_VERSION} && \
    ln -s /usr/local/bin/presto-cli-${PRESTO_VERSION} /usr/local/bin/presto

# Is an upgrade required? Install Dependencies: less
RUN apk     --no-cache upgrade && \
    apk add --no-cache less

ENTRYPOINT [ "/usr/local/bin/presto" ]
