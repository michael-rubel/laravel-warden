## Środowisko deweloperskie Laravel z użyciem Docker Warden 
- Docs: https://docs.warden.dev/

### Serwisy Warden:
- traefik
- tunnel
- dnsmasq
- portainer
- mailhog

### Serwisy środowiskowe:
- nginx
- php-fpm
- postgres
- redis

### Proces instalacyjny oraz dodatkowe instrukcje
- Docker Desktop 2.2.0.0+: https://docs.docker.com/docker-for-windows/install/
- Docker Compose 1.25.0+: https://docs.docker.com/compose/install/
- Jeśli korzystamy z MacOS i potrzebujemy sync'u sesji, to instalujemy dodatkowo Mutagen 0.11.4+: https://mutagen.io/
- Jeśli korzystamy z Windows 10, włączmy WSL 2 i zainstalujmy Ubuntu 18.04: https://docs.microsoft.com/en-us/windows/wsl/install-win10
- Jeśli zainstalowało Ubuntu z WSL 1, konwertujmy to do WSL 2 za pomocą polecenia `wsl --set-version Ubuntu-18.04 2` z CMD lub PowerShell.
- Instalujmy Warden'a:
```sh
$ sudo mkdir /opt/warden
$ sudo chown $(whoami) /opt/warden
$ git clone -b master https://github.com/davidalger/warden.git /opt/warden
$ echo 'export PATH="/opt/warden/bin:$PATH"' >> ~/.bashrc
$ PATH="/opt/warden/bin:$PATH"
$ warden svc up
```
- Zróbmy `git clone https://github.com/mr-observer/warden_build` domyślnego srodowiska (demo) i otwórzmy w osobnym oknie.
- Wejdźmy do folderu projektu.
- Dodajmy zmienne `WARDEN_*` z pliku `.env` środowiska do pliku `.env` projektu. Zauważ, że zmienne Laravela, np. `APP_URL` też znajdują się w tym pliku. Dodatkowo możemy wskazać wersje serwisów, np. `PHP_VERSION` lub `REDIS_VERSION`. Folder `.warden` dodajmy do `.gitignore` projektu.
- Aby uruchomić proces instalacyjny środowiska, dajmy `warden bootstrap`.
- Po skończeniu wykonania skryptu instalacyjnego, musimy skopiować plik certyfikatu SSL pod adresem `~/.warden/ssl/rootca/certs/ca.cert.pem` i zaimportować do ustawień SSL przeglądarki. Ścieżka będzie mniej więcej podobna: `Settings > Security > Manage Certificates`. Bardzo ważne tutaj jest to, żeby wygenerowało certyfikat z poprawną domeną wirtualną (polecenie `warden bootstrap` robi to automatycznie), ale jeśli pominęłiśmy ten etap lub chcemy zmienić konfigurację projektu (zmienia się domena) to musimy wygenerować certyfikat ponownie, np. `warden sign-certificate laravel.test` i potem zaktualizować to w przeglądarce. 
- Dla użytkowników Windows 10 trzeba dodatkowo dodawać domeny/subdomeny wirtualne do pliku `/etc/hosts`, jako np: `127.0.0.1 app.laravel.test`. Można korzystać np. z HostsFileEditor: https://hostsfileeditor.com/
- Jeśli na Linux nie udaje się wejść na domenę, wskazanego w `.env`, dodajmy adres `nameserver 127.0.0.1` do `pliku /etc/resolv.conf`.
- Żeby połączyć się do bazy z narzędzia zewnętsznego, musimy wybrać kontener bazy za pomocą `warden env ps` oraz użyć `ssh user@tunnel.warden.test -p 2222` z private key'em, pobranym z `/<USER>/.warden/tunnel/ssh_key`

### Polecenia konsolowe Warden
| Polecenie | Opis |
| ------ | ------ |
| `warden svc up` | Uruchomienie serwisów Warden. |
| `warden svc down` | Wyłączenie serwisów Warden. |
| `warden bootstrap` | Uruchomienie środowiska i generacja certyfikatów SSL dla domeny. |
| `warden sign-certificate <domain>` | Generacja certyfikatu SSL dla domeny. |
| `warden shell` | Zalogować się do kontenera `php-fpm` do pracy z `bin/magento` lub dowolnym innym narzędziem. |
| `warden exec <container>` | Uruchomić polecenie na wybranym kontenerze. |
| `warden env up -d` | Uruchomić środowisko. |
| `warden env down` | Wyłączyć środowisko wraz z usunięciem kontenerów. |
| `warden env start` | Włączyć środowisko bez usunięcia kontenerów. |
| `warden env stop` | Wyłączyć środowisko bez usunięcia kontenerów. |
