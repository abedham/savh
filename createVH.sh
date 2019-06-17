#!/bin/bash

while getopts p:d: option
do
case "${option}"
in
p) path=${OPTARG};;
d) domain=${OPTARG};;
esac	
done

function getTemplate(){
	cat > $3 <<- EOM
	<VirtualHost *:80>
	    ServerAdmin admin@example.com
	    ServerName $2
	    ServerAlias www.$2
	    DocumentRoot $1/public

	    <Directory $1/public>
		    Options Indexes FollowSymLinks MultiViews
		    AllowOverride All
		    Order allow,deny
		    allow from all
		    Require all granted
	    </Directory>

	    LogLevel debug
	    ErrorLog ${APACHE_LOG_DIR}/error.log
	    CustomLog ${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>
	EOM
}


function createVH(){
  File="/etc/apache2/sites-available/$domain.conf"
  echo '' > $File
  getTemplate $path $domain $File
  chgrp www-data -R $path
  find $path -type f -print0 | xargs -0 chmod 664
  find $path -type d -print0 | xargs -0 chmod 775
  a2ensite $domain.conf
  systemctl reload apache2 > /dev/null 2>&1
  echo "127.0.0.1       $domain
127.0.0.1       www.$domain" >> /etc/hosts

}

createVH




