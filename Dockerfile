# deps
FROM node:14-buster AS deps
WORKDIR /app
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    chromium \
    chromium-driver \
    libatk-bridge2.0-0 \
    libgconf-2-4 \
    libxss1 \
    openjdk-11-jre-headless \
    && rm -rf /var/lib/apt/lists/*
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
COPY package.json package-lock.json ./
RUN npm install

# test
FROM deps AS test
ENV CHROME_BIN /usr/bin/chromium
WORKDIR /app
COPY . .
RUN npm run test

# build
FROM node:14.19-alpine AS build
WORKDIR /app
COPY --from=test /app /app
RUN npm run build

# run
FROM nginx:1.20.2-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist/angular-starter /usr/share/nginx/html