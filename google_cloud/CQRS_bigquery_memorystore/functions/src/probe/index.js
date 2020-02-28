const { BigQuery } = require('@google-cloud/bigquery');
const bigquery = new BigQuery();


let lastVersionUpdated = null;

const controls = [{
    field: "multiplier",
    value: 1.0
}];

exports.probe = async (event, ctx) => {
    const payload = event.data ? JSON.parse(Buffer.from(event.data, 'base64'))
                               : event.query; // If running as http

    // Unique user for each deployment version                        
    const user = `probe_${payload.version}`;
    const timestamp = new Date().toISOString();
    const work = []

    // Regular prober work is to insert activity reguarly
    work.push(
        bigquery
            .dataset(process.env.PROBE_DATASET)
            .table(process.env.PROBE_TABLE)
            .insert([{
                user: user,
                timestamp: timestamp,
                value: 1.0
            }])
    );

    // But also with new deploys we need to update user control values
    if (payload.version != lastVersionUpdated) {
        console.log(`New version detected ${payload.version} writing control`);
        work.concat(controls.map(
            control => bigquery
                .dataset(process.env.CONTROLS_DATASET)
                .table(`control_${control.field}`)
                .insert([{
                    user: user,
                    timestamp: timestamp,
                    [control.field]: control.value
                }]).catch(err => {
                    console.error(JSON.stringify(err));
                })
        ));
    }

    await Promise.all(work)
    lastVersionUpdated = payload.version;
    if (event.query) ctx.sendStatus(200); // If running as HTTP funciton
};
