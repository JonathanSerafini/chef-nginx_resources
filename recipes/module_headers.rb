
# Include containing response headers to send
#
nginx_resources_config 'headers' do
  category 'include'
  configs node['nginx_resources']['headers']['config']
end
