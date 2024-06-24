FROM node:20 AS build

WORKDIR /usr/src/app

COPY frontend/package*.json ./
RUN npm install
COPY frontend ./

# Sets the environment variable just for the build
RUN FRONTEND_ENDPOINT=/api npm run build


FROM caddy:2.8.4

COPY --from=build /usr/src/app/dist /usr/share/caddy
COPY frontend/docker/prod/Caddyfile /etc/caddy/Caddyfile

EXPOSE 80 443

# Shutdown gracefully on SIGQUIT
STOPSIGNAL SIGQUIT

# Run nginx in the foreground
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
