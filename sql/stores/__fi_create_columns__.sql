
CREATE OR REPLACE FUNCTION __fi_create_columns__(
	IN db_name		character varying,
	IN schema_name	character varying,
	IN table_name	character varying,
	IN column_name	character varying,
	IN rule_name	text
) RETURNS setof integer AS $BODY$
	declare con_name	character varying;
BEGIN

	con_name	:= cast(clock_timestamp() as character varying);

	PERFORM dblink_connect(con_name, 'user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '');
	PERFORM dblink_exec(con_name, 'ALTER TABLE "' ||
									(schema_name) || '"."' ||
									(table_name)  || '" ADD "' ||
									(column_name) || '_' ||
									(rule_name)   || '_Invalids" text;');
	PERFORM dblink_disconnect(con_name);

	RETURN query
		SELECT 1;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
