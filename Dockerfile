FROM node:18.12.1-alpine3.15

WORKDIR /app

COPY . /app

RUN npm install
RUN npm install pm2 -g

EXPOSE 3000
EXPOSE 80

ENV NODE_ENV=production

CMD ["pm2-runtime", "app.js"]