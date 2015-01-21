  Manage oracle schema object for version control.

  Depend on [noradle](https://github.com/kaven276/noradle) NDBC
and for [noradle](https://github.com/kaven276/noradle)
(or any other PL/SQL based)
app CM(configuration management)/VC(version control) purpuse.

# install

`npm -g install noradle-cm`

then `schema2file` in ./bin will be installed into npm global executable path

# Get plsql units of a particular oracle schema into a file system directory

  So, oracle plsql objects can be export to file system, then use git or any VCS for version-control purpose.

  Every exported plsql object's format is the same as "PL/SQL Developer" file save format.

## step 1
  In schema directory, create a *schema.json* file, content as below:

```JSON
{
  "schema" : "message_proxy1",
  "install_script" : {
    "echo" : false,
    "prompt_unit_name" : true
  },
  "use_bom" : true,
  "ignore" : [
    "listen*"
  ]
}
```

parameter explain

* schema - export to which oracle schema
* install-script - if have, create a install script called *install.sql*
* install_script.echo - default false, if set to true, will add *set echo on* to 'install.sql'
* install_script.prompt_unit_name - if set to true, will prefix a line that give prompt which plsql unit will install
* use_bom - if utf8 BOM (0xEFBBBF) will add to plsql unit export file

## step 2

  In schema directory, execute `schema2file port`, `schema2file` will read *schema.json*,
and export schema plsql objects(package, package body, function, procedure) to respective file,
optionally add a *install.sql* script according to `schema.json` configuration.


### example export execution

```shell
schema2file 7001

write install.sql done
write gc.spc done
write k_smtp.spc done
...

```

### example export result

```shell
cat install.sql

set define off
set echo off


prompt
prompt GC.spc
@@gc.spc

prompt
prompt K_SMTP.spc
@@k_smtp.spc

...

prompt
prompt GC.bdy
@@gc.bdy

prompt
prompt K_SMTP.bdy
@@k_smtp.bdy

...

```


# get change list and make a update sqlplus script

## VCS based

example

```shell
git diff --stat head~5..head -- . | cut -d "|" -f 1 | grep -v "," | cut -d "/" -f 2
```

## update one db from another db

  You may want to sync plsql stored procedures from test db to production db,
you don't want all plsql units to "create or replace" on target db,
because it's a big job, will spent lot of time, and the target db is continually serving.
So you want only plsql units that is changed or different from source db to target db.
You know the last time the target db changed a plsql procedure,
so noradle-cm can connect to source db to fetch the change-after list,
and make a update script called "update-yyyymmdd-yyyymmdd.sql".

  *schema.json* will be reused to configure update script format.

  Execute `schema_update port YYYYMMDD` to make a update script.

### example export execution

```shell
schema_update 7001 20150121

  no-cm:update_list write update_20150121_20150121.sql done +0ms
```

### example export result

```shell
cat update_20150121_20150121.sql

set define off
set echo on


prompt
prompt ADM_EXPORT_SCHEMA_H.spc
@@adm_export_schema_h.spc

prompt
prompt ADM_EXPORT_SCHEMA_H.bdy
@@adm_export_schema_h.bdy

```
