# Deploy the nginx service
#
if node['nginx_resources']['service']['managed']
  instance = resources("nginx_resources_instance[default]")

  case node['nginx_resources']['service']['init_style']
  when 'upstart'
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
