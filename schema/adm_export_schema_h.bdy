create or replace package body adm_export_schema_h is

	-- private
	procedure set_type2ext is
	begin
		r.setc('PACKAGE', '.spc');
		r.setc('PACKAGE BODY', '.bdy');
		r.setc('PROCEDURE', '.prc');
		r.setc('FUNCTION', '.fnc');
	end;

	procedure set_ext2type is
	begin
		r.setc('spc', 'PACKAGE');
		r.setc('bdy', 'PACKAGE BODY');
		r.setc('prc', 'PROCEDURE');
		r.setc('fnc', 'FUNCTION');
	end;

	procedure unit_list is
		v_filter varchar2(100) := upper(r.getc('z$filter', '%'));
		v_after  date := trunc(r.getd('after', sysdate - 20 * 365, 'yyyymmdd'));
	begin
		h.content_type(mime_type => 'text/items');
		b.set_line_break(chr(30) || chr(10));
		set_type2ext;
		if not r.is_null('after') then
			b.line(to_char(sysdate, 'YYYYMMDD'));
		end if;
		for a in (select a.*
								from user_objects a
							 where a.object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
								 and a.object_name like v_filter
								 and a.object_name not in ('DAD_AUTH_ENTRY')
								 and a.last_ddl_time > v_after
							 order by decode(a.object_type, 'PACKAGE', 1, 'FUNCTION', 2, 'PROCEDURE', 3, 'PACKAGE BODY', 4) asc,
												a.object_name asc) loop
			b.line(lower(a.object_name) || r.getc(a.object_type));
		end loop;
	end;

	procedure download is
		v_file varchar2(30);
		v_ext  varchar2(9);
		v_type varchar2(30);
		v_maxl pls_integer;
	begin
		t.half(replace(r.getc('unit'), '.', ','), v_file, v_ext);
		h.content_type(mime_type => h.mime_text);
		if not r.is_null('BOM') then
			h.use_bom('EF BB BF');
		end if;
		b.write('create or replace ');
		set_ext2type;
		v_type := r.getc(v_ext);
	
		for a in (select a.line, a.text
								from user_source a
							 where a.name = upper(v_file)
								 and a.type = v_type
							 order by a.line asc) loop
			b.write(substrb(a.text, 1, lengthb(a.text) - 1) || chr(13) || chr(10));
		end loop;
		b.write('/');
	end;

end adm_export_schema_h;
/
