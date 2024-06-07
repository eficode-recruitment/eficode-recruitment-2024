FROM node:20 AS build

WORKDIR /usr/src/app

COPY frontend/package*.json ./
RUN npm install
COPY ./.env ../
COPY frontend ./

RUN npm run build


FROM nginx:1.26.1

COPY --from=build /usr/src/app/dist /usr/share/nginx/html

EXPOSE 80

# Shutdown gracefully on SIGQUIT
STOPSIGNAL SIGQUIT

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
