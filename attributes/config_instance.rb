
default['nginx_resources']['instance']['config'].tap do |config|
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
      'max_queue' => 65_536
    }
  }

  config['worker_connections'] = 5_000
  config['worker_processes'] = 'auto'
  config['worker_rlimit_nofile'] = 65_000
end
