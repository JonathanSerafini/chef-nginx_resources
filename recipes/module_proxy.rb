
# Configuration file containing global proxy configurations
#
nginx_resources_config 'proxy' do
  category  'config'
  source    'config/generic.conf.erb'
  configs    node['nginx_resources']['proxy']['config']
end

# Configuration file containing global upstream definitions
# 
nginx_resources_config 'proxy_upstreams' do
  category  'config'
  configs    node['nginx_resources']['proxy_upstreams']['config']
end

# Include containing specific headers to send to backend servers
#
nginx_resources_config 'proxy_headers' do
  category  'include'
  configs    node['nginx_resources']['proxy_headers']['config']
end

