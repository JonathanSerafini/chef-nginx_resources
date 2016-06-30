# Include required module
#
include_recipe "nginx_resources::module_ndk"

# Install package dependencies
#
packages = value_for_platform_family(
  %w(default) => %w(luajit libluajit-5.1-dev)
)

packages.each do |name|
  package name
end

# Export library paths required for compiling
#
node.default['nginx_resources']['source'].tap do |source_attr|
  source_attr['environment']['LUAJIT_INC'] = '/usr/include/luajit-2.0'
  source_attr['environment']['LUAJIT_LIB'] = '/usr/lib/x86_64-linux-gnu'
end

# Download lua nginx source
#
nginx_resources_module 'module_lua' do
  module_path "modules/ngx_http_lua_module"
  version   node['nginx_resources']['module_lua']['version']
  checksum  node['nginx_resources']['module_lua']['checksum']
  source    node['nginx_resources']['module_lua']['source']
end

nginx_resources_config "lua" do
  priority  '30'
  category  'config'
  source    'config/generic.conf.erb'
  configs    node['nginx_resources']['config_lua']
end

