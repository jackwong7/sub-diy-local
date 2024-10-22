#build
FROM node:14-alpine as build

WORKDIR /app

RUN apk add --no-cache wget git nginx \
    && git clone https://github.com/CareyWang/sub-web

COPY ./vue/src/views /app/sub-web/src/views
COPY ./vue/* /app/sub-web
COPY ./vue/public/index.html /app/sub-web/public/index.html


RUN cd /app/sub-web && yarn install && yarn build

#nginx
FROM nginx:1.16-alpine
COPY --from=build /app/sub-web/dist /var/www

#sub service
ADD . /var/dev/
WORKDIR /var/dev/
COPY ./nginx/conf.d/* /etc/nginx/conf.d
RUN chmod 777 ./docker-entrypoint.sh \
    && wget https://github.com/tindy2013/subconverter/releases/download/v0.7.2/subconverter_linux64.tar.gz \
    && tar -zxvf subconverter_linux64.tar.gz && rm subconverter_linux64.tar.gz


ENTRYPOINT ["./docker-entrypoint.sh"]
