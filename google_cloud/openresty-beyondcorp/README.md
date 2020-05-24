# Minimalist BeyondCorp style Identity Aware Proxy for Cloud Run

This creates an identity aware proxy that
- Redirects all unauthenticated requests to /login and serves a Google Signin
- Exchanges user supplied identity tokens for a system token and proxies upstream

We assume upstream is a private Cloud Run application, thus the proxies service account
is given the cloud.run invoker role enabling it and its proxied users access to the internal resource. Of course, you can change what roles you give the proxy to enable users to call other services.

I expect Google Cloud will develop an fully featured Identity Aware Proxy for Cloud Run at some point. Meanwhile, this is a short term solution that allows me to offer  secured Terraformed internal applications to other employees in my organization.


## OpenResty

Build on top of OpenResty

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

# Test WAL verification

curl -X POST -d "{}" http://localhost:8080/wal-playback/

# Test token validation
curl http://localhost:8080/httptokeninfo?id_token=foo
curl http://localhost:8080/httptokeninfo?access_token=foo