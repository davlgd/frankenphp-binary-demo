FROM --platform=linux/amd64 dunglas/frankenphp:static-builder

# Copy your app
WORKDIR /go/src/app/dist/app
COPY . .


WORKDIR /go/src/app/

# There is a (fixed, waiting for release) bug in static-builder image with md5
# As the image is based on Alpine Linux, use md5sum
RUN sed -i 's/md5 -q/md5sum/g' build-static.sh

# Build the static binary, be sure to select only the PHP extensions you want
RUN EMBED=dist/app/ \
    PHP_EXTENSIONS=ctype,iconv,pdo_sqlite \
    ./build-static.sh
