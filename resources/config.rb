resource_name :nginx_resources_config

property :instance,
  kind_of: String,
  default: "default"

property :priority,
  kind_of: [NilClass,String],
  coerce: proc { |v| v.to_s unless v.nil? },
  default: lazy { |r|
    case r.category
    when 'include' then nil
    else "50"
    end
  }

property :category,
  kind_of: String,
  equal_to: ['config', 'module', 'include', 'site'],
  required: true

property :filename,
  kind_of: String,
  coerce: proc { |v| v =~ /\.conf$/ ? v : "#{v}.conf" },
  default: lazy { |r| "#{r.name}.conf" }

property :cookbook,
  kind_of: String,
  default: "nginx_resources"

property :source,
  kind_of: String,
  default: lazy { |r| "#{r.category}/#{r.filename}.erb" }

property :local,
  kind_of: [TrueClass, FalseClass],
  default: false

property :enabled,
  kind_of: [TrueClass, FalseClass],
  default: true

property :variables,
  kind_of: Hash,
  coerce: proc { |v| 
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: Hash.new

property :configs,
  kind_of: Hash,
  coerce: proc { |v| 
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: Hash.new

action :create do
  template template_path do
    local     new_resource.local
    source    new_resource.source
    cookbook  new_resource.cookbook
    variables template_variables

    helper :on_off do |bool|
      bool ? "on" : "off"
    end

    helper :hash_to_s do |hash|
      hash.map{|k,v| "#{k}=#{v}"}.join(" ")
    end

    notifies :restart, nginx_instance_resource.service, :delayed
  end

  duplicates = []
  duplicates.concat(::Dir.glob(template_enabled_path('*')))  
  duplicates.concat(::Dir.glob(template_available_path('*')))  
  duplicates.delete(template_path)

  if duplicates.count > 1
    fatal! "#{desired} multiple duplicate files have been found"
  end

  duplicates.each do |duplicate|
    file duplicate do
      action :delete
    end
  end
end
  
action :delete do
  file template_path do
    action :delete
  end
end

action_class do
  include NginxResources::Mixin::DiscoveryMethods

  # chef/chef#4537
  def whyrun_supported?
    true
  end

  def nginx_instance_resource(&block)
    @nginx_instance = find_instance_resource(new_resource.instance, &block)
  end

  def template_conf_dir
    category_dir =  case new_resource.category
                    when 'config' then 'conf.d'
                    when 'module' then 'module.d'
                    when 'include' then 'include.d'
                    when 'site' then 'site.d'
                    end
    ::File.join(nginx_instance_resource.conf_dir, category_dir)
  end

  def template_prefix_filename(prefix = nil)
    prefix = new_resource.priority if prefix.nil?
    prefix = "#{prefix}-" unless prefix.nil?
    "#{prefix}#{new_resource.filename}"
  end

  def template_enabled_path(prefix = nil)
    ::File.join(template_conf_dir, template_prefix_filename(prefix))
  end

  def template_available_path(prefix = nil)
    template_enabled_path(prefix).sub(/\.conf$/,'')
  end

  def template_path
    new_resource.enabled ? template_enabled_path : template_available_path
  end

  def template_variables
    variables = {}.merge(new_resource.variables)
    variables = {
      'name'      => new_resource.name,
      'pid_dir'   => nginx_instance_resource.pid_dir,
      'log_dir'   => nginx_instance_resource.log_dir,
      'conf_dir'  => nginx_instance_resource.conf_dir,
      'spool_dir' => nginx_instance_resource.spool_dir
    }
    variables.merge!(new_resource.variables)
    variables['configs'] = new_resource.configs
    variables
  end
end

