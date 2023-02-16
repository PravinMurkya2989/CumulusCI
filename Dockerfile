FROM python:3.8-alpine3.14 AS builder

RUN apk add --no-cache gcc g++ libc-dev libffi-dev openssl-dev make libxml2-dev libxslt-dev
RUN apk add --no-cache jpeg-dev zlib-dev freetype-dev lcms2-dev openjpeg-dev tiff-dev rust cargo

WORKDIR /root

COPY requirements.txt .
COPY requirements-unix.txt .

RUN mkdir wheels

RUN pip --no-cache-dir wheel --wheel-dir wheels -r requirements.txt -r requirements-unix.txt


FROM python:3.8-alpine3.14

RUN apk add --no-cache libxml2 libxslt jpeg zlib freetype lcms2 openjpeg tiff

WORKDIR /root

COPY --from=builder /root/wheels wheels

RUN pip --no-cache-dir install wheels/*.whl

RUN rm -rf wheels

RUN apk add --no-cache nodejs npm
RUN npm install -g --no-cache raml-1-parser@1.1.66 @apidevtools/swagger-parser@9.0.1 yargs@15.3.1
ENV NODE_PATH=/usr/local/lib/node_modules

RUN apk add --no-cache tzdata
ARG TIMEZONE="Europe/Berlin"
ENV TZ=${TIMEZONE}
RUN echo ${TIMEZONE} > /etc/timezone
