# =============================================================================
# Target: base
#

FROM wowzamedia/wowza-streaming-engine-linux:4.7.7 AS base

# =============================================================================
# Target: development
#

FROM base AS development
