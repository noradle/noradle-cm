  Manage oracle schema object for version control.

# install

`npm -g install noradle-cm`

then `schema2file` in ./bin will be installed into npm global executable path

# Get plsql units of a particular oracle schema into a file system directory

  So, oracle plsql objects can be export to file system, then use git or any VCS for version-control purpose.

  Every exported plsql object's format is the same as "PL/SQL Developer" file save format.

## step 1
  In schema directory, create a *schema.json* file, content as below:

```
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

```
schema2file 7001

write install.sql done
write gc.spc done
write k_smtp.spc done
...

```

### example export result

```
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
