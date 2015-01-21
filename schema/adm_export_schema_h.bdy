create or replace package body adm_export_schema_h is

	procedure unit_list is
		v_filter varchar2(100) := upper(r.getc('z$filter', '%'));
	begin
		h.content_type(mime_type => 'text/items');
		h.set_line_break(chr(30) || chr(10));
		r.setc('PACKAGE', '.spc');
		r.setc('PACKAGE BODY', '.bdy');
		r.setc('PROCEDURE', '.prc');
		r.setc('FUNCTION', '.fnc');
		for a in (select a.*
								from user_objects a
							 where a.object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
								 and a.object_name like v_filter
								 and a.object_name not in ('DAD_AUTH_ENTRY')
							 order by decode(a.object_type, 'PACKAGE', 1, 'FUNCTION', 2, 'PROCEDURE', 3, 'PACKAGE BODY', 4) asc,
												a.object_name asc) loop
			h.line(lower(a.object_name) || r.getc(a.object_type));
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
		-- h.content_disposition_attachment(r.subpath);
		if not r.is_null('BOM') then
			h.use_bom('EF BB BF');
		end if;
		h.set_line_break('');
		h.write('create or replace ');
		--h.set_line_break('');
		select decode(v_ext, 'spc', 'PACKAGE', 'bdy', 'PACKAGE BODY') into v_type from dual;
		select max(a.line)
			into v_maxl
			from user_source a
		 where a.name = upper(v_file)
			 and a.type = v_type;
		for a in (select a.line, a.text
								from user_source a
							 where a.name = upper(v_file)
								 and a.type = v_type
								 and a.line <= v_maxl
							 order by a.line asc) loop
		
			if false and a.line > v_maxl - 4 and a.text like 'end ' || v_file || ';%' then
				h.write(a.text || chr(13) || chr(10));
				--exit;
			else
				h.write(substrb(a.text, 1, lengthb(a.text) - 1) || chr(13) || chr(10));
			end if;
		end loop;
		h.write('/' || chr(13) || chr(10));
	end;

end adm_export_schema_h;
/
