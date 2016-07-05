# Source downloads and unpacks a remove file.
#
resource_name :nginx_resources_source

# The version to be compiled
# @since 0.1.0
property :version,
  kind_of: String,
  required: true


# The checksum of the source archive file
# @since 0.1.0
property :checksum,
  kind_of: String,
  required: true,
  desired_state: false

# The URL from which to download the archive file
# @since 0.1.0
property :source,
  kind_of: String,
  required: true,
  desired_state: false

# The name of the archive file we have downloaded and stored on disk
# @since 0.1.0
property :archive,
  kind_of: String,
  default: lazy { |r| "#{r.name}-#{r.version}.tar.gz" },
  desired_state: false

# The folders to strip after extracting the archive
# @since 0.1.0
property :archive_depth,
  kind_of: Integer,
  desired_state: false,
  default: 1

# The path where the archive exists on disk
# @since 0.1.0
property :archive_path,
  kind_of: String,
  desired_state: false,
  default: lazy { |r|
    ::File.join(
      Chef::Config['file_cache_path'],
      r.archive
    )
  }

# The path where the archive will be extracted to
# @since 0.1.0
property :deploy_path,
  kind_of: String,
  desired_state: false,
  default: lazy { |r|
    ::File.join(
      Chef::Config['file_cache_path'],
      "#{r.name}-#{r.version}"
    )
  }

# An optional ruby block to evaluate within the context of this resource.
# @since 0.1.0
def hook(&block)
  @hook = block if block_given?
  @hook
end

action :install do
  remote_file new_resource.source do
    source    new_resource.source
    checksum  new_resource.checksum
    path      new_resource.archive_path
    backup    false
  end

  bash 'extract_source' do
    cwd ::File.dirname(new_resource.archive_path)
    code <<-EOH
      mkdir #{new_resource.deploy_path}
      tar zxf #{::File.basename(new_resource.archive_path)} \
           --strip-components=#{new_resource.archive_depth} \
           -C #{new_resource.deploy_path}
    EOH
    not_if do
      ::File.directory?(new_resource.deploy_path)
    end
  end

  if hook
    recipe_eval(&hook)
  end
end

action :delete do
  file new_resource.archive_path do
    action :delete
  end

  directory new_resource.deploy_path do
    recursive true
    action    :delete
  end
end

action_class do
  # Support whyrun
  def whyrun_supported?
    true
  end
end

