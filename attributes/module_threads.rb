  
default['nginx_resources']['module_threads'].tap do |config|
  config['thread_pool'] = {
    'default' => {
      'threads' => 32,
      'max_queue' => 65536
    }
  }
end

default['nginx_resources']['config_threads'].tap do |config|
  config['aio'] = 'threads=default'
end

