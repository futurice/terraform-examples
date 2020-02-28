const moment = require('moment-timezone');
const { BigQuery } = require('@google-cloud/bigquery');
const { Storage } = require('@google-cloud/storage');
const Redis = require('redis');
const bigquery = new BigQuery();
const gcs = new Storage();
const redis = Redis.createClient(process.env.REDIS_PORT,
                                 process.env.REDIS_HOST);

const {promisify} = require('util');
const redisGet = promisify(redis.get).bind(redis);

const VERSION = process.env.VERSION;
const PROBER_DATASET = process.env.PROBER_DATASET;
const PROBER_TABLE = process.env.PROBER_TABLE;
const UNIFIED_VALUES_DATASET = process.env.UNIFIED_VALUES_DATASET;
const UNIFIED_VALUES_TABLE = process.env.UNIFIED_VALUES_TABLE;
const CURRENT_TOTALS_DATASET = process.env.CURRENT_TOTALS_DATASET;
const CURRENT_TOTALS_TABLE = process.env.CURRENT_TOTALS_TABLE;

exports.test = async (req, res) => {
    try {
        res.send({
            "version": VERSION,
            "time": moment().tz("Europe/Berlin").format("YYYY-MM-DD HH:mm:ss z"),
            "prober_updating": await checkProberUpdating(),
            "unified_values_contains_probe": await checkUnifiedValuesContainsProbe(),
            "current_totals_contains_probe": await checkCurrentTotalsContainsProbe(),
            "memorystore_current_totals_contains_probe": await checkMemorystoreCurrentTotalsContainsProbe(),
        });
    } catch (err) {
        console.log(err);
        res.status(500)
            .send({
                "version": VERSION,
                "error": err.message,
                "stack": err.stack
            });
    }
};

async function checkProberUpdating() {
    return await hasSingleResult(`
        SELECT user
        FROM \`${PROBER_DATASET}.${PROBER_TABLE}\`
        WHERE user = 'probe_${VERSION}'
        AND timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE)
        LIMIT 1`);
}

async function checkUnifiedValuesContainsProbe() {
    return await hasSingleResult(`
        SELECT user
        FROM \`${UNIFIED_VALUES_DATASET}.${UNIFIED_VALUES_TABLE}\`
        WHERE user = 'probe_${VERSION}'
        AND timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 10 MINUTE)
        AND day >= CURRENT_DATE()
        LIMIT 1`);
}

async function checkCurrentTotalsContainsProbe() {
    return await hasSingleResult(`
        SELECT user
        FROM \`${CURRENT_TOTALS_DATASET}.${CURRENT_TOTALS_TABLE}\`
        WHERE user = 'probe_${VERSION}'
        AND adjusted_total >= 2`);
    // Note: no limit, we don't expect mutiple results
}

async function checkMemorystoreCurrentTotalsContainsProbe() {
    return await redisGet(`current_totals/probe_${VERSION}`) ? true: false;
}

async function hasSingleResult(query) {
    const [job] = await bigquery.createQueryJob({
        query: query,
        location: 'EU',
    });
    const [rows] = await job.getQueryResults();
    return rows.length == 1;
}
