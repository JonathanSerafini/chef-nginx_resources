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
    listen_params
    includes
    root
    locations
    variables
    cookbook
    source
    enabled
  ).each do |key|
    value = node['nginx_resources']['site']['default_site'][key]
    send(key, value) unless value.nil?
  end
end

# Install the service definition, source an update cause a restart
#
if node['nginx_resources']['service']['managed']
  case node['nginx_resources']['service']['init_style']
  when 'upstart'
    template 'nginx_service' do
      path   '/etc/init/nginx.conf'
      source 'nginx-upstart.conf.erb'
      mode   '0644'
      variables({
        'sbin_path' => instance.sbin_path,
        'conf_path' => instance.conf_path,
        'pid_path'  => instance.pid_path,
        'configs'   => node['nginx_resources']['upstart'].to_hash
      })
    end
  end
end
