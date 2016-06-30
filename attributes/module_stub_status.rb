# ngx_http_realip_module
# http://nginx.org/en/docs/http/ngx_http_realip_module.html

default['nginx_resources']['config_stub_status'].tap do |config|
  config['uri']    = '/nginx_status'
  config['allow']  = ['127.0.0.1']
  config['deny']   = ['all']
  config['stub_status'] = true
  config['access_log'] = false
end
