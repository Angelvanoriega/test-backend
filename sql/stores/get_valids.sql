
CREATE OR REPLACE FUNCTION get_valids(
	IN db_name character varying,
	IN schema_name character varying,
	IN table_name character varying,
	IN column_name character varying,
	IN regexp character varying
)
  RETURNS setof json AS
$BODY$
	declare Str_Vacio	character varying;
	BEGIN
		return query
			SELECT valids
				FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
						'SELECT array_to_json(array_agg(row_to_json(result)))
							FROM (SELECT "'|| (column_name) ||'" as data, count("'||
									(column_name) ||'") as freq FROM "' ||
									(schema_name) || '"."' ||
									(table_name)  ||'" WHERE "'||
									(column_name) ||'" ~ '''|| regexp || ''' AND "' ||
									(column_name) ||'" IS NOT NULL AND "'||
									(column_name) ||'" != '''' group by "'||
									(column_name) ||'" order by 2 DESC) as result;') AS t1(valids json);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
