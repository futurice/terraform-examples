#!/bin/bash

check_exec(){
  if [ "$?" -ne 0 ]
  then 
    echo $1
    exit 1
  fi
}

sudo apt update
sudo apt install curl gpg gnupg2 software-properties-common apt-transport-https lsb-release ca-certificates curl -y

check_exec "===> Failed to update and install libraries"

curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg

check_exec "===> Failed obtain the key"

echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

check_exec "===> Failed to add the key"

sudo apt update

sudo apt install postgresql-13 postgresql-client-13 -y

check_exec "===> Postgresql-13 cannot be installed"

echo -n "===> Do you want to start Postgres Database now ? (y|n) "
read input

# converting to lowercase & comparing
if [ "${input,,}" = "y" -o "${input,,}" = "yes" ]
then
  echo "===> Starting Postgres ........"
  sudo systemctl start postgresql
  check_exec "===> Postgres could not be started"
fi

echo "===> Script ran successfully"

exit 0