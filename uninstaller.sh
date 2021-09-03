#!/bin/sh
# Nombre de la base de datos: inscripcionsysacad
dbname="inscripcionsysacad"
# Usuario de la base de datos: inscripsysacad
dbuser="inscripsysacad"
dbhost="localhost"

read -p "Usuario MySQL [default:root]" dbroot
if [ ! -n "$dbroot" ];
then 
   dbroot="root"
fi

printf "Contrasena de $dbroot " >&2
stty -echo
read dbrootpass
stty echo
if [ ! -n "$dbrootpass" ];
then 
   dbrootpass=""
fi

echo '
[client]
user='$dbroot'
password='$dbrootpass'

' > xn
#REVISAR 
echo '
REVOKE ALL PRIVILEGES, GRANT OPTION FROM '"'"''$dbuser''"'"'@'"'"''$dbhost''"'"';
DROP DATABASE IF EXISTS `'$dbname'`;
DROP USER '"'"''$dbuser''"'"'@'"'"''$dbhost''"'"';
FLUSH PRIVILEGES;

' > dbremove.sql

mysql --defaults-extra-file=xn < dbremove.sql

rm -rf *

echo 'Fin del proceso!'

