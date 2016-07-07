# Site resource wraps Config to provide some additional logic to a virtualhost
# creation.
#
resource_name :nginx_resources_site

# Name of the nginx_resources_instance resource which this belongs to
# @since 0.1.0
property :instance,
  kind_of: String,
  default: 'default'

# A priority prefix for the configurtion path in order to load in order
# @since 0.1.0
property :priority,
  kind_of: String,
  coerce: proc { |v| v.to_s },
  default: '50'

# The nginx server_name (ex.: server_name wwww.mysite.com)
# @since 0.1.0
property :server_name,
  kind_of: Array,
  coerce: proc { |v| Array(v) },
  required: true

# The nginx listen (ex.: listen 443 ssl)
# @since 0.1.0
property :listen,
  kind_of: Array,
  coerce: proc { |v| Array(v) },
  required: true

# Additional listen_params which applies to all listen statements
# @since 0.1.0
property :listen_params,
  kind_of: Hash,
  default: lazy {
    node['nginx_resources']['site']['listen_params'].to_hash
  }

# List of files to include within the configuration
# @since 0.1.0
property :includes,
  kind_of: Array,
  default: lazy {
    node['nginx_resources']['site']['includes'].to_a
  }

# The nginx root (docroot)
# @since 0.1.0
property :root,
  kind_of: String,
  required: true

# Array of Hashes defining nginx location blocks
# The hashes support the following keys:
# - uri: The name and path of the location
# - try_files: Nginx try_files statement
# - proxy_pass: Nginx proxy_pass statement
# - configs: Hash of nginx params to include in the location block
# @since 0.1.0
property :locations,
  kind_of: Array,
  default: lazy {
    [
      { 'uri' => '/', 'try_files' => %($uri index.htm) }
    ]
  }

# Nginx parameters which should be included in the virtualhost file
# @since 0.1.0
property :configs,
  kind_of: Hash,
  coerce: proc { |v|
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: {}

# Additional variables that are not nginx parameters
# @since 0.1.0
property :variables,
  kind_of: Hash,
  coerce: proc { |v|
    case v
    when Chef::Node::ImmutableMash then v.to_hash
    else v
    end
  },
  default: {}

# Cookbook containing the template source
# @since 0.1.0
property :cookbook,
  kind_of: String,
  default: 'nginx_resources'

# Template source
# @since 0.1.0
property :source,
  kind_of: String,
  default: 'site/generic.conf.erb'

# Whether the template is disk local or provided in the cookbook
# @since 0.1.0
property :local,
  kind_of: [TrueClass, FalseClass],
  default: false

# Whether the site should be enabled or note
# @since 0.1.0
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
    configs   new_resource.configs
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

  # Support whyrun
  def whyrun_supported?
    true
  end

  def nginx_instance_resource
    @nginx_instance_resource = find_resources(
      'resource_name' => :nginx_resources_instance,
      'name' => new_resource.instance
    ).first
  end

  # rubocop:disable Metrics/AbcSize
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
    variables
  end
end
