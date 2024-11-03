# Introduction

This is Docker image for running Project Zomboid Dedicated Server.

# How to Use

## Using docker-compose

1. Create a directory for your server files.
2. Inside that directory, create a `docker-compose.yml` file.
3. Copy and paste the following configuration into the `docker-compose.yml` file:

   ```yaml
   services:
     pzserver:
       image: skytuna/zomboid
       container_name: pzserver
       tty: true
       stdin_open: true
       environment:
         # Modify below to configure the server initialization.
         SERVER_NAME: 'servertest'
         ADMIN_USERNAME: 'admin'
         ADMIN_PASSWORD: 'admin'
         # Other server parameters.
         # OPTS: "-port 12345"
       ports:
         - '16261:16261/udp'
         - '16262:16262/udp'
       volumes:
         - ./settings:/root/Zomboid/Server
         - ./saves:/root/Zomboid/Saves/Multiplayer
         - ./mods:/pzserver/steamapps
         # Uncomment the line below after creating the new JVM option.
         # - ./ProjectZomboid64.json:/pzserver/ProjectZomboid64.json
         # - ./ProjectZomboid32.json:/pzserver/ProjectZomboid32.json
       restart: unless-stopped
   ```

   ### Environments

   - `SERVER_NAME`: The name of your server. Configuration files will be created with this name, such as `servertest.ini`, `servertest_SandboxVars.lua`, etc.
   - `ADMIN_USERNAME` : The server will automatically create default `admin` user. This sets username to replace `admin`.
   - `ADMIN_PASSWORD` : The password for the `admin` user.
   - `OPTS` : Other server parameters. See [PZWiki Startup Parameters](https://pzwiki.net/wiki/Startup_parameters#Server).

   ### Volumes

   - `settings`: Configuration files.
   - `saves`: Server data.
   - `mods`: Data for any mods you are using. This prevents the mod data from being downloaded each time the server restarts.

---

## Mounting Server Configuration Files (Optional)

1. Create a directory named `settings` in your working directory.
2. Place your server configuration files (`YOUR_SERVER_NAME.ini`, `YOUR_SERVER_NAME_SandboxVars.lua`, etc.) into the `settings` directory.
3. Update `SERVER_NAME` in the `docker-compose.yml` file to match your server’s name.

---

## Expanding Server Memory Size (Optional)

1. Create a `ProjectZomboid64.json` or `ProjectZomboid32.json` based on your system (or both; the server will automatically detect them).
2. Copy and paste the following content.

   for 64bit:

   ```json
   {
     "mainClass": "zombie/network/GameServer",
     "classpath": [
       "java/.",
       "java/istack-commons-runtime.jar",
       "java/jassimp.jar",
       "java/javacord-2.0.17-shaded.jar",
       "java/javax.activation-api.jar",
       "java/jaxb-api.jar",
       "java/jaxb-runtime.jar",
       "java/lwjgl.jar",
       "java/lwjgl-natives-linux.jar",
       "java/lwjgl-glfw.jar",
       "java/lwjgl-glfw-natives-linux.jar",
       "java/lwjgl-jemalloc.jar",
       "java/lwjgl-jemalloc-natives-linux.jar",
       "java/lwjgl-opengl.jar",
       "java/lwjgl-opengl-natives-linux.jar",
       "java/lwjgl_util.jar",
       "java/sqlite-jdbc-3.27.2.1.jar",
       "java/trove-3.0.3.jar",
       "java/uncommons-maths-1.2.3.jar",
       "java/commons-compress-1.18.jar"
     ],
     "vmArgs": [
       "-Djava.awt.headless=true",
       "-Xmx8g",
       "-Dzomboid.steam=1",
       "-Dzomboid.znetlog=1",
       "-Djava.library.path=linux64/:natives/",
       "-Djava.security.egd=file:/dev/urandom",
       "-XX:+UseZGC",
       "-XX:-OmitStackTraceInFastThrow"
     ]
   }
   ```

   for 32bit:

   ```json
   {
     "mainClass": "zombie/network/GameServer",
     "classpath": [
       "java/.",
       "java/istack-commons-runtime.jar",
       "java/jassimp.jar",
       "java/javacord-2.0.17-shaded.jar",
       "java/javax.activation-api.jar",
       "java/jaxb-api.jar",
       "java/jaxb-runtime.jar",
       "java/lwjgl.jar",
       "java/lwjgl-natives-linux.jar",
       "java/lwjgl-glfw.jar",
       "java/lwjgl-glfw-natives-linux.jar",
       "java/lwjgl-jemalloc.jar",
       "java/lwjgl-jemalloc-natives-linux.jar",
       "java/lwjgl-opengl.jar",
       "java/lwjgl-opengl-natives-linux.jar",
       "java/lwjgl_util.jar",
       "java/sqlite-jdbc-3.27.2.1.jar",
       "java/trove-3.0.3.jar",
       "java/uncommons-maths-1.2.3.jar",
       "java/commons-compress-1.18.jar"
     ],
     "vmArgs": [
       "-Djava.awt.headless=true",
       "-Xms768m",
       "-Xmx768m",
       "-Dzomboid.steam=1",
       "-Dzomboid.znetlog=1",
       "-Djava.library.path=linux32/:natives/",
       "-Djava.security.egd=file:/dev/urandom",
       "-XX:+UseG1GC",
       "-XX:-OmitStackTraceInFastThrow"
     ]
   }
   ```

3. Modify the `-Xmx8g` setting in `vmArgs` section. Here, `-Xmx` specifies the maximum heap memory, and `8g` denotes 8GB. (`-Xms`: minimum heap memory, `768m`: 768MB)
4. Uncomment the corresponding `./ProjectZomboid64...` lines in the `docker-compose.yml.`

---

## Starting Server

After setting up, navigate to the directory in your terminal and run:

```sh
docker-compose up -d
```

This command will start the server in detached mode.  
  
Now your server is up and running! Check the logs for any issues.

---

## Managing Server

### View Logs

To view the logs while the server is running, run:

```sh
docker-compose logs --tail=20 -f pzserver
```

- `--tail`: Specifies the number of lines to display from the end of the logs (in this case, the last 20 lines).
- `-f`: Follows the log output in real-time, displaying new log entries as they are generated. Press `Ctrl + C` to exit.

### In-Game Command Input

To input in-game commands, use the following command:

```sh
docker attach pzserver
```

- This command allows you to attach to the running `pzserver` container, enabling you to enter commands directly into the game.
- Note: To detach from the container without stopping it, press `Ctrl + P`, then `Ctrl + Q`.

### Restart Server

To restart the server for reasons such as a mods update, run:

```sh
docker-compose restart
```

### Stop Server

```sh
docker-compose down
```

---

Happy Surviving!
