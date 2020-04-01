## Provisioning Camunda on Cloud Run + Cloud SQL, using Terraform and Cloud Build

Terraform receipe for running Camunda BPMN workflow engine serverlessly on Cloud Run, using Cloud SQL as the backing store. Custom image building offloaded to Cloud Build. Private container image hosting in Google Container Engine.

Customize the base image in the main.tf locals.

Read more on the blog
- [Provisioning Serverless Camunda on Cloud Run](https://www.futurice.com/blog/serverless-camunda-terraform-recipe-using-cloud-run-and-cloud-sql) 
- [Call external services with at-least-once delevery](https://www.futurice.com/blog/at-least-once-delivery-for-serverless-camunda-workflow-automation)


    #Camunda # Cloud Run #Cloud SQL #Cloud Build #Container Registry #Docker

### Terraform setup

Create service account credentials for running terraform locally. Then

    export GOOGLE_CREDENTIALS=<PATH TO SERVICE ACCOUNT JSON CREDS>
    gcloud auth activate-service-account --key-file $GOOGLE_CREDENTIALS
    terraform init


Terraform service account, Editor role was not enough
  - to set cloud run service to noauth, had to add Security Admin on camunda cloud run resource (NOT PROJECT level)

### Docker / gcloud Setup

For mac I needed to expose the docker deamon on a tcp port:-

    docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 127.0.0.1:1234:1234 bobrik/socat TCP-LISTEN:1234,fork UNIX-CONNECT:/var/run/docker.sock

Then in bash_profile:

    export DOCKER_HOST=tcp://localhost:1234

Also needed to setup GCR creds in docker

    gcloud auth configure-docker
