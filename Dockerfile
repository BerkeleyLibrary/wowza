# =============================================================================
# Target: base
#

FROM wowzamedia/wowza-streaming-engine-linux:4.9.6 AS base

# =============================================================================
# Ports

# Default streaming port
EXPOSE 1935/tcp

# Wowza Streaming Engine API
EXPOSE 8087/tcp

# Wowza Streaming Engine Manager UI
EXPOSE 8088/tcp

# =============================================================================
# apt setup

RUN apt-get update -qq

# =============================================================================
# For debugging

RUN apt-get install -y --no-install-recommends \
    curl \
    dnsutils \
    gettext \
    iputils-ping

# =============================================================================
# Java

# The upstream Wowza image may ship with an outdated OpenJDK, and
# previously (even as of 4.8.25) did not include an LTS release or
# one that was aware of containers.
#
# Luckily, Wowza supports manually replacing the JRE:
# https://www.wowza.com/docs/manually-install-and-troubleshoot-java-on-wowza-streaming-engine
# ... so this updates to the latest version of OpenJDK 21 (LTS).
#
# (Unfortunately, this by itself isn't enough to get Wowza to properly
# calculate its own max heap size, so we still need to set that explicitly
# in Tune.xml. Possibly a future version of Wowza will be clever enough to
# use -XX:MaxRAMPercentage instead.)

RUN apt-get install -y --no-install-recommends openjdk-21-jre-headless

RUN rm -rf /usr/local/WowzaStreamingEngine/java

# for some reason, OpenJDK's default directory includes the architecture
# name and does not symlink it to something more straightforward like
# /usr/lib/jvm/java-21-openjdk so we have to detect the architecture

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) ln -s "/usr/lib/jvm/java-21-openjdk-${arch}" /usr/local/WowzaStreamingEngine/java

# =============================================================================
# Global configuration

# Set unique uid/gid for wowza user/group
# (base image defaults wowza user/group to uid/gid 1000)
ENV APP_USER=wowza
ENV APP_UID=40041

RUN usermod -u $APP_UID $APP_USER && \
    groupmod -g $APP_UID $APP_USER && \
    mkdir -p /opt/app && \
    chown -R $APP_USER:$APP_USER /opt/app

# transfer now-orphaned files to new wowza user (-h to chown symlinks)
RUN find / -xdev -nouser -exec chown -h $APP_USER:$APP_USER {} \;

# set variables to be used by envsubst to overwrite the default wowza config
ENV SUPERVISORD_PID_FILE=/tmp/supervisord.pid
ENV SUPERVISORD_SOCKET_FILE=/tmp/supervisor.sock

# =============================================================================
# Set working directory

WORKDIR /opt/app

# =============================================================================
# Tests

RUN apt-get install -y --no-install-recommends python3-pip python3-venv
RUN python3 -m venv venv
RUN venv/bin/pip3 install unittest-xml-reporting

COPY --chown=$APP_USER test /opt/app/test

# Put artifacts where Github Actions can get at them
RUN mkdir /opt/app/artifacts && \
    chown $APP_USER:$APP_USER /opt/app/artifacts

# =============================================================================
# Local config

# Delete default applications, which we don't use
RUN for app in vod live; \
    do \
        rm -r /usr/local/WowzaStreamingEngine/applications/${app}; \
        rm -r /usr/local/WowzaStreamingEngine/conf/${app}; \
    done

# Copy our scripts, configs, templates, etc. into the container
COPY --chown=$APP_USER WowzaStreamingEngine /usr/local/WowzaStreamingEngine
COPY --chown=$APP_USER log4j-templates /opt/app/log4j-templates
COPY --chown=$APP_USER etc_templates /opt/app/etc_templates
COPY --chown=$APP_USER bin /opt/app/bin

# =============================================================================
# Additional Java libraries

# Install zip, temporarily
RUN apt-get install -y --no-install-recommends zip

# ==============================
# Server

# The server will load classes from any JAR under /usr/local/WowzaStreamingEngine/lib,
# so we can just symlink our JARs in there

COPY --chown=$APP_USER lib-ucblit /opt/app/lib
RUN ln -s /opt/app/lib/*.jar /usr/local/WowzaStreamingEngine/lib

# ==============================
# Manager

# The manager uses an embedded Tomcat, which will only load classes from WMSManager.war,
# so we have to use `zip` to inject the JARs into the WAR file

# Create a fake WEB-INF/lib directory (actually a symlink to /opt/app/lib),
# since `zip` won't let us specify paths
RUN mkdir /opt/app/WEB-INF && \
    ln -s /opt/app/lib /opt/app/WEB-INF/lib

# Add the JARs under the fake WEB-INF/lib to the WEB-INF/lib directory in the WAR
RUN zip /usr/local/WowzaStreamingEngine/manager/lib/WMSManager.war WEB-INF/lib/*.jar

# Remove the fake WEB-INF/lib directory
RUN rm -r /opt/app/WEB-INF

# Uninstall zip
RUN apt-get remove -y zip

# =============================================================================
# Unlike most of our containers, this container starts as root as privileges
# are dropped by supervisord instead of setting the `USER` set in the
# Dockerfile.

# =============================================================================
# Default command

ENTRYPOINT ["/opt/app/bin/docker-entrypoint.sh"]
