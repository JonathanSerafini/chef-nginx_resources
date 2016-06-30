
nginx_resources_config 'gzip' do
  category  'config'
  source    'config/generic.conf.erb'
  configs    node['nginx_resources']['gzip']['config']
end

