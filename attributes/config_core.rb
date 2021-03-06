# https://nginx.org/en/docs/http/ngx_http_core_module.html
#
default['nginx_resources']['core']['config'].tap do |config|
  config['client_body_buffer_size'] = '128k'
  config['client_body_timeout'] = '60s'
  config['client_header_buffer_size'] = '1k'
  config['client_header_timeout'] = '60s'
  config['client_max_body_size'] = '1m'
  config['client_body_temp_path'] = '/var/spool/nginx'

  config['default_type'] = 'application/octet-stream'

  config['keepalive_requests'] = 100
  config['keepalive_timeout'] = '5s'

  config['large_client_header_buffers'] = '4 8k'

  config['log_formats']['friendly_syslog'] = "'" + %w(
    $http_host:$server_port
    - $remote_addr
    - $upstream_addr
    - $status
    - $request_time[$upstream_response_time]
    - \"$request\"
    - \"$http_user_agent\"
  ).join(' ') + "'"

  config['log_formats']['apache'] = "'" + %w(
    $remote_addr - $remote_user [$time_local]
    \"$request\" $status $body_bytes_sent
    \"$http_referer\" \"$http_user_agent\"
    \"$http_cookie\"
  ).join(' ') + "'"

  config['access_log'] = '/var/log/nginx/access.log apache'

  config['open_file_cache']['max'] = 2000
  config['open_file_cache']['inactive'] = '60s'
  config['open_file_cache_min_uses'] = 1
  config['open_file_cache_errors'] = 'off'
  config['open_file_cache_valid'] = '60s'

  config['reset_timedout_connection'] = false
  config['resolver'] = '127.0.0.1' # TODO

  config['sendfile'] = false
  config['sendfile_max_chunk'] = 0

  config['send_timeout'] = '60s'

  config['server_tokens'] = true

  config['server_names_hash_bucket_size'] = 128
  config['server_names_hash_max_size'] = 512

  config['tcp_nopush'] = true
  config['tcp_nodelay'] = true

  config['types_hash_bucket_size'] = 64
  config['types_hash_max_size'] = 2048

  config['underscores_in_headers'] = false

  config['variables_hash_bucket_size'] = 64
  config['variables_hash_max_size'] = 1024
end
