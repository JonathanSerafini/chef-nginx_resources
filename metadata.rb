name 'nginx_resources'
maintainer 'Jonathan Serafini'
maintainer_email 'jonathan@serafini.ca'
issues_url 'https://github.com/JonathanSerafini/chef-nginx_resources/issues'
source_url 'https://github.com/JonathanSerafini/chef-nginx_resources'
license 'apachev2'
description 'Cookbook to install nginx with resources'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
chef_version '>= 12.7'
version '0.2.0'

depends 'build-essential', '~> 2.3.0'
depends 'apt'
