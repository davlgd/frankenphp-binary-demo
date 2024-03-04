# FrankenPHP binary demo on Clever Cloud

This is a simple demo of how to build a Laravel/Octane application as a binary with FrankenPHP and deploy it on Clever Cloud.  You'll need a [Clever Cloud account](https://console.clever-cloud.com/) and [Clever Tools](https://github.com/CleverCloud/clever-tools).

## Setup Clever Tools

```bash
npm i -g clever-tools
clever login
```

## Init the project

Here you'll need PHP, Composer and Laravel on your local machine:

```bash
# We create the Laravel project
composer create-project laravel/laravel FrankenLaravel
cd FrankenLaravel

# We setup Octane
composer require laravel/octane
php artisan octane:install --server=frankenphp --no-interaction

# Clean the application before FrankenPHP build
composer install --ignore-platform-reqs --no-dev -a
rm -rf tests/

# On macOS sed works differently, use:
# sed -i '' 's/APP_ENV=local/APP_ENV=prod/g' .env
# sed -i '' 's/APP_DEBUG=true/APP_DEBUG=false/g' .env
sed -i 's/APP_ENV=local/APP_ENV=prod/g' .env
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/g' .env
```

## Build the binary with FrankenPHP

Here you'll need Docker. Create `my.Dockerfile` (or get it from this repository):

```Dockerfile
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
```

Build the binary in a container:

```bash
docker build -t static-app -f my.Dockerfile .
```

Get the built binary as `FrankenLaravel`:

```bash
docker cp $(docker create --name static-app-tmp static-app):/go/src/app/dist/frankenphp-linux-x86_64 FrankenLaravel ; docker rm static-app-tmp
```

## Deploy on Clever Cloud

Create a folder and a Clever Cloud Node.js application, as you can use it with your own web server:

```bash
mkdir ccFrankenLaravel
cd ccFrankenLaravel
cp ../FrankenLaravel .
clever create -t node
git init
```

Create `package.json` file or get it from this repository:

```json
{
  "scripts": {
    "start": "./FrankenLaravel php-server -l :8080"
  }
}
```

Git push!

```bash
git add FrankenLaravel package.json
git commit -m "Init"
clever deploy
clever open
```

Want to know more about (Franken)PHP, read [my blog post](https://labs.davlgd.fr/posts/2024-03-having-fun-with-franken-php/) about it.
