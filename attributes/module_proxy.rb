# ngx_http_proxy_module
# http://nginx.org/en/docs/http/ngx_http_proxy_module.html

default['nginx_resources']['proxy']['config'].tap do |config|
end

default['nginx_resources']['proxy_upstreams']['config'].tap do |config|
end

default['nginx_resources']['proxy_headers']['config'].tap do |config|
  config['proxy_set_header'].tap do |header|
    header['Host']              = '$http_host'
    header['X-Forwarded-By']    = '$server_addr:$server_port'
    header['X-Forwarded-For']   = '$remote_addr'
    header['X-Forwarded-Class'] = '$classification'
    header['X-Forwarded-Port']  = '$server_port'
    header['X-Forwarded-Proto'] = '$scheme'
    header['X-Forwarded-Https'] = '$x_forwarded_https'
  end
end
