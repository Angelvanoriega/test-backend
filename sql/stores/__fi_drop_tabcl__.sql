
CREATE OR REPLACE FUNCTION __fi_drop_tabcl__(
	IN db_name		character varying,
	IN schema_name	character varying,
	IN table_name	character varying,
	IN checksum		character varying,
	IN column_name	character varying
) RETURNS setof integer  AS $BODY$
	declare con_name	character varying;
			ori_table	character varying;
			tab_col_na	character varying;
BEGIN

	con_name	:= cast(clock_timestamp() as character varying);
	ori_table	:= (schema_name || '"."' || table_name);
	tab_col_na	:= ( ori_table  ||  '_'  || md5(column_name || '_' || checksum));

	PERFORM		dblink_connect(con_name, 'user=dataclean password=da8T_mEjUPr8 dbname=' || db_name || '');
	PERFORM		dblink_exec(con_name,	'DROP TABLE IF EXISTS "' || tab_col_na || '";');
	PERFORM		dblink_disconnect(con_name);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
