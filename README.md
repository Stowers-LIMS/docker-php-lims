# Docker for LIMS PHP

This is the PHP container for the Stowers in-house LIMS application.

## Requires

* Docker v1.12+

## Includes
### Included Applications

* **git** - So running `composer.phar` from bash will work as expected
* **mysql-client** - Needed to connect to the linked mysql server from bash
* **php-pear** - Required by some of our legacy modules
* **tree** - Used by our filesystem parser

### PHP Extensions Added

* imap
* intl
* ldap
* mcrypt
* memcached
* Opcache
* PDO
  * MSSQL/SYBASE
  * MySQL
* zip

### Additional Apache Modules Enabled

* mod_rewrite

## To Run

Since this is based off of the [official PHP](https://hub.docker.com/_/php/) build, check out their excellent build instructions.

## Contributions

If you see something in this Dockerfile that can be done better, please submit a pull request.
