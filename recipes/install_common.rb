# Create an Instance resource
#
nginx_resources_instance 'default' do
  service node['nginx_resources']['service']['name']
  configs node['nginx_resources']['instance']['config']
end

# Default config file fragments
#
nginx_resources_config 'mime_types' do
  category 'config'
  priority '20'
end

nginx_resources_config 'core' do
  category 'config'
  priority '20'
  source   'config/core.conf.erb'
  configs   node['nginx_resources']['core']['config']
end

nginx_resources_config 'custom' do
  category 'config'
  priority '90'
  source   'config/generic.conf.erb'
  configs  node['nginx_resources']['custom']['config']
end

# Default config file includes
#
nginx_resources_config 'health' do
  category 'include'
  configs  node['nginx_resources']['health']['config']
end

# Default virtualhost
#
nginx_resources_site 'default' do
  %w(
    priority
    server_name
    listen
    includes
    root
    locations
    variables
    cookbook
    source
    enabled
  ).each do |key|
    value = node['nginx_resources']['default_site'][key]
    send(key, value) unless value.nil?
  end
end
