set define on
set echo on
accept dbu char default 'noradle_cm' prompt 'enter schema name you want to create and install into'

create user &dbu identified by noradle_cm
default tablespace sysaux
temporary tablespace temp;
grant create procedure to &dbu;
grant create session to &dbu;

alter session set current_schema = &dbu;

@@install.sql

exit
