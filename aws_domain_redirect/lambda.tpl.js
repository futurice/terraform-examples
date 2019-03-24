'use strict';

// Lambda@Edge doesn't support environment variables, so this config will be inlined with a Terraform template
const config = JSON.parse('${config}');

log('aws_domain_redirect.config', config);

// Handle incoming request from the client
exports.viewer_request = (event, context, callback) => {
  const request = event.Records[0].cf.request;

  log('aws_domain_redirect.viewer_request.before', request);

  const response = {
    status: config.redirect_permanently ? '301' : '302',
    statusDescription: config.redirect_permanently ? 'Moved Permanently' : 'Moved Temporarily',
    body: '',
    headers: formatHeaders({
      Location: config.redirect_url,
      'Strict-Transport-Security': config.redirect_with_hsts ? 'max-age=31557600; preload' : '', // i.e. 1 year (in seconds)
    }),
  };

  callback(null, response);

  log('aws_domain_redirect.viewer_request.after', response);
};

// Formats incoming/outgoing requests for debugging
function log(message, meta) {
  console.log(message, require('util').inspect(meta, false, 10, false));
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
