# Install user account
#
user 'nginx_user' do
  username node['nginx_resources']['user']
  system true
  shell  '/bin/false'
  home   '/var/www'
  not_if do
    node['nginx_resources']['source']['use_existing_user']
  end
end
