#!/usr/bin/env python
"""
This file is meant to be used in the CLI, for example:

    COMPOSE_PROJECT_NAME=colorescience COMPOSE_APP_HOSTS=cs.docker bridge/build.py apps/colorescience/services.yaml
    COMPOSE_PROJECT_NAME=amity COMPOSE_APP_TYPE=bolt bridge/build.py apps/default/services.yaml apps/amity/docker-compose.yml
"""

import os
import sys
import bridge

class BuildImageException(Exception):
    pass

if __name__ == '__main__':
    try:
        if len(sys.argv) < 3:
            raise BuildImageException('Please supply filename to parse as argument')

        filename = sys.argv[1]
        output = sys.argv[2] if len(sys.argv) > 2 else None
        result = bridge.build(filename, os.environ, output)

        if not result:
            raise BuildImageException('Error building docker-compose file')

        print('File written: ' + result)
    except BuildImageException as e:
        sys.exit('Error updating image: ' + str(e))
