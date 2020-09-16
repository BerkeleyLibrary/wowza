# =============================================================================
# Target: base
#

FROM wowzamedia/wowza-streaming-engine-linux:4.8.5 AS base

# =============================================================================
# For debugging

RUN apt-get update -qq
RUN apt-get install -y \
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
    chown -R $APP_USER:$APP_USER /usr/local/WowzaStreamingEngine && \
    chown -R $APP_USER:$APP_USER /home/wowza

# =============================================================================
# Ports

# Default streaming port
EXPOSE 1935/tcp

# Wowza Streaming Engine API
EXPOSE 8087/tcp

# Wowza Streaming Engine Manager UI
EXPOSE 8088/tcp

# =============================================================================
# Local config

COPY --chown=$APP_USER bin /home/wowza/bin
COPY --chown=$APP_USER conf /usr/local/WowzaStreamingEngine/conf
COPY --chown=$APP_USER applications /usr/local/WowzaStreamingEngine/applications
RUN find /usr/local/WowzaStreamingEngine/applications -name .keep -delete

# =============================================================================
# Entrypoint

ENTRYPOINT ["/home/wowza/bin/docker-entrypoint-server.sh"]

# =============================================================================
# Target: development
#

FROM base AS development
