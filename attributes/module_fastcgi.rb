# ngx_http_fastcgi_module
# http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html

default['nginx_resources']['config_fastcgi'].tap do |config|
  config['default_index'] = '/index.php'
  config['fastcgi_params'] = {}
end
