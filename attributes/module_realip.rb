# ngx_http_realip_module
# http://nginx.org/en/docs/http/ngx_http_realip_module.html

default['nginx_resources']['realip']['config'].tap do |config|
  config['addresses']          = ['127.0.0.1']
  config['real_ip_header']     = "X-Forwarded-For"
  config['real_ip_recursive']  = true
end
