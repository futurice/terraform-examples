FROM node:14-slim

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY index.js ./

EXPOSE 4000
CMD ["node", "index.js"]
