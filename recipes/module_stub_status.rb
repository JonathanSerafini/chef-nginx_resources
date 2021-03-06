
nginx_resources_config 'stub_status' do
  category 'include'
  configs node['nginx_resources']['stub_status']['config']
end

node.default['nginx_resources']['source'].tap do |source_attr|
  source_attr['builtin_modules']['http_stub_status_module'] = true
end
