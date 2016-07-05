# Default instance options
#
default['nginx_resources']['user']      = "www-data"
default['nginx_resources']['group']     = "www-data"

default['nginx_resources']['root_dir']  = '/opt'
default['nginx_resources']['conf_dir']  = '/etc/nginx'
default['nginx_resources']['bin_dir']   = '/usr/local/sbin'
default['nginx_resources']['spool_dir'] = '/var/spool/nginx'
default['nginx_resources']['pid_dir']   = '/var/run/nginx'

default['nginx_resources']['log_dir'] = '/var/log/nginx'
default['nginx_resources']['log_group'] = 'adm'
default['nginx_resources']['log_dir_perm'] = '0750'

# Default site options
#
default['nginx_resources']['site']['listen_params'] = {
  'reuseport' => false
}
default['nginx_resources']['site']['includes'] = []
default['nginx_resources']['site']['default_site'].tap do |config|
  config['priority'] = '20'
  config['listen'] = '80'
  config['server_name'] = '_'
  config['root'] = '/var/www/html'
  config['enabled'] = false
end

# Default service options
#
default['nginx_resources']['service']['name'] = "service[nginx]"
default['nginx_resources']['service']['managed'] = true
default['nginx_resources']['service']['init_style'] = 'upstart'

default['nginx_resources']['upstart']['runlevels'] = '2345'
default['nginx_resources']['upstart']['respawn_limit'] = nil

# Default build options
#
default['nginx_resources']['source']['version'] = '1.10.1'
default['nginx_resources']['source']['checksum'] = '1fd35846566485e03c0e318989561c135c598323ff349c503a6c14826487a801'
default['nginx_resources']['source']['environment'] = {}
default['nginx_resources']['source']['use_existing_user'] = true
default['nginx_resources']['source']['builtin_modules'] = {
  "threads" => true
}
default['nginx_resources']['source']['external_modules'] = {}
default['nginx_resources']['source']['additional_configure_flags'] = %w()
default['nginx_resources']['source']['include_recipes'] = %w(
  nginx_resources::module_ndk
  nginx_resources::module_ssl
  nginx_resources::module_realip
  nginx_resources::module_stub_status
  nginx_resources::module_fastcgi
  nginx_resources::module_gzip
)

