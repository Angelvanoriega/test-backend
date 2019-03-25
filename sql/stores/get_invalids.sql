
CREATE OR REPLACE FUNCTION get_invalids(
	IN db_name character varying,
	IN schema_name character varying,
	IN table_name character varying,
	IN column_name character varying,
	IN regexp character varying
)
  RETURNS TABLE (data character varying, freq INTEGER) AS
$BODY$
	BEGIN

	return query
		SELECT t1.data, t1.freq
			FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
					'SELECT "'|| (column_name) ||'" as data, count(*) as freq FROM "' ||
						(schema_name) || '"."' ||
						(table_name)  ||'" WHERE "'||
						(column_name) ||'" !~ '''|| regexp || ''' AND "' ||
						(column_name) ||'" IS NOT NULL AND "'||
						(column_name) ||'" != '''' group by "'||
						(column_name) ||'" order by 2 DESC') AS t1(data character varying, freq INTEGER);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
