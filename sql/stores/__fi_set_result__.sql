CREATE OR REPLACE FUNCTION __fi_set_result__(
	IN db_name		character varying,
	IN schema_name	character varying,
	IN table_name	character varying,
	IN checksum		character varying,
	IN column_name	character varying,
	IN rule_name	text,
	IN fix_valuex	character varying,
	IN fix_result	character varying
)
  RETURNS setof integer AS
$BODY$
	declare Str_Vacio	character varying;
			con_name	character varying;
			ori_table	character varying;
			tab_col_na	character varying;
			col_rul_na	character varying;
			md5_colname	character varying;

	BEGIN

	Str_Vacio	:= '';
	con_name	:= cast(clock_timestamp() as character varying);
	ori_table	:= (schema_name || '"."' || table_name);
	tab_col_na	:= ( ori_table  ||  '_'  || md5(column_name ||  '_'  || checksum));
	col_rul_na	:= (column_name	||  '_'	 || rule_name	|| '_Result');
	md5_colname	:= (column_name ||  '_'  || md5(ori_table || '_' || column_name));

	PERFORM		dblink_connect(con_name, 'user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '');

	PERFORM		dblink_exec(con_name,	'CREATE INDEX IF NOT EXISTS "' ||
											(md5_colname)	|| '" ON "' ||
											(ori_table)		|| '"("' ||
											(column_name)	|| '" COLLATE pg_catalog."en_US.utf8" text_pattern_ops);');

	PERFORM		dblink_exec(con_name,	'CREATE INDEX IF NOT EXISTS "' ||
											(md5_colname)	|| '_" ON "' ||
											(ori_table)		|| '"("' ||
											(column_name)	|| '" COLLATE pg_catalog."en_US.utf8");');

	PERFORM		dblink_exec(con_name,	'CREATE TABLE IF NOT EXISTS "'|| tab_col_na ||'" AS
											SELECT DISTINCT "' ||
												(column_name)  || '" FROM "' ||
												(ori_table)	   || '";');

	PERFORM		dblink_exec(con_name,	'ALTER TABLE "'		||
											(tab_col_na)	|| '" ADD COLUMN IF NOT EXISTS "' ||
											(col_rul_na)	|| '" text;');

	PERFORM		dblink_exec(con_name,	'UPDATE "'
											|| (tab_col_na)	|| '" SET "' 
											|| (col_rul_na)	|| '" = ''' 
											|| (fix_result) || ''' WHERE "'    
											|| (column_name)|| '" = '''        
											|| (fix_valuex) || ''';' );

	PERFORM dblink_disconnect(con_name);

	return query
		select 1;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
