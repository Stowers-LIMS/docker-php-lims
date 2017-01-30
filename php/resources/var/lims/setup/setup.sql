create database if not exists limsdockerdb;

grant all privileges on limsdockerdb.* to limsdbuser@'%';

grant super on *.* to limsdbuser@'%';

flush privileges;
