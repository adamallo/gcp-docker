# gcp-docker
Docker Image for Globus Connect Personal Client

## Starting Up Globus Connect Personal
The dockerfile creates a user called `globus` and run personal connect server
under that user. It expects an environment variable giving the globus setup key.
It also mounts a volume where the endpoint serves it's path from.

1. Build a copy of the image from this repo:
```bash
%  docker build -t gcp-docker .
```

2. Obtain a setup key by visiting: [https://app.globus.org/collections/gcp?generate_key=true](https://app.globus.org/collections/gcp?generate_key=true)
3. Start up the service with the following docker command:
```bash
docker run --rm -v ./mydata:/globusdata -it -e SETUP_KEY="<<<KEY>>>" gcp-docker
```
This will launch the server and register the endpoint with globus.

### Running GCP client on Synology NAS:

1) Install the Docker app on the Synology drive

2) On the registry tab of the Docker app look for meissnert/gcp and download the image

3) launch the image using the wizard and specify a container name, e.g. gcp

4) go to the container, edit and set environmental variables ```USERID``` & ```USER``` to match one of the local users on the NAS

5) on the volume settings specify which folders to share with the container and seth the mount path to ```/home/<USER>/<FOLDERTOSHARE>```

6) go to terminal and run: ```adduser --disabled-password --gecos '' $USER &USERID```

7) `su $USER `

8) ```/opt/globusconnectpersonel/globusconnect -setup <key>```

9) ```opt/globusconnectpersonel/gobusconnect -start &```
