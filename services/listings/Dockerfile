FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --production

COPY src ./src
COPY migrations ./migrations

EXPOSE 4001

CMD ["npm", "run", "start"]
