# ngx_http_gzip_module
# http://nginx.org/en/docs/http/ngx_http_gzip_module.html

default['nginx_resources']['gzip']['config'].tap do |config|
  config['gzip'] = true
  config['gzip_buffers'] = '16 8k'
  config['gzip_disable'] = 'MSIE [1-6]\.'
  config['gzip_comp_level'] = 2
  config['gzip_http_version'] = '1.0'
  config['gzip_min_length'] = 1000
  config['gzip_proxied'] = 'any'
  config['gzip_types'] = %w(
    text/plain
    text/css
    application/x-javascript
    text/xml
    application/xml
    application/rss+xml
    application/atom+xml
    text/javascript
    application/javascript
    application/json
    text/mathml
  ).join(' ')
  config['gzip_vary'] = 'off'
end
