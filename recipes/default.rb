
include_recipe "#{cookbook_name}::install_user"
include_recipe "#{cookbook_name}::install_common"
include_recipe "#{cookbook_name}::install_modules"
include_recipe "#{cookbook_name}::install_source"
include_recipe "#{cookbook_name}::install_service"

