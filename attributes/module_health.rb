
default['nginx_resources']['health']['config'].tap do |config|
  config['uri']     = '/nginx_health'
  config['allow']   = ['127.0.0.1']
  config['deny']    = ['all']
  config['maintenace_override'] = '/var/lib/nginx-maintenace-mode'
  config['access_log'] = false
end

