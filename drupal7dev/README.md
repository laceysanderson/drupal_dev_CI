![Tripal Dependency](https://img.shields.io/badge/tripal-%3E=3.0-brightgreen)

# UofS Tripal Docker

## Usage

1) Pull the most recent image from the Github Package Repository.

```
docker pull laceysanderson/drupal7dev
```

2) Create a running container exposing the website at localhost:8888

To customize the installed site, change the variables available in the .env file without removing any. Make sure to change DBPASS and ADMINPASS for security reasons.

```
docker run --publish=8888:80 --name=tdocker -tid \
  -e DBPASS='somesecurepassword' \
  -e ADMINPASS='anothersecurepassword' \
  --env-file=.env \
  laceysanderson/drupal7dev:latest
```

3) Provision the container including installation of the software stack including default configuration.

```
docker exec -it tdocker /app/init_scripts/startup_container.sh
```

### For development on a specific module

1) Pull the most recent image from the Github Package Repository.

```
docker pull laceysanderson/drupal7dev
```

2) Pull your module. I suggest creating a dockers directory to ensure you can find the directory to mapped to your container ;-p

```
cd ~/Dockers
git clone https://github.com/tripal/tripal
cd tripal
```

 3) Create the needed .env file. This will not be committed to the repository since it's included in the .gitignore file and could provide security issues.

 ```
 touch .env
 ```

 Now edit this file with your favourite editor to include the following variables. Make sure to change the values for security reasons!

 ```
 ##
 ## DO NOT REMOVE ANY VARIABLES.
 ##
 DBADMIN=tripaladmin
 DBNAME=tripaldb
 DRUPALADMIN=tripaladmin
 DRUPALEMAIL=tripaladmin@yourserver.com
 SITENAME="Tripal Docker"
 ```

 4) Create a running container exposing the website at localhost:8888 and mounting your current directory inside the container.

  - **Make sure to change `DBPASS` and `ADMINPASS` for security reasons.**
  - Your website admin is the value of `DRUPALADMIN` in the .env file with the password set in the run command below.

```
docker run --publish=8888:80 --name=tdocker -tid \
  -e DBPASS='somesecurepassword' \
  -e ADMINPASS='anothersecurepassword' \
  --env-file=.env \
	--volume=`pwd`:/var/www/html/sites/all/modules/tripal \
  laceysanderson/drupal7dev:latest
```

4) Provision the container including installation of the software stack including default configuration.

```
docker exec -it tdocker /app/init_scripts/startup_container.sh
```
