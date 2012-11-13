# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HrSystem::Application.initialize!
$CLIENT_EXPIRE_MINUTES = 60
require 'class_ext'
require 'sql_logic'
require 'file_manager'