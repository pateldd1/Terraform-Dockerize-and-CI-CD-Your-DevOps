FROM node:18.12.1-alpine3.15

WORKDIR /app

COPY . /app

RUN npm install

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "app.js"]