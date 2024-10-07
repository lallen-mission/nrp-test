#!/bin/bash

if [[ -z "${DOMAIN}" ]]
then
    echo -e "[!] \$DOMAIN not specified!"
    exit 1
fi

if [[ -z "${ENVIRONMENT}" ]]
then
    echo -e "[!] \$ENVIRONMENT not specified!"
    exit 1
fi

if [[ -z "${PROTO}" ]]
then
    echo -e "[!] \$PROTO not specified!"
    exit 1
fi

echo -e "[+] Generating Nginx config for domain *.${DOMAIN}"
rm -f /etc/nginx/conf.d/*.conf

cat << EOF > /etc/nginx/conf.d/proxy.conf
server {
    listen 80;
    server_name ${DOMAIN};
    rewrite_log on;
    error_log /dev/stdout info;
    access_log /dev/stdout;

    # Extract the first part of the URL (e.g., /mypath)
    set \$app "";
    if (\$uri ~* ^/([^/]+)) {
        set \$app \$1;
    }

    # Rewrite the URL by removing the first part (e.g., /mypath -> /)
    rewrite ^/[^/]+/(.*)\$ /\$1 break;

    # Dynamically construct the backend subdomain (e.g., mypath-prod.${DOMAIN})
    set \$backend "\$app-${ENVIRONMENT}.${DOMAIN}";

    # Proxy the request to the dynamically determined backend
    location / {
        proxy_pass ${PROTO}://\$app-${ENVIRONMENT}.${DOMAIN};
    }
}
EOF

cat /etc/nginx/conf.d/proxy.conf
echo -e "[+] Starting Nginx!"

nginx -g "daemon off;"
