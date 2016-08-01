#!/usr/bin/env python
"""
This file is meant to be used in the CLI, after "build.py", in order to update the docker-compose image name.
"""

import os
import sys
import bridge

class UpdateImageException(Exception):
    pass

if __name__ == '__main__':
    try:
        if len(sys.argv) < 3:
            raise UpdateImageException('Please supply filename to parse as argument')

        filename = sys.argv[1]
        new_image = sys.argv[2]
        result = update_image(filename, new_image)

        if not result:
            raise UpdateImageException('Error building docker-compose file')

        print('File written: ' + result)
    except UpdateImageException as e:
        sys.exit('Error updating image: ' + str(e))
