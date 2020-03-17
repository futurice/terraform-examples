const Redis = require('redis');
const split = require('split');
const { Storage } = require('@google-cloud/storage');

const redis = Redis.createClient(
  process.env.REDIS_PORT,
  process.env.REDIS_HOST);
const gcs = new Storage();

redis.on("error", function (err) {
  console.error("Redis error " + err);
});

/*
 * Read a bucket and path, assume the file is line deliminated JSON, extract field "key"
 * and push into redis with the whole JSON record as the value.
 * Triggered by writes to a bucket
 */
exports.memorystoreload = (info, context) => new Promise((resolve, reject) => {
  const bucket = gcs.bucket(info.bucket);
  const file = bucket.file(info.name);
  let keysWritten = 0;
  file.createReadStream()
    .on('error', reject)
    .pipe(split()) // convert to lines
    .on('data', function (line) {
      if (!line || line === "") {
        return;
      }
      keysWritten++;
      const data = JSON.parse(line);
      redis.set(data.KEY, line, 'EX', process.env.EXPIRY, redis.print);
    })
    .on('end', () => {
      console.log(`Keys written: ${keysWritten}`);
      redis.wait(1, resolve);
    })
    .on('error', reject);
});

