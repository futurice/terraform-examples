# Minimalist BeyondCorp style Identity Aware Proxy for Cloud Run

This creates an identity aware proxy that
- Redirects all unauthenticated requests to /login and serves a Google Signin
- Exchanges user supplied identity tokens for a system token and proxies upstream

We assume upstream is a private Cloud Run application, thus the proxies service account
is given the cloud.run invoker role enabling it and its proxied users access to this internal resource. Of course, you can change what roles you give the proxy to enable users to call other services.

I expect Google Cloud will develop an fully featured Identity Aware Proxy for Cloud Run at some point. Meanwhile, this is a short term solution that allows me to offer  secured Terraformed internal applications to other employees in my organization.

Firebase Auth is an alternative choice for the authenticating technology, but due to
1 Firebase project per account it would paint me into a corner on what I can do out of a single Cloud project. Also the Google Signin is more flexible on what permissions can be requested.

## OpenResty

Build on top of OpenResty with a smattering of Lua

