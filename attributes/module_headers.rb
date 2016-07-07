# ngx_http_headers_module
# http://nginx.org/en/docs/http/ngx_http_headers_module.html

default['nginx_resources']['headers']['config'].tap do |config|
  config['add_header'].tap do |header|
    header['X-Served-By'] = '$hostname'
  end
end
