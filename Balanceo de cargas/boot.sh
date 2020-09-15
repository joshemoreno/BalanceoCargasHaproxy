#!/bin/bash
# echo "instalando LXD"
# sudo snap install lxd
# echo "iniciando grupo LXD"
# sudo lxd init
# echo "creando el contenedor web2"
# lxc init ubuntu:20.04 web2 --target web2
# echo "creando el contenedor backup2"
# lxc init ubuntu:20.04 backup2 --target web2
echo "configurando ip's"
lxc network attach lxdfan0 web2 eth0
lxc config device set web2 eth0 ipv4.address 240.4.100.2
lxc network attach lxdfan0 backup2 eth0
lxc config device set backup2 eth0 ipv4.address 240.4.100.4
echo "Iniciar contenedores"
lxc start web2
lxc start backup2
sleep 50s
echo "instalando servicio apache"
sudo lxc exec web2 -- apt-get install apache2 -y
sudo lxc exec backup2 -- apt-get install apache2 -y
echo "creando index.html"
sudo mkdir web
cd web
sudo touch index.html
sudo echo "<!DOCTYPE html>
<html>
<body>
<h1>Pagina de prueba</h1>
<p>Bienvenidos al contenedor Web2</p>
</body>
</html>" >> index.html
echo "subiendo index.html"
lxc file push index.html web2/var/www/html/index.html
cd ..
echo "creando index.html"
sudo mkdir backup
cd backup
sudo touch index.html
sudo echo "<!DOCTYPE html>
<html>
<body>
<h1>Pagina de prueba</h1>
<p>Bienvenidos al contenedor Backup2</p>
</body>
</html>" >> index.html
echo "subiendo index.html"
lxc file push index.html backup2/var/www/html/index.html
