#!/bin/bash

## This script is run when the docker container is created.
##
## Expected ENVIRONMENTAL VARIABLES
## - $DBPASS: The password for the tripal/chado database administrative user.
## - $ADMINPASS: The password for the drupal admin user.
##
## All Other variables are defined in a .env file.

service postgresql start
SQL="CREATE ROLE $DBADMIN WITH PASSWORD '$DBPASS'"
echo "CREATE ROL $DBADMIN"
PGPASSWORD=docker psql --user docker --command "$SQL"
SQL="ALTER ROLE $DBADMIN WITH LOGIN"
PGPASSWORD=docker psql --user docker --command "$SQL"
SQL="CREATE DATABASE $DBNAME WITH OWNER $DBADMIN"
echo "CREATE DATABASE $DBNAME"
PGPASSWORD=docker psql --user docker --command "$SQL"

service apache2 start
sleep 30
cd /var/www/html/
echo "SITE INSTALL"
vendor/drush/drush/drush site-install standard --yes \
  --db-url=pgsql://$DBADMIN:$DBPASS@localhost/$DBNAME \
  --account-mail="$DRUPALEMAIL" \
  --account-name=$DRUPALADMIN \
  --account-pass=$ADMINPASS \
  --site-mail="$DRUPALEMAIL" \
  --site-name="$SITENAME"
chmod a+r -R /var/www/html/sites/default/files
chown -R www-data:www-data /var/www/html/sites/default/files

echo "INSTALL DRUPAL MODULES"
vendor/drush/drush/drush pm-enable --yes libraries
vendor/drush/drush/drush pm-enable --yes advanced_help ctools date \
	 ds entity field_formatter_class field_formatter_settings \
	field_group field_group_table jquery_update link redirect views

echo "INSTALL & PREPARE TRIPAL/CHADO"
vendor/drush/drush/drush pm-enable --yes tripal tripal_chado tripal_ws tripal_ds
# Prepare chado and drupal
vendor/drush/drush/drush eval "module_load_include('inc', 'tripal_chado', 'includes/tripal_chado.install'); tripal_chado_load_drush_submit('Install Chado v1.3');"
vendor/drush/drush/drush trp-run-jobs --username=$DRUPALADMIN
vendor/drush/drush/drush eval "module_load_include('inc', 'tripal_chado', 'includes/setup/tripal_chado.setup'); tripal_chado_prepare_drush_submit();"
vendor/drush/drush/drush trp-run-jobs --username=$DRUPALADMIN
vendor/drush/drush/drush dis -y overlay
vendor/drush/drush/drush cc all
