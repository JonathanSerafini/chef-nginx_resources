default['nginx_resources']['module_lua'].tap do |mod|
  v = '0.10.5'

  mod['source'] = "https://github.com/openresty/lua-nginx-module/archive/v#{v}.tar.gz"
  mod['version'] = "#{v}"
  mod['checksum'] = '4f0292c37ab3d7cb980c994825040be1bda2c769cbd800e79c43eb37458347d4'
end

default['nginx_resources']['config_lua'] = {}
