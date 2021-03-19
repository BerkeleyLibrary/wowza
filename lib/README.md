# Additional Java libraries

This directory contains additional Java libraries that are copied into 
Wowza's lib directory at build time.

## log4j-layout-template-json-2.14.jar

Wowza 4.8.8.01+ uses log4j2, but log4j2 doesn't ship its JsonTemplateLayout
in the default distribution, so if we want to use it, we have to include it
separately.
