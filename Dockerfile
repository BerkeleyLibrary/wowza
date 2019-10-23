# =============================================================================
# Target: base
#

FROM wowzamedia/wowza-streaming-engine-linux:4.7.7 AS base

# =============================================================================
# Global configuration

# Set unique uid/gid for wowza user/group
# (base image defaults wowza user/group to uid/gid 1000)
ENV APP_USER=wowza
ENV APP_UID=40041

RUN usermod -u $APP_UID $APP_USER && \
    groupmod -g $APP_UID $APP_USER && \
    chown -R $APP_USER:$APP_USER /usr/local && \
    chown -R $APP_USER:$APP_USER /home/wowza

ENTRYPOINT ["/sbin/entrypoint.sh"]

# =============================================================================
# Target: development
#

FROM base AS development
