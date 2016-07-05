# Deploy the nginx service
#
if node['nginx_resources']['service']['managed']
  instance = resources("nginx_resources_instance[default]")

  case node['nginx_resources']['service']['init_style']
  when 'upstart'
    template 'nginx_service' do
      path   '/etc/init/nginx.conf'
      source 'nginx-upstart.conf.erb'
      mode   '0644'
      variables({
        'sbin_path' => instance.sbin_path,
        'conf_path' => instance.conf_path,
        'pid_path'  => instance.pid_path,
        'configs'   => node['nginx_resources']['upstart'].to_hash
      })
    end

    service 'nginx' do
      provider Chef::Provider::Service::Upstart
      supports :status => true, :restart => true, :reload => true
      if node['nginx_resources']['service']['should_start']
        action :start
      else
        action :nothing
      end
    end
  end
end
