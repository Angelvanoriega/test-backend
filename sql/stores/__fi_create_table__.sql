
CREATE OR REPLACE FUNCTION __fi_create_table__(
	IN db_name		character varying,
	IN schema_name	character varying,
	IN table_name	character varying,
	IN checksum		character varying
) RETURNS void  AS $BODY$
	declare con_name	character varying;
			new_table	character varying;
			ori_table	character varying;
BEGIN

	con_name	:= cast(clock_timestamp() as character varying);
	ori_table	:= (schema_name || '"."' || table_name);
	new_table	:= ( ori_table  ||  '__'  || checksum);

	PERFORM		dblink_connect(con_name, 'user=dataclean password=da8T_mEjUPr8 dbname=' || db_name || '');
	PERFORM		dblink_exec(con_name, 'DROP TABLE IF EXISTS "' || new_table || '";');
	PERFORM		dblink_disconnect(con_name);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
