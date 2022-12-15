FROM node:19-alpine3.17 AS build

WORKDIR /app

COPY . .

RUN npm install

RUN npm run build

FROM node:19-alpine3.17 AS final
ENV NODE_ENV=production

COPY ["package.json", "package-lock.json*", "./"]

RUN npm install --production

RUN npm install -g serve

COPY --from=build /app/build/ /app/

CMD ["serve", "-s", "/app"]


