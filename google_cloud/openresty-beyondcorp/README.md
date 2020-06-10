# Swiss Army Identity Aware Proxy

Very fast Serverless OpenResty based proxy that can wrap upstream binaries with a login. Furthermore, we have examples of 
- Local development environment
- Slack/Zapier intergration.
- A Write Ahead Log
- Google Secret Manager intergration

Read more on the [OpenResty: a Swiss Army Proxy for Serverless; WAL, Slack, Zapier and Auth](https://futurice.com/blog/openresty-a-swiss-army-proxy-for-serverless) blog.

An earlier version is linked to in the [Minimalist BeyondCorp style Identity Aware Proxy for Cloud Run](https://futurice.com/blog/identity-aware-proxy-for-google-cloud-run) blog that is just the login part.

## OpenResty and Cloud Run

Build on top of OpenResty, hosted on Cloud Run (and excellent match)

## Extensions Fast Response using a Write Ahead Log

If upstream is slow (e.g. scaling up), you can redirect to a WAL. Latency is the time to store the message. 
A different location plays back the WAL with retries so you can be sure the request is eventially handled.

## Extensions Securing a Slack Intergration

Intergration with Slack
Reads a secret from Google secrets manager and verifies the signature HMAC

## Extensions Securing a Zapier Intergration

Zapier can be protected with an Oauth account

## Local testing with docker-compose

Generate a local service account key in .secret

`gcloud iam service-accounts keys create .secret/sa.json --iam-account=openresty@larkworthy-tester.iam.gserviceaccount.com`

run this script to get a setup that reloads on CTRL + C

`/bin/bash test/dev.sh`

The use of bash to start the script gives it an easier name to find to kill

killall "bash"

# Get prod tokens

    https://openresty-flxotk3pnq-ew.a.run.app/login?token=true

# Test WAL verification

    curl -X POST -d "{}" http://localhost:8080/wal-playback/

# Test token validation

    curl http://localhost:8080/httptokeninfo?id_token=foo
    curl http://localhost:8080/httptokeninfo?access_token=foo


# Test slack

    curl http://localhost:8080/slack/command
