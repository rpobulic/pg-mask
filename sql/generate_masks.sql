\encoding 'UTF8'
\pset fieldsep '\t'
\pset null '\\N'
\o mask.sql
select 'select ''\encoding ''''UTF8'''''';';
select 'select ''copy "'||nam.nspname||'".'||tab.relname||'('||string_agg(col.attname,',')||')from stdin;'';'
||e'\n'||'copy(select '||string_agg(coalesce(
	case substring(msk.description from '"msk"(.*?)"')
	when 'det'
	then case format_type(col.atttypid,null)
	     when 'numeric'
	     then 'abs((''x''||encode(digest(to_hex('||col.attname||'::int8),''sha512''),''hex''))::bit(64)::int8)*sign('||col.attname||')%'||col.attname
	     when 'integer'
	     then '(abs((''x''||encode(digest(to_hex('||col.attname||'),''sha512''),''hex''))::bit(32)::int)*sign('||col.attname||'))::int%'||col.attname
	     when 'bigint'
	     then '(abs((''x''||encode(digest(to_hex('||col.attname||'),''sha512''),''hex''))::bit(64)::int8)*sign('||col.attname||'))::int8%'||col.attname
	     when 'double precision'
	     then '(abs((''x''||encode(digest(to_hex('||col.attname||'::int8),''sha512''),''hex''))::bit(64)::int8)*sign('||col.attname||'::numberic)%'||col.attname||'::numeric)||''::float8'''
	     when 'character varying'
	     then 'substring(encode(digest('||col.attname||',''sha512''),''base64'')for char_length('||col.attname||'))'
	     when 'character'
	     then 'substring(encode(digest('||col.attname||',''sha512''),''base64'')for char_length('||col.attname||'))'
	     when 'text'
	     then 'substring(encode(digest('||col.attname||',''sha512''),''base64'')for char_length('||col.attname||'))'
	     when 'timestamp with time zone'
	     then '((abs((''x''||encode(digest(to_hex('||col.attname||'::date-date_trunc(''year'',now())::date),''sha512''),''hex''))::bit(32)::int)*sign('||col.attname||'::date-date_trunc(''year'',now())::date))::int%('||col.attname||'::date-date_trunc(''year'',now())::date)+date_trunc(''year'',now())::date)::timestamp'
	     when 'timestamp without time zone'
	     then '((abs((''x''||encode(digest(to_hex('||col.attname||'::date-date_trunc(''year'',now())::date),''sha512''),''hex''))::bit(32)::int)*sign('||col.attname||'::date-date_trunc(''year'',now())::date))::int%('||col.attname||'::date-date_trunc(''year'',now())::date)+date_trunc(''year'',now())::date)::timestamptz'
	     when 'date'
	     then '(abs((''x''||encode(digest(to_hex('||col.attname||'-date_trunc(''year'',now())::date),''sha512''),''hex''))::bit(32)::int)*sign('||col.attname||'-date_trunc(''year'',now())::date))::int%('||col.attname||'-date_trunc(''year'',now())::date)+date_trunc(''year'',now())::date'
	     when 'bytea'
	     then 'substring(digest('||col.attname||',''sha512'')for length('||col.attname||')+4)'
	     else col.attname::text
	     end
	when 'rand'
	then case format_type(col.atttypid,null)
	     when 'numeric'
	     then 'abs((''x''||encode(gen_random_bytes(8),''hex''))::bit(64)::int8)*sign('||col.attname||')%'||col.attname
	     when 'integer'
	     then '(abs((''x''||encode(gen_random_bytes(4),''hex''))::bit(32)::int)*sign('||col.attname||'))::int%'||col.attname
	     when 'bigint'
	     then '(abs((''x''||encode(gen_random_bytes(8),''hex''))::bit(64)::int8)*sign('||col.attname||'))::int8%'||col.attname
	     when 'double precision'
	     then '(abs((''x''||encode(gen_random_bytes(8),''hex''))::bit(64)::int8)*sign('||col.attname||'::numberic)%'||col.attname||'::numeric)||''::float8'''
	     when 'character varying'
	     then 'substring(encode(gen_random_bytes(32),''base64'')for char_length('||col.attname||'))'
	     when 'character'
	     then 'substring(encode(gen_random_bytes(32),''base64'')for char_length('||col.attname||'))'
	     when 'text'
	     then 'substring(encode(gen_random_bytes(32),''base64'')for char_length('||col.attname||'))'
	     when 'timestamp with time zone'
	     then '((abs((''x''||encode(gen_random_bytes(16),''hex''))::bit(32)::int)*sign('||col.attname||'::date-date_trunc(''year'',now())::date))::int%('||col.attname||'::date-date_trunc(''year'',now())::date)+date_trunc(''year'',now())::date)::timestamp'
	     when 'timestamp without time zone'
	     then '((abs((''x''||encode(gen_random_bytes(16),''hex''))::bit(32)::int)*sign('||col.attname||'::date-date_trunc(''year'',now())::date))::int%('||col.attname||'::date-date_trunc(''year'',now())::date)+date_trunc(''year'',now())::date)::timestamptz'
	     when 'date'
	     then '(abs((''x''||encode(gen_random_bytes(8),''hex''))::bit(32)::int)*sign('||col.attname||'-date_trunc(''year'',now())::date))::int%('||col.attname||'-date_trunc(''year'',now())::date)+date_trunc(''year'',now())::date'
	     when 'bytea'
	     then 'substring(gen_random_bytes(64))for length('||col.attname||')+4)'
	     else col.attname::text
	     end
	else substring(msk.description from '"msk"(.*?)"')
	end
 ,col.attname::text),',')
||e'\n'||'from "'||nam.nspname||'".'||tab.relname||')to stdout;'
||e'\n'||'select ''\.'';'
from      pg_class tab
left join pg_namespace   nam on nam.oid     =tab.relnamespace
     join pg_attribute   col on col.attrelid=tab.oid
left join pg_description msk on msk.objoid  =tab.oid
                            and msk.objsubid=col.attnum
where tab.relkind       ='r'::char
  and tab.relpersistence='p'::char
  and pg_get_userbyid(tab.relowner)=user
  and col.attnum>0
  and not col.attisdropped
--  and tab.relname='ad_menu_bkp_beforeimportwebui'
group by nam.nspname,tab.relname
;
\o masked_data.sql
\i mask.sql
\o
