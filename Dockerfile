# build front-end
FROM node:19-alpine as frontend

RUN apk add --no-cache git

RUN npm install pnpm -g

WORKDIR /app

COPY ./package.json /app

RUN pnpm install

COPY . /app

RUN pnpm run build

# build backend
FROM node:19-alpine as backend

RUN apk add --no-cache git

RUN npm install pnpm -g

WORKDIR /app

COPY /service/package.json /app

RUN pnpm install

COPY /service /app

RUN pnpm build

# service
FROM node:19-alpine

RUN apk add --no-cache git

RUN npm install pnpm -g

WORKDIR /app

COPY /service/package.json /app

RUN pnpm install --production && rm -rf /root/.npm /root/.pnpm-store /usr/local/share/.cache /tmp/*

COPY /service /app

COPY --from=frontend /app/dist /app/public

COPY --from=backend /app/build /app/build

EXPOSE 3002

CMD ["pnpm", "run", "prod"]
