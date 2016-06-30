
nginx_resources_config 'fastcgi' do
  category  'include'
  configs    node['nginx_resources']['fastcgi']['config']
end

