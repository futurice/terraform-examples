Getting started

    export GOOGLE_CREDENTIALS=<PATH TO SERVICE ACCOUNT JSON CREDS>
    gcloud auth activate-service-account --key-file $GOOGLE_CREDENTIALS
    terraform init

Note you need to switch on the App Engine API (dependancy of Cloud Scheduler), choose wisely, this is irreversable. The region CANNOT be changed.

Shut down memorystore

    terraform destroy -target module.memorystore.google_redis_instance.cache



