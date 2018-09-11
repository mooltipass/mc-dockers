# Moolticute docker for building ubuntu deb packages

This docker is used by to prepare moolticute source for uploading on Launchpad.

# Usage

Download the latest image from docker hub
```bash
➜ docker pull mooltipass/mc-launchpad
Using default tag: latest
latest: Pulling from mooltipass/mc-launchpad
Digest: sha256:5c7be97f9d27853455d96d05cedcacbe89b276706e21cdc9a9ed67047e598ff3
Status: Image is up to date for mooltipass/mc-launchpad:latest
```

Clone the moolticute source repository somewhere on you hdd. You will also need to put the GPG key files in this folder.
```bash
➜ mkdir workdir && cd workdir
➜ git clone https://github.com/mooltipass/moolticute moolticute-1.2.3
➜ touch gpgkey_pub.asc  # public gpg key
➜ touch gpgkey_sec.asc  # private key
➜ touch passphrase.txt  # passphrase for the secret key
```

Then you need to tell docker where to map the source code of moolticute.

Start the docker
```bash
➜ docker run -t --name mc-deb -d -v ABSOLUTE_PATH_TO_YOUR_WORKDIR:/moolticute mooltipass/mc-launchpad
f0b28a4f15e940968a317dbb6427a4aef0e869d4d3553fe0d30592c97457882d
```

The docker is running, you can check with:
```bash
➜ docker ps
CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
f0b28a4f15e9 mooltipass/mc-launchpad "/start.sh /start" About a minute ago Up About a minute mcbuilder
```

Now it's time to start the build for all ubuntu version you need:
```bash
➜ docker exec mc-deb bash /scripts/build_source.sh 1.2.3 cosmic
➜ docker exec mc-deb bash /scripts/build_source.sh 1.2.3 bionic
➜ docker exec mc-deb bash /scripts/build_source.sh 1.2.3 xenial
[...]
```

Sources packages (*.changes) and sources are uploaded to launchpad automatically

