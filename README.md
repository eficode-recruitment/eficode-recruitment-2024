# Eficode - Recruitment Task

The original task description can be found in [TASK.md](TASK.md).

## What has been done
In this section, I will describe what has been done in this repository. If there was something I spotted that could be done, but I didn't have time to do it, I will mention it in the "Further possible improvements" section.

> I tracked my work using Linear, in which I've created issues/tickets. If you want to see how I describe things to do, take a look at the expandable commend from the bot that liked each issue in PRs.

### App Code
- (app) Added `.env` file to centralize environment variables,
- (app) Extracted all variables from the frontend and backend to `.env` file,
- (frontend) Replaced webpack with Vite, removed unnecessary dependencies, and improved HMR,
- (frontend) Added build script to output static assets,

Further possible improvements:
- (CI) Add CI pipeline to build and lint the app,
- (app) Add corepack to install project dependencies with always-correct version package manager.

### Docker
- (backend) Added Dockerfile.
- (frontend) Added Dockerfile for both environments:
  - dev uses `npm start` to guarantee hot reload,
  - prod uses multi-stage build to build the app and then serve static files with nginx,
- (compose) Added `docker-compose.yml` to run the app in connected containers.
- (compose) Added `compose watch` script to run the app in development mode.

Further possible improvements:
- (compose) Use secrets to store sensitive data such as OpenWeatherMap API key.


---

## How to run
Before starting, you need to get yourself an API key in the OpenWeatherMap "Current Weather Data" API.

Afterwards:
1. Clone the repository.
2. Rename `.env.example` to `.env` and fill in the `OPENWEATHERMAP_API_KEY` variable with your OpenWeatherMap API key,
3. Change other variables if needed (such as target city),
4. Run `docker-compose watch` to build and start the containers in the background,
5. Open `http://localhost:8000` in your browser to see the app running.

All the commands:
```bash
git clone git@github.com:eficode-recruitment/eficode-recruitment-2024.git
cd eficode-recruitment-2024
cp .env.example .env
# Fill in the .env file, and then run:
docker-compose watch
```

> If you modified the .env file while containers were running, you need to restart the containers by running `docker-compose watch` again.


