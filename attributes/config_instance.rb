
default['nginx_resources']['config_instance'].tap do |config|
  # ngx_core_module
  #
  config['aio'] = 'threads=default'

  config['daemon'] = true
  config['multi_accept'] = false
  config['pcre_jit'] = false

  config['env'] = {}
  config['error_log'] = 'logs/error.log error'

  config['thread_pool'] = {
    'default' => {
      'threads' => 32,
      'max_queue' => 65536
    }
  }

  config['worker_connections'] = 512
  config['worker_processes'] = 'auto'
  config['worker_rlimit_nofile'] = '1024'
end

