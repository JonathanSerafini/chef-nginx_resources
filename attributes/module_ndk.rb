# ndk_http_module
# https://github.com/simpl/ngx_devel_kit

default['nginx_resources']['module_ndk'].tap do |mod|
  v = '0.3.0'

  mod['source'] = "https://github.com/simpl/ngx_devel_kit/archive/v#{v}.tar.gz"
  mod['version'] = "#{v}"
  mod['checksum'] = '88e05a99a8a7419066f5ae75966fb1efc409bad4522d14986da074554ae61619'
end

