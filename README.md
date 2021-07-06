## Ready Docker Warden environment for a Laravel Developer with Postgres
<p align="center">
    <img alt="PHP 8" src="https://img.shields.io/badge/PHP-8.x-8892BF?style=for-the-badge&logo=php">
    <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-13.x-336791?style=for-the-badge&logo=postgresql&logoColor=white">
    <img alt="Redis" src="https://img.shields.io/badge/Redis-6.x-a51f17?style=for-the-badge&logo=redis&logoColor=white">
</p>

### Installation
- Docker Desktop 2.2.0.0+: https://docs.docker.com/docker-for-windows/install/
- Docker Compose 1.25.0+: https://docs.docker.com/compose/install/
- If we use MacOS then we additionally need Mutagen 0.11.4+: https://mutagen.io/
- If we use Windows 10, enable WSL 2 and install Ubuntu 20.04: https://docs.microsoft.com/en-us/windows/wsl/install-win10
- If you have installed your Ubuntu with WSL 1, convert it to WSL 2 using `wsl --set-version Ubuntu-VV.04 2` with CMD or PowerShell.
- Install Warden:
```sh
$ sudo mkdir /opt/warden
$ sudo chown $(whoami) /opt/warden
$ git clone -b master https://github.com/davidalger/warden.git /opt/warden
$ echo 'export PATH="/opt/warden/bin:$PATH"' >> ~/.bashrc
$ PATH="/opt/warden/bin:$PATH"
$ warden svc up
```
- Run `git clone https://github.com/michael-rubel/laravel_warden` to clone the environment files to a separate folder.
- `cd` to the folder with the project.
- Add `WARDEN_*` to the `.env` file in the project folder. Take in mind that environment variables needed by Laravel, e.g. `APP_URL` exist in the same `.env` file too. Additionally, we can specify version of the services we need, e.g. `PHP_VERSION` or `REDIS_VERSION`. `.warden` and `.postgres` folders should be added to `.gitignore` of the project.
- Run `warden bootstrap` to get the environment ready.
- After bootstrap is finished we should import the certificate file  `~/.warden/ssl/rootca/certs/ca.cert.pem` to trusted SSL's in the browser to join local projects. Important thing is that we need the certificate generated for a specific domain (the `warden bootstrap` do it for us automatically), but if we missed that step or changed the domain, we need to manually regenerate the certificate, i.e. `warden sign-certificate laravel.test`. 
- For Windows 10 users we should additionally add the domains to the `/etc/hosts`, i.e: `127.0.0.1 app.laravel.test`. You can use open-source HostsFileEditor: https://hostsfileeditor.com/
- If you can't join the domain after complete installation, add the `nameserver 127.0.0.1` mapping to `/etc/resolv.conf`. Some distributions do not use loopback as a resolver by default.
- If you need to join the service from the external tools like PHPStorm, we should choose the container name with `warden env ps` and use `ssh user@tunnel.warden.test -p 2222` with the private key that you can get from `/<USER>/.warden/tunnel/ssh_key`

### Warden services:
- traefik
- tunnel
- dnsmasq
- portainer
- mailhog

### Environment services:
- nginx
- php-fpm
- postgres
- redis

### Commandline Warden
| Command | Description |
| ------ | ------ |
| `warden svc up` | Run Warden services. |
| `warden svc down` | Disable Warden services. |
| `warden bootstrap` | Run environment build an SSL certificate generation for the domain. |
| `warden sign-certificate <domain>` | Generate SSL for specific domain. |
| `warden shell` | Log in to container `php-fpm` to work with `artisan`, `composer`, etc. |
| `warden exec <container>` | Run command on the container. |
| `warden env up -d` | Run the environment. |
| `warden env down` | Shutdown the environment. |

- Warden Docs: https://docs.warden.dev/
