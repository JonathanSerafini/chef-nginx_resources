
# Build nginx from source
#
nginx_resources_source 'nginx_default' do
  source    node['nginx_resources']['source']['url']
  version   node['nginx_resources']['source']['version']
  checksum  node['nginx_resources']['source']['checksum']
  archive   "nginx-#{node['nginx_resources']['source']['version']}.tar.gz"
  deploy_path ::File.join(
    Chef::Config['file_cache_path'],
    "nginx-#{node['nginx_resources']['source']['version']}"
  )
end
