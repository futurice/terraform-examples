import { APIGatewayProxyHandler } from "aws-lambda";
import { getRandomJoke } from "one-liner-joke";

export const handler: APIGatewayProxyHandler = () => {
  return Promise.resolve({
    statusCode: 200,
    body: JSON.stringify(getRandomJoke(), null, 2)
  });
};
