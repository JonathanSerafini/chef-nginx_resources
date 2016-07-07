module NginxResources
  module Mixin
    module DiscoveryMethods
      def find_nginx_resources(search_params)
        Chef.run_context.resource_collection.select do |r|
          resource_name = if search_params['resource_name']
                          then "^#{search_params["resource_name"]}$"
                          else '^nginx_resources_'
                          end
          next unless r.resource_name =~ /#{resource_name.to_s}/
          next unless search_params.all?{|p,v| r.send(p) == v}
          true
        end
      end

      def find_instance_resource(name)
        find_nginx_resources({
          'resource_name' => :nginx_resources_instance,
          'name' => name
        }).first
      end
    end
  end
end
