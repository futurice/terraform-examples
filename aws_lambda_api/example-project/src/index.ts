import { APIGatewayProxyHandler } from "aws-lambda";

export const handler: APIGatewayProxyHandler = (event, context) => {
  return Promise.resolve({
    statusCode: 200,
    body: JSON.stringify({ message: "Hello TS!", event, context }, null, 2)
  });
};
