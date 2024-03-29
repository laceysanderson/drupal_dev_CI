# The most recent version of Drupal 7 with PHP 8.0 and Apache2
FROM drupal:7-php8.0-apache-bullseye

USER root

COPY . /app

ARG tripalversion='7.x-3.x'

RUN chmod -R +x /app && apt-get update 1> ~/aptget.update.log \
  && apt-get install git unzip zip wget gnupg2 supervisor --yes -qq 1> ~/aptget.extras.log

########## Apache block sensitive files ###############################
COPY ./default_files/block-files.conf /etc/apache2/conf-enabled

########## Drupal Additions #####################
WORKDIR /usr/local/etc/php/
RUN cp php.ini-development php.ini \
  && sed -i 's/memory_limit\s*=.*/memory_limit = 5G/g' php.ini \
  && php -r "echo ini_get('memory_limit').PHP_EOL;" \
  && service apache2 restart

########## Drupal Additions #####################
WORKDIR /var/www/html
RUN chmod a+x /app/init_scripts/composer-init.sh \
  && /app/init_scripts/composer-init.sh \
  && vendor/bin/drush --version

########## PostgreSQL ###########################

# This seems to be needed though I'm not sure why.
# See https://stackoverflow.com/questions/51033689/how-to-fix-error-on-postgres-install-ubuntu
RUN mkdir -p /usr/share/man/man1 && mkdir -p /usr/share/man/man7

# Add PostgreSQL's repository.
# RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
#  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install PostgreSQL 13
#  There are some warnings (in red) that show up during the build. You can hide
#  them by prefixing each apt-get statement with DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install postgresql-13 postgresql-client-13 postgresql-contrib-13 --yes -qq 1> ~/aptget.postgresql.log

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-13`` package when it was ``apt-get installed``
USER postgres

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN cp /app/default_files/postgresql/pg_hba.conf /etc/postgresql/13/main/pg_hba.conf

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
RUN    /etc/init.d/postgresql start \
    && psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" \
    && createdb -O docker docker \
    && export PGPASSWORD='docker'

# Expose the PostgreSQL port
EXPOSE 5432

USER root

########## CERTBOT ##############################
# RUN apt-get update  --yes -qq 1> ~/aptget.update.2.log \
#   && apt-get install certbot python-certbot-apache --yes -qq 1> ~/aptget.certbot.log

########## Tripal ###############################
WORKDIR /var/www/html/sites/all/modules
RUN org='tripal' && repo='tripal' \
  && echo "github/$org/$repo version ${tripalversion}" \
  && git config --global advice.detachedHead false \
  && git clone --quiet https://github.com/$org/$repo.git --branch=${tripalversion} tripal

RUN  chmod a+r -R /var/www/html/sites/all \
  && chown -R www-data:www-data /var/www/html/sites/all \
  && chmod +x /app/init_scripts/startup_container.sh
