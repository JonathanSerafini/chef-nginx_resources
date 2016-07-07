# Create an Instance resource
#
instance = nginx_resources_instance 'default' do
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
  configs node['nginx_resources']['core']['config']
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
  self.class.properties.each do |key, _|
    value = node['nginx_resources']['site']['default_site'][key]
    send(key, value) unless value.nil?
  end
end

# Install the service definition, source an update cause a restart
#
template 'nginx_service' do
  init_style = node['nginx_resources']['service']['init_style']

  variables({
    'sbin_path' => instance.sbin_path,
    'conf_path' => instance.conf_path,
    'pid_path'  => instance.pid_path,
    'configs'   => node['nginx_resources'].fetch(init_style, {}).to_hash
  })

  case init_style
  when 'upstart'
    path    '/etc/init/nginx.conf'
    source  'nginx-upstart.conf.erb'
  else raise NotImplementedError.new('the nginx init_style is not supported')
  end

  only_if do
    node['nginx_resources']['service']['managed']
  end
end
