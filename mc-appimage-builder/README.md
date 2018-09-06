# Moolticute docker for building AppImage

This docker is used by to build/package moolticute for AppImage (Linux)

# Usage

Download the latest image from docker hub
```bash
➜ docker pull mooltipass/mc-appimage-builder
Using default tag: latest
latest: Pulling from mooltipass/mc-appimage-builder
Digest: sha256:5c7be97f9d27853455d96d05cedcacbe89b276706e21cdc9a9ed67047e598ff3
Status: Image is up to date for mooltipass/mc-appimage-builder:latest
```

Clone the moolticute source repository somewhere on you hdd.
```bash
➜ git clone https://github.com/mooltipass/moolticute
[...]
```

Then you need to tell docker where to map the source code of moolticute.

Start the docker
```bash
➜ docker run -t --name appimage-builder -d -v ABSOLUTE_PATH_TO_YOUR_SRC/moolticute:/moolticute mooltipass/mc-appimage-builder
8aa6768f752515f8f9a7a3c82213813225aea7ef950799e065e7426b296d6902
```

The docker is running, you can check with:
```bash
➜ docker ps
CONTAINER ID IMAGE        COMMAND     CREATED        STATUS  PORTS   NAMES
8aa6768f7525 a1c24aecf093 "/bin/bash" 36 seconds ago Up 33 seconds   appimage-builder
```

Now it's time to start the build:
```bash
➜ docker exec appimage-builder /bin/bash /scripts/build.sh
[...]
```

And finally to create the packages:
```bash
➜ docker exec appimage-builder /bin/bash /scripts/package.sh
[...]
```

AppImage file is now available in your moolticute source dir (in the build-appimage folder)
