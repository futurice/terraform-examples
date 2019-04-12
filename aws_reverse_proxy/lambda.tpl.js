'use strict';

// Lambda@Edge doesn't support environment variables, so this config will be expanded from a Terraform template
const config = ${config};
const addResponseHeaders = ${add_response_headers};
const validCredentials = config.basic_auth_username + ':' + config.basic_auth_password;
const validAuthHeader = 'Basic ' + new Buffer(validCredentials).toString('base64');

log('aws_static_site.config', { config, addResponseHeaders });

// Handle incoming request from the client
exports.viewer_request = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const headers = request.headers;

  log('aws_static_site.viewer_request.before', request);

  if (config.override_response_status && config.override_response_status_description && config.override_response_body) {
    const response = {
      status: config.override_response_status,
      statusDescription: config.override_response_status_description,
      body: config.override_response_body,
      headers: formatHeaders(addResponseHeaders),
    };
    callback(null, response); // reply to the client with the overridden content, and don't forward request to origin
    log('aws_static_site.viewer_request.after', response);
  } else if (
    (config.basic_auth_username || config.basic_auth_password) &&
    (typeof headers.authorization == 'undefined' || headers.authorization[0].value != validAuthHeader)
  ) {
    const response = {
      status: '401',
      statusDescription: 'Unauthorized',
      body: config.basic_auth_body,
      headers: {
        ...formatHeaders(addResponseHeaders),
        ...formatHeaders({
          'WWW-Authenticate': 'Basic realm="' + config.basic_auth_realm + '", charset="UTF-8"',
        }),
      },
    };
    callback(null, response); // reply to the client with Unauthorized, and don't forward request to origin
    log('aws_static_site.viewer_request.after', response);
  } else {
    callback(null, request); // allow the request to be forwarded to origin normally
    log('aws_static_site.viewer_request.after', 'OK');
  }
};

// Handle outgoing response to the client
exports.viewer_response = (event, context, callback) => {
  const response = event.Records[0].cf.response;

  log('aws_static_site.viewer_response.before', response);

  response.headers = {
    ...response.headers,
    ...formatHeaders(addResponseHeaders),
  };

  log('aws_static_site.viewer_response.after', response);

  callback(null, response);
};

// Outputs incoming/outgoing requests for debugging
function log(label, meta) {
  console.log(label, require('util').inspect(meta, false, 10, false));
}

// Converts a set of headers into the rather-verbose format CloudFront expects; headers with "" as the value are dropped
function formatHeaders(headers) {
  return Object.keys(headers)
    .filter(next => headers[next] !== '')
    .reduce(
      (memo, next) =>
        Object.assign(memo, {
          [next.toLowerCase()]: [{ key: next, value: headers[next] }],
        }),
      {},
    );
}
