#user $NGINX_USER;
worker_processes auto;
pid /home/container/nginx.pid;
error_log /home/container/.container-config/nginx/logs/error.log;

events {
    worker_connections 768;
}

http {
    # temporary files{
    client_body_temp_path /tmp/nginx 1 2;
    proxy_temp_path /tmp/nginx-proxy;
    fastcgi_temp_path /tmp/nginx-fastcgi;
    uwsgi_temp_path /tmp/nginx-uwsgi;
    scgi_temp_path /tmp/nginx-scgi;
    
    # other
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;

    types_hash_max_size 2048;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;
    gzip on;
    gzip_disable "msie6";
    # include /etc/nginx/conf.d/*.conf;
    #include /etc/nginx/sites-enabled/*;
    server {
        # logs
        access_log /home/container/.container-config/nginx/logs/access.log;
        error_log /home/container/.container-config/nginx/logs/error.log;

        listen 2999 default_server;
        # listen $NGINX_PORT  default_server;
        root $NGINX_WEB_ROOT;
        location / {
            try_files $uri $NGINX_PHP_FALLBACK$is_args$args;
        }
        location ~ $NGINX_PHP_LOCATION {
            fastcgi_pass unix:$PHP_SOCK_FILE;
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            #include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            fastcgi_param DOCUMENT_ROOT $realpath_root;
            internal;
        }

        # return 404 for all other php files not matching the front controller
        # this prevents access to other php files you don't want to be accessible.
        location ~ \.php$ {
            return 404;
        }
    }
}
