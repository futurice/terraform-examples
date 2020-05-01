


The basis for token intospection

curl https://oauth2.googleapis.com/tokeninfo?access_token=$(gcloud auth print-access-token)

returns

{
  "azp": "32555940559.apps.googleusercontent.com",
  "aud": "32555940559.apps.googleusercontent.com",
  "sub": "104477641821643740620",
  "scope": "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/appengine.admin https://www.googleapis.com/auth/compute https://www.googleapis.com/auth/accounts.reauth openid",
  "exp": "1588279623",
  "expires_in": "3599",
  "email": "tom.larkworthy@gmail.com",
  "email_verified": "true",
  "access_type": "offline"
}

curl https://oathkeeper-flxotk3pnq-ew.a.run.app/camunda-welcome/index.html -H "Authorization: Bearer $(gcloud auth print-access-token)"

See https://accounts.google.com/.well-known/openid-configuration

Note google does not support the introspection endpoint
 https://developer.ibm.com/apiconnect/2017/10/10/integrate-third-party-oauth-provider-google/

 It works using an id_token and jwt with scopes "openid email profile"
