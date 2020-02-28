const { BigQuery } = require('@google-cloud/bigquery');
const { Storage } = require('@google-cloud/storage');
const bigquery = new BigQuery();
const gcs = new Storage();

exports.materialize = async (event, ctx) => {
    if (process.env.SOURCE_DATASET && process.env.SOURCE_TABLE && process.env.N_DAYS) {
        const query = `
            MERGE
            \`${process.env.PROJECT}.${process.env.DATASET}.${process.env.TABLE}\`
            USING (SELECT * FROM
            \`${process.env.PROJECT}.${process.env.SOURCE_DATASET}.${process.env.SOURCE_TABLE}\`)
            ON FALSE
            WHEN NOT MATCHED BY SOURCE AND day > DATE_SUB(CURRENT_DATE, INTERVAL ${process.env.N_DAYS} DAY) THEN DELETE
            WHEN NOT MATCHED BY TARGET AND dat > DATE_SUB(CURRENT_DATE, INTERVAL ${process.env.N_DAYS} DAY) THEN INSERT ROW`;
        console.log(`Executing: ${query}`)
        const [job] = await bigquery.createQueryJob({
            query: query,
            location: 'EU',
        });
        await job.getQueryResults();
    } else if (process.env.SOURCE_DATASET && process.env.SOURCE_TABLE) {
        const query = `
            CREATE OR REPLACE TABLE
            \`${process.env.PROJECT}.${process.env.DATASET}.${process.env.TABLE}\`
            AS SELECT * FROM 
            \`${process.env.PROJECT}.${process.env.SOURCE_DATASET}.${process.env.SOURCE_TABLE}\``;
        console.log(`Executing: ${query}`)
        const [job] = await bigquery.createQueryJob({
            query: query,
            location: 'EU',
        });
        await job.getQueryResults();
    }
    
    if (process.env.BUCKET && process.env.FILE) {
        console.log(`Exporting to ${process.env.BUCKET} ${process.env.FILE}`);
        const destfile = gcs
            .bucket(process.env.BUCKET)
            .file(process.env.FILE);

        // Now export this to a gcs location
        const dataset = bigquery.dataset(process.env.DATASET);
        const table = dataset.table(process.env.TABLE);
        await table.createExtractJob(destfile, {
            format: "JSON"
        });
    }
};
