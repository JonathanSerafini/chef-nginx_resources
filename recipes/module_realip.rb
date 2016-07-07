
nginx_resources_config 'realip' do
  category 'config'
  configs node['nginx_resources']['realip']['config']
end

node.default['nginx_resources']['source'].tap do |source_attr|
  source_attr['builtin_modules']['http_realip_module'] = true
end
