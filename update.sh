#!/bin/sh

wget https://github.com/UTN-FRD/updates/raw/main/v1.0.6.zip

if [ ! -f v1.0.6.zip ]; then
    echo "El archivo de actualización no es correcto."
    exit 1
fi

unzip v1.0.6.zip

mkdir updates/bkp
# resguardo la configuración
cp Modells/Config.php updates/bkp/Config.php

# copio archivos de inscripción
cp -rf updates/inscripcion-frd/* .
cp -rf updates/inscripcion-frd/.[!.]* .
rm -rf updates/inscripcion-frd/
rm -f Modells/Config.php
cp updates/bkp/Config.php Modells/Config.php

# copio archivos de admin
cp -rf updates/inscripcion-admin/* admin
cp -rf updates/inscripcion-admin/.[!.]* admin
rm -rf updates/inscripcion-admin
rm -f admin/Modells/Config.php
cp updates/bkp/Config.php admin/Modells/Config.php

# copio archivos de api
cp -rf updates/inscripcion-api/* api
cp -rf updates/inscripcion-api/.[!.]* api
rm -rf updates/inscripcion-api
rm -f api/Modells/Config.php
cp updates/bkp/Config.php api/Modells/Config.php

# verifico si actualizo la base de datos
if [ -f updates/update.sql ]; then
    dbuser=$(sed -n '/$dbuser = / s/.*\= '"'"'*//p' updates/bkp/Config.php | cut -d\' -f 1)
    dbpass=$(sed -n '/$dbpass = / s/.*\= '"'"'*//p' updates/bkp/Config.php | cut -d\' -f 1)
    dbname=$(sed -n '/$dbname = / s/.*\= '"'"'*//p' updates/bkp/Config.php | cut -d\' -f 1)
    dbhost=$(sed -n '/$dbhost = / s/.*\= '"'"'*//p' updates/bkp/Config.php | cut -d\' -f 1)

    echo '
    [client]
    user='$dbuser'
    password='$dbpass'

    ' > xn

    mysql --defaults-extra-file=xn -h $dbhost $dbname < updates/update.sql
    
    rm updates/*.sql
    rm xn
fi

rm -rf updates/bkp
rm -rf updates
rm v1.0.6.zip
