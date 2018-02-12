#!/usr/bin/sh

################################
### Install MongoDb 3.6

#  Import the public key used by the package management system
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5

# Create a list file for MongoDB
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list

# Reload local package database
sudo apt-get update

#  Install the MongoDB packages
sudo apt-get install -y mongodb-org

################################
### Install a specific release of MongoDB (ei 3.2)

# https://askubuntu.com/questions/842592/apt-get-fails-on-16-04-installing-mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org=3.2.18 mongodb-org-server=3.2.18 mongodb-org-shell=3.2.18 mongodb-org-mongos=3.2.18 mongodb-org-tools=3.2.18



################################
## Set up dummy data and users

# Download sample data
# https://docs.mongodb.com/getting-started/shell/import-data/
wget https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json
mongoimport --db test --collection restaurants --drop --file primer-dataset.json

## Setup users

# https://docs.mongodb.com/manual/tutorial/manage-users-and-roles/
# https://stackoverflow.com/questions/21256293/create-read-only-user-in-mongo-db-instance-for-a-particular-database
mongo --eval "printjson(db.createUser({\
    user: 'sa',\
    pwd: 'saP@ssw0rd',\
    roles: [ { role: 'userAdminAnyDatabase' , db: 'admin' }, { role: 'readWriteAnyDatabase' , db: 'admin' }]\
  })\
)"

mongo --eval "printjson(db.createUser({\
    user: 'reportUser',\
    pwd: 'reportP@ssw0rd',\
    roles: [ { role: 'read' , db: 'test' }]\
  })\
)"

# Login to mongo using the users
mongo --username=sa --password=saP@ssw0rd admin
mongo --username=reportUser --password=reportP@ssw0rd test


################################
# !! MANUALLY EDIT mongod.conf to (1) enable security and (2) bind to IP
# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/
# https://www.mkyong.com/mongodb/mongodb-allow-remote-access/

sudo vim /etc/mongod.conf

# storage:
#   dbPath: /var/lib/mongodb\
#   journal:\
#     enabled: true\
# #  engine:\
# #  mmapv1:\
# #  wiredTiger:\

# # where to write logging data.\
# systemLog:\
#   destination: file\
#   logAppend: true\
#   path: /var/log/mongodb/mongod.log\

# # network interfaces
# net:
#   port: 27017
#   bindIp: 127.0.0.1,10.1.2.4

# # how the process runs
# processManagement:
#   timeZoneInfo: /usr/share/zoneinfo

# security:
#   authorization: enabled

# #operationProfiling:

# #replication:

# #sharding:

# ## Enterprise-Only Options:

# #auditLog:

# #snmp:


################################
### Restart mongod service
sudo service mongod restart
sudo service mongod status