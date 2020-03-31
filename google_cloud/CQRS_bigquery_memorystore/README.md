## CQRS Bigquery Memorystore Timeseries Analytics with Self Testing Example

Read [https://www.futurice.com/blog/bigquery-to-memorystore](Exporting Bigquery results to memorystore)

### Getting started

    export GOOGLE_CREDENTIALS=<PATH TO SERVICE ACCOUNT JSON CREDS>
    gcloud auth activate-service-account --key-file $GOOGLE_CREDENTIALS
    terraform init

Note you need to switch on the App Engine API (dependancy of Cloud Scheduler), choose wisely, this is irreversable. The region CANNOT be changed.

Shut down memorystore

    terraform destroy -target module.memorystore.google_redis_instance.cache



