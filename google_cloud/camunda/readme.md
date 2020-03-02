
For mac I needed to expose the docker deamon on a tcp port:-

    docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 127.0.0.1:1234:1234 bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock

Then in bash_profile:

    export DOCKER_HOST=tcp://localhost:1234

Also needed to setup GCR creds in docker

    gcloud auth configure-docker

Editor role was not enough to provision network, add Service Network Admin Role as well


// Note sure of the following
Editor role was not enough on default compute service account, added Cloud SQL Client