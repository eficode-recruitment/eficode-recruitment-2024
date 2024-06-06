FROM node:14

ENV NPM_CONFIG_LOGLEVEL info

EXPOSE 9000

WORKDIR /usr/src/app

COPY package*.json .
RUN npm install --production
COPY --chown=node:node ./src .

USER node
CMD ["node", "index.js"]
