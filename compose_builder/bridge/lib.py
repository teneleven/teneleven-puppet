from compose.config import load
from compose.config.config import ConfigFile
from compose.config.config import ConfigDetails
from compose.config.serialize import serialize_config
from compose.config.environment import Environment

import os

def build(filename, env_dict=None, output_path=None):
    """
    Build docker-compose.yml file from services & env.
    """

    path = os.path.dirname(filename)
    conf_file = ConfigFile.from_filename(filename)
    env = Environment(env_dict) if env_dict else None
    conf = load(ConfigDetails(path, [conf_file], env))

    output_path = output_path if output_path else path + '/docker-compose.yml'

    # try to make directory
    if os.path.dirname(output_path):
        os.makedirs(os.path.dirname(output_path))

    out = open(output_path, 'w')
    out.write(serialize_config(conf))
    out.close()

    return output_path

def update_image(filename, new_image, service_name='web'):
    """
    Update service image name to new_image.
    """

    path = os.path.dirname(filename)
    conf_file = ConfigFile.from_filename(filename)
    conf = load(ConfigDetails(path, [conf_file], None))

    # find service
    for i in range(len(conf.services)):
        service = conf.services[i]
        if service['name'] == service_name:
            conf.services[i]['image'] = new_image

            out = open(filename, 'w')
            out.write(serialize_config(conf))
            out.close()

            return filename
