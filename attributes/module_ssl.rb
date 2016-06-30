# ngx_http_ssl_module
# http://nginx.org/en/docs/http/ngx_http_ssl_module.html

default['nginx_resources']['module_ssl'].tap do |mod|
  v = '1.0.2h'

  mod['source'] = "https://www.openssl.org/source/openssl-#{v}.tar.gz"
  mod['version'] = "#{v}"
  mod['checksum'] = '1d4007e53aad94a5b2002fe045ee7bb0b3d98f1a47f8b2bc851dcd1c74332919'
  mod['archive_depth'] = 1
  mod['use_native'] = false
  mod['generate_dhparam'] = true
end

default['nginx_resources']['config_ssl'].tap do |config|
  config['ssl'] = true
  config['ssl_buffer_size'] = '16k'
  config['ssl_dhparam'] = '/etc/ssl/dhparam.pem'
	config['ssl_prefer_server_ciphers'] = true
  config['ssl_protocols'] = 'TLSv1.1 TLSv1.2'
  config['ssl_session_cache'] = 'shared:SSL:10m'
  config['ssl_session_timeout'] = '5m'
  config['ssl_stapling'] = true

  # Array to contain a list of supported ciphers
  supported_ciphers = []

	# Support PFS Diffie Helman enabled ciphers
	supported_ciphers.concat(%w(
		kEECDH+ECDSA+AES128
		kEECDH+ECDSA+AES256
		kEECDH+AES128
		kEECDH+AES256
	))

	# Support fast certificates
	supported_ciphers.concat(%w(
		ECDHE-RSA-AES128-GCM-SHA256
		ECDHE-RSA-AES128-GCM-SHA256
		ECDHE-ECDSA-AES128-GCM-SHA256
		ECDHE-RSA-AES256-GCM-SHA384
		ECDHE-ECDSA-AES256-GCM-SHA384
		DHE-RSA-AES128-GCM-SHA256
		DHE-DSS-AES128-GCM-SHA256
		ECDHE-RSA-AES128-SHA256
		ECDHE-ECDSA-AES128-SHA256
		ECDHE-RSA-AES128-SHA
		ECDHE-ECDSA-AES128-SHA
		ECDHE-RSA-AES256-SHA384
		ECDHE-ECDSA-AES256-SHA384
		ECDHE-RSA-AES256-SHA
		ECDHE-ECDSA-AES256-SHA
		DHE-RSA-AES128-SHA256
		DHE-RSA-AES128-SHA
		DHE-DSS-AES128-SHA256
		DHE-RSA-AES256-SHA256
		DHE-DSS-AES256-SHA
		DHE-RSA-AES256-SHA
		AES128-GCM-SHA256
		AES256-GCM-SHA384
		AES128
		AES256
		HIGH
	))

	# Disable insecure ciphers
	supported_ciphers.concat(%w(
		!aNULL
		!eNULL
		!DES
		!3DES
		!SEED
		!CAMELLIA
		!SRP
		!EXP
		!MD5
		!DSS
		!kEDH
		!kECDH
		!EXPORT
  	!RC4
	))

	config['ssl_ciphers'] = supported_ciphers.uniq.join(":")
end
