#!/usr/bin/env bash

set -e

/usr/local/bin/wait-for-it -t 15 mysql:3306 -- echo "mysql is up"

cd /var/www/smartvideo
rm -f public/storage

mkdir -p /var/www/laravel
cp -R storage /var/www/laravel
chown -R www-data:www-data /var/www/laravel/

php artisan package:discover
echo 'migrate'
php artisan migrate --force

echo 'publish'
php artisan vendor:publish --tag=laravel-pagination
php artisan horizon:publish
php artisan cache:clear

echo 'cache'
php artisan config:cache
php artisan view:cache
php artisan route:cache
php artisan api:cache
php artisan event:cache
php artisan storage:link


echo "cron"
mkdir -p /var/spool/cron/crontabs/
cp crontab /var/spool/cron/crontabs/root
chmod 0644 /var/spool/cron/crontabs/root
crontab -u www-data /var/spool/cron/crontabs/root
cron -f &

echo "queue"
php artisan horizon &

echo 'http'

exec apache2-foreground
