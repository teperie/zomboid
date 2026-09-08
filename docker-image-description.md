# Project Zomboid Dedicated Server

Docker image for running a [Project Zomboid](https://projectzomboid.com/) Dedicated Server.

The server automatically checks for updates through SteamCMD whenever the container starts.

---

## Quick Start

Run:

```bash
docker run -d \
  --name pzserver \
  -p 16261:16261/udp \
  -p 16262:16262/udp \
  -e SERVER_NAME=servertest \
  -e ADMIN_USERNAME=admin \
  -e ADMIN_PASSWORD=change-this-password \
  skytuna/zomboid
```

---

## Features

* Automatic server updates on container startup
* Persistent server configuration and save data
* Persistent mod data
* Optional custom JVM configuration

---

## Requirements

* Docker
* Docker Compose (optional)
* Sufficient system memory for your server configuration

---

## How to Use

### Using Docker Compose

1. Create a directory for your server.

2. Create a `docker-compose.yml` file inside the directory.

3. Add the following configuration:

```yaml
services:
  pzserver:
    image: skytuna/zomboid
    container_name: pzserver

    tty: true
    stdin_open: true

    environment:
      # Server initialization
      SERVER_NAME: 'servertest'
      ADMIN_USERNAME: 'admin'
      ADMIN_PASSWORD: 'change-this-password'

      # Additional server startup parameters
      # OPTS: "-port 12345"

    ports:
      - '16261:16261/udp'
      - '16262:16262/udp'

    volumes:
      - ./settings:/root/Zomboid/Server
      - ./saves:/root/Zomboid
      - ./mods:/pzserver/steamapps

      # Optional: custom JVM configuration
      # - ./ProjectZomboid64.json:/pzserver/ProjectZomboid64.json
      # - ./ProjectZomboid32.json:/pzserver/ProjectZomboid32.json

    restart: unless-stopped
```

### Environment Variables

#### `SERVER_NAME`

The name of your server.

This determines the names of server configuration files and save data.

For example:

```text
SERVER_NAME: 'servertest'
```

will use configuration files such as:

```text
servertest.ini
servertest_SandboxVars.lua
```

#### `ADMIN_USERNAME`

Username for the administrator account created during server initialization.

#### `ADMIN_PASSWORD`

Password for the administrator account.

**Change the default password before starting a public server.**

#### `OPTS`

Additional Project Zomboid server startup parameters.

For example:

```yaml
OPTS: "-port 12345"
```

See the [Project Zomboid Startup Parameters](https://pzwiki.net/wiki/Startup_parameters#Server) documentation for available parameters.

---

## Volumes

### `settings`

```yaml
- ./settings:/root/Zomboid/Server
```

Stores server configuration files.

You can place files such as:

```text
settings/
├── servertest.ini
├── servertest_SandboxVars.lua
└── ...
```

The server name should match `SERVER_NAME`.

For example:

```yaml
SERVER_NAME: 'myserver'
```

should use:

```text
myserver.ini
myserver_SandboxVars.lua
```

### `saves`

```yaml
- ./saves:/root/Zomboid
```

Stores persistent multiplayer server save data.

Because the data is stored on the host, it remains available when the container is recreated or removed.

**Back up this directory before major server changes or Project Zomboid version updates.**

### `mods`

```yaml
- ./mods:/pzserver/steamapps
```

Stores mod-related data used by the server.

This prevents the mod data from being downloaded again whenever the container is recreated.

The entire `steamapps` directory is used for this purpose and should not be changed to a different mount path.

---

## Starting the Server

From the directory containing `docker-compose.yml`, run:

```sh
docker compose up -d
```

On startup, the container:

1. Checks the installed Project Zomboid server files.
2. Updates them through SteamCMD if a newer version is available.
3. Starts the dedicated server.

The first startup may take some time because the server files need to be downloaded.

---

## Automatic Server Updates

The container runs SteamCMD every time it starts:

```text
steamcmd
    ↓
Check for Project Zomboid updates
    ↓
Update if necessary
    ↓
Start server
```

Therefore, rebuilding the Docker image is normally **not required just because Project Zomboid has released a new server version**.

To update an existing server, recreate the container:

```sh
docker compose down
docker compose up -d
```

The persistent `settings`, `saves`, and `mods` directories are not removed by this operation.

---

## Custom JVM Configuration

The Project Zomboid server installation already contains JVM configuration files such as:

```text
/pzserver/ProjectZomboid64.json
/pzserver/ProjectZomboid32.json
```

These files can be mounted from the host when you want to customize JVM options such as memory allocation.

### Getting the Default JVM Configuration

You can copy the file from the running container:

```sh
docker cp pzserver:/pzserver/ProjectZomboid64.json ./ProjectZomboid64.json
```

For 32-bit:

```sh
docker cp pzserver:/pzserver/ProjectZomboid32.json ./ProjectZomboid32.json
```

Edit the copied file as needed.

For example:

```text
-Xmx8g
```

sets the maximum Java heap size to 8 GB.

* `-Xms`: Initial/minimum heap size
* `-Xmx`: Maximum heap size

### Enabling the Custom Configuration

After modifying the JSON file, uncomment the corresponding volume in `docker-compose.yml`:

```yaml
volumes:
  - ./ProjectZomboid64.json:/pzserver/ProjectZomboid64.json
```

or:

```yaml
volumes:
  - ./ProjectZomboid32.json:/pzserver/ProjectZomboid32.json
```

Then recreate the container:

```sh
docker compose down
docker compose up -d
```

### Important: Project Zomboid Updates

The JVM JSON files are part of the Project Zomboid server installation and may change when the server is updated.

If you keep a customized JSON file mounted from the host, it **overrides the corresponding file inside the container**.

Therefore, after a major Project Zomboid update:

1. Get the new default JSON from the updated container.
2. Compare it with your customized JSON.
3. Reapply your custom JVM settings to the new file.
4. Keep the updated file mounted through `docker-compose.yml`.

For example:

```sh
docker cp pzserver:/pzserver/ProjectZomboid64.json ./ProjectZomboid64.json
```

Then reapply your custom `-Xmx` and other changes.

This prevents an old JVM configuration from becoming incompatible with a newer Project Zomboid server version.

---

## Managing the Server

### View Logs

```sh
docker compose logs --tail=20 -f pzserver
```

* `--tail=20`: Displays the last 20 lines.
* `-f`: Continuously displays new log entries.

Press `Ctrl + C` to stop viewing the logs. This does not stop the server.

### In-Game Command Input

```sh
docker attach pzserver
```

This attaches to the running server console and allows you to enter server commands.

To detach without stopping the container:

```text
Ctrl + P
Ctrl + Q
```

### Restart the Server

```sh
docker compose restart
```

Use this when the server needs to be restarted, such as after certain configuration or mod changes.

### Stop the Server

```sh
docker compose down
```

This stops and removes the container.

Persistent data stored in the mounted directories remains intact.

---

## Updating Mods

When a mod is updated, the server must be restarted to ensure that the server and clients are using the same mod version.

To restart the server:

```sh
docker compose restart
```

Mod-related data is stored in the persistent `mods` directory.

---

## Backups

Before major Project Zomboid updates or significant configuration changes, back up:

```text
settings/
saves/
mods/
```

---

## Troubleshooting

### Server does not start after a Project Zomboid update

Check the server logs:

```sh
docker compose logs --tail=100 pzserver
```

If you use a custom JVM JSON file, check whether the file is compatible with the newly updated server installation.

You can obtain the current default file with:

```sh
docker cp pzserver:/pzserver/ProjectZomboid64.json ./ProjectZomboid64.json
```

Compare it with your customized configuration and update your custom file if necessary.

### Resetting a server's save data

Do not delete server data without making a backup first.

The server save data is stored under:

```text
./saves/
```

Removing this data can permanently remove your existing server world and progress.

---

Happy Surviving!
