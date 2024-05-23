# pritunl docker 
Run Pritunl in a docker container.

## Features

* Based on alpine linux for small images
* Included docker-compose.yml brings mongo (edit it to not expose the mongo port on the host)

## Building
export _tag=v1.32.3897.75
docker build -t us-central1-docker.pkg.dev/cloudkite-public/docker-images/pritunl:$_tag .
docker push us-central1-docker.pkg.dev/cloudkite-public/docker-images/pritunl:$_tag

## Usage

    git clone https://github.com/cloudkite-io/pritunl-docker
    cd pritunl-docker
    docker-compose up --build

The admin console is now available at `https://<ip>`, `pritunl`/`pritunl`.
  
## Help
Cloudkite is here to help. Feel free to reach out: https://cloudkite.io
