const http = require("http");
const appInsights = require("applicationinsights");

if (!process.env.APPINSIGHTS_INSTRUMENTATIONKEY) {
  console.error("Missing APPINSIGHTS_INSTRUMENTATIONKEY config");
  process.exit(2);
}

// Instrumentation key is loaded from APPINSIGHTS_INSTRUMENTATIONKEY env var
appInsights.setup().setAutoCollectConsole(true, true);
// The cloud role can be used to identify the app in Application Insights
appInsights.defaultClient.context.tags[
  appInsights.defaultClient.context.keys.cloudRole
] = "MyApplication";
appInsights.start();

const port = 4000;

async function connectToDatabase() {
  try {
    const connectionString = process.env.DB_URL;
    const parsedConnectionString = parseConnectionString(connectionString);
    await sql.connect({
      authentication: {
        type: "azure-active-directory-msi-app-service",
        options: {
          // These are available when we have enabled system managed identity
          msiEndpoint: process.env.MSI_ENDPOINT,
          msiSecret: process.env.MSI_SECRET,
        },
      },
      server: parsedConnectionString.host,
      database: parsedConnectionString.database,
      options: {
        trustServerCertificate: false,
        encrypt: true,
        port: 1433,
      },
    });

    console.log("Connected successfully to database");
  } catch (err) {
    console.error(err);
    process.exit(2);
  }
}

async function startServer() {
  const requestListener = async function (req, res) {
    try {
      console.log("Request to", req.url);

      res.writeHead(200);
      res.end("My first server!");
    } catch (error) {
      console.error(err);
      res.writeHead(500);
      res.end("2");
    }
  };

  const server = http.createServer(requestListener);
  server.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });
}

(async function start() {
  await startServer();
})();
