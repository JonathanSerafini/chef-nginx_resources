# ndk_http_module
# https://github.com/simpl/ngx_devel_kit

default['nginx_resources']['ndk']['module'].tap do |config|
  config['module_path'] = 'modules/ndk_http_module'
  config['source']      = 'https://github.com/simpl/ngx_devel_kit' <<
                          '/archive/v0.3.0.tar.gz'
  config['version']     = '0.3.0'
  config['checksum']    = '88e05a99a8a7419066f5ae75966fb1efc409bad4' <<
                          '522d14986da074554ae61619'
end

