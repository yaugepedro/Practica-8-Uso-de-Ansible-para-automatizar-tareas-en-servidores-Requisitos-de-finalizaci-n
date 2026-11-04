# Práctica 8: Automatizar servidores con Ansible

Hecha por Yauge Pedro Volquez Terrero.

## De qué trata

No tengo servidores en la nube, así que usé Docker para crear 5 servidores Ubuntu falsos (contenedores con SSH). Después usé Ansible desde mi PC para conectarme a los 5 a la vez y hacerles las mismas tareas automáticamente, sin entrar a uno por uno.

## Lo que usé

- Windows con WSL (Ubuntu)
- Docker Desktop
- Ansible y sshpass, instalados en Ubuntu con `sudo apt install -y ansible sshpass`

## Qué hay en este repositorio

- `Dockerfile`: crea la imagen de Ubuntu con SSH y python3. Tiene el usuario `ansible` con password `ansible` y permisos sudo sin password.
- `docker-compose.yml`: levanta 5 servidores (`server1` a `server5`) usando esa imagen.
- `inventario.ini`: dice a qué servidores se conecta Ansible y con qué usuario y clave.
- `ansible.cfg`: le indica a Ansible dónde está el inventario y le quita la advertencia de SSH.
- `playbook.yml`: las tareas que se ejecutan en cada servidor.

## Los servidores

Cada servidor tiene su IP dentro de la red de Docker y un puerto distinto en mi PC:

- server1: 172.20.0.11, puerto 2221
- server2: 172.20.0.12, puerto 2222
- server3: 172.20.0.13, puerto 2223
- server4: 172.20.0.14, puerto 2224
- server5: 172.20.0.15, puerto 2225

En el inventario puse `127.0.0.1` con el puerto de cada uno, porque desde WSL no pude llegar directo a las IPs de los contenedores.

## Cómo lo ejecuté

Primero levanté los servidores:

    docker compose up -d --build

Revisé que los 5 estuvieran corriendo:

    docker ps

Probé que Ansible pudiera hablar con todos (tienen que salir 5 SUCCESS):

    ansible servidores -m ping

Y ejecuté el playbook:

    ansible-playbook playbook.yml

## Qué hace el playbook

1. Actualiza el cache de APT.
2. Crea el usuario `itla`.
3. Crea la carpeta `app` dentro de `/home/itla`.
4. Crea el archivo `hola.txt` dentro de esa carpeta.
5. Instala `cowsay` y `htop`.

## Cómo comprobé que funcionó

    ansible servidores -b -a "cat /home/itla/app/hola.txt"
    ansible servidores -b -a "ls -l /home/itla/app"
    ansible servidores -a "id itla"
    ansible servidores -a "/usr/games/cowsay Hola"
    ansible servidores -a "which htop"

A los primeros dos les puse `-b` porque la carpeta de `itla` no la puede leer el usuario `ansible`. Sin eso salía "Permission denied".

## Resultado

El playbook terminó con `failed=0` en los 5 servidores. Cada uno tiene su `hola.txt` que dice "Hola desde serverN", el usuario `itla` y las dos aplicaciones instaladas. Cuando lo corrí una segunda vez no cambió nada, porque Ansible ya veía todo hecho.

## Para apagar todo

    docker compose down
