
nginx_resources_module 'module_ndk' do
  module_path node['nginx_resources']['ndk']['module']['module_path']
  priority  '20'
  version   node['nginx_resources']['ndk']['module']['version']
  checksum  node['nginx_resources']['ndk']['module']['checksum']
  source    node['nginx_resources']['ndk']['module']['source']
end
