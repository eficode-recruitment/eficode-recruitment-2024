FROM node:20

WORKDIR /usr/src/app

COPY frontend/package*.json ./
RUN npm install
COPY ./.env ../
COPY frontend ./

CMD ["npm", "run", "start"]
