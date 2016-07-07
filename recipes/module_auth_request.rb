
node.default['nginx_resources']['source'].tap do |source_attr|
  source_attr['builtin_modules']['http_auth_request_module'] = true
end
