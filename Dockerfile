# =============================================================================
# Target: base
#

FROM wowzamedia/wowza-streaming-engine-linux:4.8.5 AS base

# =============================================================================
# For debugging

RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends \
    curl \
    dnsutils \
    iputils-ping

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

# =============================================================================
# Ports

# Default streaming port
EXPOSE 1935/tcp

# Wowza Streaming Engine API
EXPOSE 8087/tcp

# Wowza Streaming Engine Manager UI
EXPOSE 8088/tcp

# =============================================================================
# Java

# The upstream Wowza image ships with OpenJDK 9.0.4+11, which is not a
# long-term support release and, importantly, doesn't know about containers:
# https://www.wowza.com/community/t/creating-a-production-worthy-docker-image/53957/3
#
# Luckily, Wowza supports manually replacing the JRE:
# https://www.wowza.com/docs/manually-install-and-troubleshoot-java-on-wowza-streaming-engine
#
# (Unfortunately, this by itself isn't enough to get Wowza to properly
# calculate its own max heap size, so we still need to set that explicitly
# in Tune.xml. Possibly a future version of Wowza will be clever enough to
# use -XX:MaxRAMPercentage instead.)

RUN apt-get install -y --no-install-recommends openjdk-11-jre-headless

RUN rm -rf /usr/local/WowzaStreamingEngine/java
RUN ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/local/WowzaStreamingEngine/java

# =============================================================================
# Tests

RUN apt-get install -y --no-install-recommends python3-pip
RUN pip3 install unittest-xml-reporting

COPY --chown=$APP_USER test /opt/app/test

# Put artifacts where Jenkins can get at them
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

# Copy our scripts and configs into the container
COPY --chown=$APP_USER bin /opt/app/bin
COPY --chown=$APP_USER conf /usr/local/WowzaStreamingEngine/conf
COPY --chown=$APP_USER manager/conf /usr/local/WowzaStreamingEngine/manager/conf
COPY --chown=$APP_USER applications /usr/local/WowzaStreamingEngine/applications

# All subsequent commands are executed relative to this directory.
WORKDIR /opt/app

# Run as the wowza user to minimize risk to the host.
USER $APP_USER

# =============================================================================
# Default command

CMD ["/opt/app/bin/docker-entrypoint.sh"]

# =============================================================================
# Target: development

FROM base AS development

# =============================================================================
# Target: production

FROM base AS production
