/**
 * Created by cuccpkfs on 15-1-21.
 */

var Noradle = require('noradle')
  , path = require('path')
  , cfg = require(path.join(process.cwd(), 'schema.json'))
  , dbPort = parseInt(process.argv[2])
  , after = parseInt(process.argv[3])
  , dbUser = cfg.schema
  , outDir = '.'
  , fs = require('fs')
  , debug = require('debug')('no-cm:update_list')
  ;

var dbPool = new Noradle.DBPool(dbPort, {
  FreeConnTimeout : 60000
});
var dbc = new Noradle.NDBC(dbPool, {
  x$dbu : dbUser
});

dbc.call('adm_export_schema_h.unit_list', {
  __parse : true,
  z$filter : '%',
  after : after
}, function(status, headers, units){
  if (status !== 200) {
    console.error(units);
    process.exit(status);
    return;
  }
  var now = units.shift();
  if (!cfg.install_script) {
    cfg.install_script = {};
  }
  if (cfg.install_script) {
    var echoSwitch = cfg.install_script.echo ? 'on' : 'off'
      , usePrompt = !!cfg.install_script.prompt_unit_name
      , lines = [
        "set define off",
        "set echo " + echoSwitch,
        ""
      ]
      , script_text = 'set define off\nset echo ' + echoSwitch + '\n\n@@' + units.join('\n@@') + '\n'
      ;
    units.forEach(function(unit){
      if (usePrompt) {
        lines.push('\r\nprompt\r\nprompt ' + unit.split('.')[0].toUpperCase() + '.' + unit.split('.')[1]);
      }
      lines.push('@@' + unit);
    });
    lines.push('');
    var scriptName = "update_" + after + "_" + now + ".sql";
    fs.writeFileSync(path.join(outDir, scriptName), lines.join("\r\n"));
    debug('write %s done', scriptName);
    process.exit(0);
  }
});
