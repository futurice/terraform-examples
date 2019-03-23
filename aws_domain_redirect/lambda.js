"use strict";

exports.handler = (event, context, callback) => {
  const response = event.Records[0].cf.response;
  Object.assign(response.headers, {
    "strict-transport-security": [
      { key: "Strict-Transport-Security", value: "max-age=31557600; preload" }
    ]
  });
  callback(null, response);
};
