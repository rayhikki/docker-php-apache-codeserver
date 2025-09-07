# docker-php-apache-codeserver

## PHP-Apache
Base from image: PHP-8.4:Apache\
Auto generate self-sign certificate for https support\
Same as - https://github.com/rayhikki/dokcer-php-apache

## Code-Server
Code-Server image: lscr.io/linuxserver/code-server:latest\
Can access php-apache container via "ssh codeserver@php-apache" in termial (sshd enable)
But need to set password in container before with command "passwd codeserver"

## PHP Plugin Enable
Composer\
PDO MySQL/PostgreSQL\
MongoDB\
pcntl (multi-thread)\
snmp\
zip

## Other Cli Support
git\
htop\
iftop\
nano\
ping\
snmpwalk/snmpget/snmpset
