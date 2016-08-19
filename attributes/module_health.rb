
default['nginx_resources']['health']['config'].tap do |config|
  config['uri']     = '/nginx_health'
  config['allow']   = ['127.0.0.1']
  config['deny']    = ['all']
  config['maintenance_override'] = '/var/lib/nginx-maintenance-mode'
  config['access_log'] = true
end
