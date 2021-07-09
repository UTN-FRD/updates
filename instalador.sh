#!/bin/sh
########
# Instalacion desatendida #
# Condiciones: 
# Base de datos MySQL instalada en el mismo servidor que la aplicación
dbhost="localhost"
# Nombre de la base de datos: inscripcionsysacad
dbname="inscripcionsysacad"
# Usuario de la base de datos: inscripsysacad
dbuser="inscripsysacad"
# Contraseña de la base de datos: 1nscr1psys4c4d
dbpass="1nscr1psys4c4d"

# Usuarios del sistema
useradmin='admin'
userpass='admin'
userapi='sysacad'
userapipass='sys4c4d'

# Valores pedidos al usuario
read -p "ingrese el correo electronico de Gmail para enviar mensajes automaticos: " emailadmin
if [ ! -n "$emailadmin" ];
then 
   emailadmin=""
fi

read -p "ingrese la contrasena del correo electronico de Gmail: " emailpass
if [ ! -n "$emailpass" ];
then 
   emailpass=""
fi

read -p "Usuario MySQL [default:root] " dbroot
if [ ! -n "$dbroot" ];
then 
   dbroot="root"
fi

read -p "Password de $dbroot " dbrootpass
if [ ! -n "$dbrootpass" ];
then 
   dbrootpass=""
fi

echo 'Descargando archivos...'
wget https://github.com/UTN-FRD/updates/raw/main/inscripcion.zip

if [ ! -f inscripcion.zip ]; then
    echo "Hubo un error al descargar el archivo de instalacion..."
    exit 1
fi

echo 'Extrayendo archivos...'
unzip -qq inscripcion.zip

echo 'Moviendo archivos...'
echo '
<?php
// Database credentials
$dbname = '"'"''$dbname''"'"';
$dbuser = '"'"''$dbuser''"'"';
$dbpass = '"'"''$dbpass''"'"';
$dbhost = '"'"''$dbhost''"'"';

// Datatables MySQL connection
$sql_details = array(
    '"'"'user'"'"' => $dbuser,
    '"'"'pass'"'"' => $dbpass,
    '"'"'db'"'"'   => $dbname,
    '"'"'host'"'"' => $dbhost
);

// Emailer credentials
$emailAdmin = '"'"''$emailadmin''"'"';
$emailPass = '"'"''$emailpass''"'"';

' > Config.php

mv inscripcion-frd/* .
mv inscripcion-frd/.[!.]* .
rmdir inscripcion-frd
rm -f Modells/Config.php
cp Config.php Modells/Config.php

mkdir documents
chmod 755 documents
chown -R www-data:www-data documents/
chmod -R g+rw documents/

mkdir admin
mv inscripcion-admin/* admin
mv inscripcion-admin/.[!.]* admin
rmdir inscripcion-admin
rm -f admin/Modells/Config.php
cp Config.php admin/Modells/Config.php

mkdir api
mv inscripcion-api/* api
mv inscripcion-api/.[!.]* api
rmdir inscripcion-api
rm -f capi/Modells/Config.php
cp Config.php api/Modells/Config.php

chown -R www-data:www-data *

echo 'Creando la base de datos...'

echo '
[client]
user='$dbroot'
password='$dbrootpass'

' > xn

echo '
CREATE DATABASE IF NOT EXISTS `'$dbname'`;
CREATE USER '"'"''$dbuser''"'"'@'"'"''$dbhost''"'"' IDENTIFIED BY '"'"''$dbpass''"'"';
GRANT ALL PRIVILEGES ON `'$dbname'`.* TO '"'"''$dbuser''"'"'@'"'"''$dbhost''"'"';
FLUSH PRIVILEGES;

' > dbcreate.sql

mysql --defaults-extra-file=xn < dbcreate.sql

echo 'Creando la estructura de datos...'
mysql --defaults-extra-file=xn $dbname < database-structure.sql
mysql --defaults-extra-file=xn $dbname < database-views.sql

echo 'Inicializando datos...'
mysql --defaults-extra-file=xn $dbname < entidades_educativas.sql
mysql --defaults-extra-file=xn $dbname < database-data.sql

echo '
INSERT INTO `users`( `username`, `password`, `email`, `name`, `role`) VALUES 
('"'"''$useradmin''"'"', md5('"'"''$userpass''"'"'), '"'"''$emailadmin''"'"', '"'"''$useradmin''"'"', '"'"''Admin''"'"'),
('"'"''$userapi''"'"', md5('"'"''$userapipass''"'"'), '"'"''''"'"', '"'"''$userapi''"'"', '"'"''Sysacad''"'"');

UPDATE `configuration` SET `value`='"'"''$emailadmin''"'"' WHERE `id`='"'"''EMAIL_SEND''"'"';

' > dbusers.sql

mysql --defaults-extra-file=xn $dbname < dbusers.sql

rm *.sql
rm xn
rm inscripcion.zip
rm Config.php

echo 'Fin del proceso!'

