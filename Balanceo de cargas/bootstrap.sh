#!/usr/bin/env bash
# echo "instalando LXD"
# sudo snap install lxd
# echo "iniciando grupo LXD"
# sudo lxd init
lxc network set lxdfan0 fan.underlay_subnet=192.168.100.0/24
# echo "creando el contenedor haproxy"
# lxc init ubuntu:20.04 haproxy --target haproxy
echo "configurando ip's"
lxc network attach lxdfan0 haproxy eth0
lxc config device set haproxy eth0 ipv4.address 240.2.100.1
echo "Iniciar contenedores"
lxc start haproxy
sleep 50s
echo "instalando servicio haproxy"
sudo lxc exec haproxy -- apt-get install haproxy -y
echo "editando configuracion haproxy"
echo "global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL). This list is from:
        #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
        # An alternative list with additional directives can be obtained from
        #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

backend web-backend
   balance roundrobin
   stats enable
   stats auth admin:admin
   stats uri /haproxy?stats

   option allbackups
   server web1 240.3.100.3:80 check
   server web2 240.4.100.2:80 check
   server backup1 240.3.100.5:80 check backup
   server backup2 240.4.100.4:80 check backup

frontend http
  bind *:80
  default_backend web-backend" >> haproxy.cfg
lxc file push haproxy.cfg haproxy/etc/haproxy/haproxy.cfg
sudo lxc exec haproxy -- systemctl restart haproxy
lxc config device add haproxy http proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
echo "<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mantenimiento</title>
    <link rel="stylesheet" href="styles.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css"
        integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@700&display=swap" rel="stylesheet">
<style>
    body{
        background-color:white;
    }
    .jumbotron{
        color: white !important;
        margin-top:10% !important;
        background-color: #b31d1d !important;
    }
    .display-4{
        font-family: nunito !important;
        font-weight: bold !important;
    }
    .lead{
        font-family: nunito !important;
        font-weight: bolder !important;
    }
    .navbar {
        color: white !important;
        background-color: #b31d1d !important;
    }
    span{
        font-weight: bold !important;
        font-family: nunito !important;
    }
    .form-control{
        background-color: #b31d1d !important;
        color: white !important;
        border: hidden !important;
        font-size: 20px !important;
        font-family: nunito !important;
    }
</style>
</head>

<body onload="mueveReloj()">
    <nav class="navbar ">
        <span class="navbar-brand mb-0 h1">Bienvenidos a nuestra web</span>
    </nav>
    <div class="jumbotron container">
        <div class="container">
            <h1 class="display-4">Disculpe las molestias</h1>
            <p class="lead">En este momento no estamos en servicio pero nuestro equipo ya esta trabajando en restablecer el servicio</p>
            <form name="form_reloj" class="reloj">
                <input class="rel form-control lead" type="text" name="reloj" size="60">
            </form>
        </div>
    </div>
    <title>Reloj con Javascript</title>
    <script language="JavaScript">
        function mueveReloj() {
            momentoActual = new Date()
            hora = momentoActual.getHours()
            minuto = momentoActual.getMinutes()
            segundo = momentoActual.getSeconds()
            var restante1 = -hora + 20;
            var restante2 = -minuto + 60;
            var restante3 = -segundo + 60;
            horaImprimible = "Vuelve en aproximadamente: " + restante1 + "h " + restante2 + "m " + restante3 + "s"
            document.form_reloj.reloj.value = horaImprimible
            setTimeout("mueveReloj()", 1000)
        }
    </script>
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"
        integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj"
        crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"
        integrity="sha384-9/reFTGAW83EW2RDu2S0VKaIzap3H66lZH81PoYlFhbGU+6BZp6G7niu735Sk7lN"
        crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"
        integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV"
        crossorigin="anonymous"></script>

</html>" >> 503.http
lxc file push 503.http haproxy/etc/haproxy/errors/503.http
sudo lxc exec haproxy -- systemctl restart haproxy





