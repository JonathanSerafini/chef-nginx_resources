resource_name :nginx_resources_site

property :instance,
  kind_of: String,
  default: 'default'

property :priority,
  kind_of: String,
  coerce: proc { |v| v.to_s },
  default: '50'

property :server_name,
  kind_of: Array,
  coerce: proc { |v| Array(v) },
  required: true

property :listen,
  kind_of: Array,
  coerce: proc { |v| Array(v) },
  required: true

property :listen_params,
  kind_of: Hash,
  default: Hash.new

property :includes,
  kind_of: Array,
  default: Array.new

property :root,
  kind_of: String,
  required: true

property :locations,
  kind_of: Array,
  default: lazy { |r|
    [
      { 'path' => '/', 'try_files' => %($uri index.htm) }
    ]
  }

property :configs,
  kind_of: Hash,
  coerce: proc { |v| 
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: Hash.new

property :variables,
  kind_of: Hash,
  coerce: proc { |v| 
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: Hash.new

property :cookbook,
  kind_of: String,
  default: 'nginx_resources'

property :source,
  kind_of: String,
  default: 'site/generic.conf.erb'

property :local,
  kind_of: [TrueClass, FalseClass],
  default: false

property :enabled,
  kind_of: [TrueClass, FalseClass],
  default: true

action :install do
  nginx_resources_config new_resource.name do
    instance  new_resource.instance
    priority  new_resource.priority
    category  'site'
    local     new_resource.local
    source    new_resource.source
    cookbook  new_resource.cookbook
    variables template_variables
    enabled   new_resource.enabled
  end
end

action :delete do
  nginx_resources_config new_resource.name do
    instance  new_resource.instance
    category  'site'
    action    :delete
  end
end

action_class do
  include NginxResources::Mixin::DiscoveryMethods

  # chef/chef#4537
  def whyrun_supported?
    true
  end

  def nginx_instance_resource
    @nginx_instance_resource = find_resources({
      'resource_name' => :nginx_resources_instance,
      'name' => new_resource.instance
    }).first
  end

  def template_variables
    variables = {
      'listen' => new_resource.listen,
      'listen_params' => new_resource.listen_params,
      'server_name' => new_resource.server_name,
      'includes' => new_resource.includes,
      'root' => new_resource.root,
      'locations' => new_resource.locations
    }
    variables.merge!(new_resource.variables)
    variables['configs'] = new_resource.configs
    variables
  end
end

