# Maintenance resource is designed to enable/disable maintenance mode on the
# instance. It also provides facilities to force maintenance mode for the
# duration of a Chef run.
#
# @example
# ```ruby
# nginx_resources_maintenance 'default' do
#   compile_time true
#   enable_only_if do
#     node['attribute_to_enable_maintenance']
#   end
#   disable only if do
#     !node['attribute_to_enable_maintenance'] ||
#     node['attribute_to_delete_maintenance']
#   end
#   action :manage
# end
# ```
resource_name :nginx_resources_maintenance

# Path to the maintenance mode file which is used by the `module_health` recipe
# @since 0.5.0
property :path,
  kind_of: String,
  default: lazy {
    node['nginx_resources']['health']['config']['maintenance_override']
  }

# Whether to apply the resource at compile time
# @since 0.5.0
property :compile_time,
  kind_of: [TrueClass, FalseClass],
  default: false

# Condition to determine whether to enable maintenance mode
# @since 0.5.0
def enable_only_if(&block)
  set_or_return(:enable_only_if, block, kind_of: Proc)
end

# Chef event_handler to hook into when enabling
# @since 0.5.0
property :enable_event,
  kind_of: String,
  default: 'converge_start'

# Condition to determine whether to disable maintenance mode
# @since 0.5.0
def disable_only_if(&block)
  set_or_return(:disable_only_if, block, kind_of: Proc)
end

# Chef event_handler to hook into when disabling
# @since 0.5.0
property :disable_event,
  kind_of: String,
  default: 'converge_complete'

# When compile_time is defined, apply the action immediately and then set the
# action :nothing to ensure that it does not run a second time.
def after_created
  if compile_time
    actions = Array(self.action) || [:manage]
    actions.each do |action|
      next if action == :nothing
      self.run_action(:manage)
    end
    self.action(:nothing)
  end
end

# Action to create the maintenance mode lock file
# @since 0.5.0
action :create do
  maintenance_file_resource do
    action :create_if_missing
    only_if new_resource.enable_only_if if new_resource.enable_only_if
  end
end

# Action to delete the maintenance mode lock file
# @since 0.5.0
action :delete do
  maintenance_file_resource do
    action :delete
    only_if new_resource.disable_only_if if new_resource.disable_only_if
  end
end

# Action to create the maintenance mode based on Chef event_handlers.
action :manage do
  new_resource = self

  Chef.event_handler do
    on new_resource.enable_event.to_sym do
      if new_resource.guard_evaluates_true?(new_resource.enable_only_if)
        ::File.write(new_resource.path, '')
      end

      if ::File.exist?(new_resource.path)
        Chef::Log.warn 'Nginx maintenance is currently in effect'
      end
    end if new_resource.enable_event

    on new_resource.disable_event.to_sym do
      if new_resource.guard_evaluates_true?(new_resource.disable_only_if)
        ::File.rm(new_resource.path)
      end

      if ::File.exist?(new_resource.path)
        Chef::Log.warn 'Nginx maintenance is currently in effect'
      end
    end if new_resource.disable_event
  end
end

action_class do
  # Support whyrun
  def whyrun_supported?
    true
  end

  def maintenance_file_resource
    file new_resource.path do
      action :nothing
    end
  end

  def guard_evaluates_true?(guard)
    node = Chef.run_context.node
    new_resource = new_resource
    guard ? guard.call : true
  end
end
