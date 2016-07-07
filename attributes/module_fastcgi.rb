# ngx_http_fastcgi_module
# http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html

default['nginx_resources']['fastcgi']['config'].tap do |config|
  config['default_index'] = '/index.php'
  config['fastcgi_param'] = {
    'CONTENT_TYPE' => '$content_type',
    'CONTENT_LENGTH' => '$content_length',
    'DOCUMENT_URI' => '$document_uri',
    'DOCUMENT_ROOT' => '$document_root',
    'GATEWAY_INTERFACE' => 'CGI/1.1',
    'PATH_INFO' => '$fastcgi_path_info',
    'PATH_TRANSLATED' => '$document_root$fsn',
    'QUERY_STRING' => '$query_string',
    'REMOTE_ADDR' => '$remote_addr',
    'REQUEST_METHOD' => '$request_method',
    'REDIRECT_STATUS' => '200',
    'REQUEST_URI' => '$request_uri',
    'SCRIPT_FILENAME' => '$document_root$fsn',
    'SCRIPT_NAME' => '$fastcgi_script_name',
    'SERVER_ADDR' => '$server_addr',
    'SERVER_NAME' => '$server_name',
    'SERVER_PORT' => '$server_port',
    'SERVER_PROTOCOL' => '$server_protocol',
    'SERVER_SOFTWARE' => 'nginx/$nginx_version'
  }
end
