# docker-php-apache-codeserver

## PHP-Apache
Base from image: PHP-8.4:Apache\
Auto generate self-sign certificate for https support\
Same as - https://github.com/rayhikki/dokcer-php-apache but +VS Code build-in

## Code-Server
Code-Server image: lscr.io/linuxserver/code-server:latest\
Can access php-apache container via terminal with "ssh codeserver@php-apache" in termial (sshd enable)\
access root permission with "su root" with password are set in user.env

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
nslookup\
snmpwalk/get/set
