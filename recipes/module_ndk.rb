
nginx_resources_module 'module_ndk' do
  module_path "modules/ndk_http_module"
  priority  '20'
  version   node['nginx_resources']['module_ndk']['version']
  checksum  node['nginx_resources']['module_ndk']['checksum']
  source    node['nginx_resources']['module_ndk']['source']
end

