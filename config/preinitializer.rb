# load config.yml
require 'yaml'
CONFIG = YAML.load(File.read(RAILS_ROOT + "/config/config.yml"))