
name "nginx_resources"
run_list "nginx_resources::default"

default_source :supermarket
cookbook "nginx_resources", path: "."

