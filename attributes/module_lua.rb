
default['nginx_resources']['lua']['module'].tap do |config|
  v = '0.10.5'
  config['module_path'] = 'modules/ngx_http_lua_module'
  config['source']      = 'https://github.com/openresty/lua-nginx-module' <<
                          '/archive/v0.10.5.tar.gz'
  config['version']     = '0.10.5'
  config['checksum']    = '4f0292c37ab3d7cb980c994825040be1bda2c769cbd' <<
                          '800e79c43eb37458347d4'
end

default['nginx_resources']['lua']['config'].tap do |config|
  config['package_path'] = %w(
    /usr/share/lua/5.1
    /usr/local/share/lua/5.1
  )

  config['package_cpath'] = %w(
    /usr/lib/lua/5.1
    /usr/local/lib/lua/5.1
    /usr/lib/x86_64-linux-gnu/lua/5.1
  )

  config['init']['includes'] = %w()
  config['init_worker']['includes'] = %w()
end
