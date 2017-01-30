create database if not exists dnalims;

grant all privileges on dnalims.* to dnalims@'%';
grant all privileges on dnalims.* to dnalims@'localhost';

grant super on *.* to dnalims@'%';
grant super on *.* to dnalims@'localhost';

flush privileges;
