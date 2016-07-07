# Include required module
#
include_recipe 'nginx_resources::module_ndk'

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
  module_path node['nginx_resources']['lua']['module']['module_path']
  version   node['nginx_resources']['lua']['module']['version']
  checksum  node['nginx_resources']['lua']['module']['checksum']
  source    node['nginx_resources']['lua']['module']['source']
end

nginx_resources_config 'lua' do
  priority  '30'
  category  'config'
  configs node['nginx_resources']['lua']['config']
end
