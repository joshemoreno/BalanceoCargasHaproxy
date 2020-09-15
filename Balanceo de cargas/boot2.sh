#!/bin/bash
# echo "instalando LXD"
# sudo snap install lxd
# echo "iniciando grupo LXD"
# sudo lxd init
# echo "creando el contenedor web1"
# lxc init ubuntu:20.04 web1 --target web1
# echo "creando el contenedor backup1"
# lxc init ubuntu:20.04 backup1 --target web1
echo "configurando ip's"
lxc network attach lxdfan0 web1 eth0
lxc config device set web1 eth0 ipv4.address 240.3.100.3
lxc network attach lxdfan0 backup1 eth0
lxc config device set backup1 eth0 ipv4.address 240.3.100.5
echo "Iniciar contenedores"
lxc start web1
lxc start backup1
sleep 50s
echo "instalando servicio apache"
sudo lxc exec web1 -- apt-get install apache2 -y
sudo lxc exec backup1 -- apt-get install apache2 -y
echo "creando index.html"
sudo mkdir web
cd web
sudo touch index.html
sudo echo "<!DOCTYPE html>
<html>
<body>
<h1>Pagina de prueba</h1>
<p>Bienvenidos al contenedor Web1</p>
</body>
</html>" >> index.html
echo "subiendo index.html"
lxc file push index.html web1/var/www/html/index.html
cd ..
echo "creando index.html"
sudo mkdir backup
cd backup
sudo touch index.html
sudo echo "<!DOCTYPE html>
<html>
<body>
<h1>Pagina de prueba</h1>
<p>Bienvenidos al contenedor Backup1</p>
</body>
</html>" >> index.html
echo "subiendo index.html"
lxc file push index.html backup1/var/www/html/index.html
