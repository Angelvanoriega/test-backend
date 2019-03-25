
CREATE OR REPLACE FUNCTION count_invalids(
    IN db_name character varying,
    IN schema_name character varying,
    IN table_name character varying,
    IN column_name character varying,
    IN regexp character varying
)
  RETURNS setof integer AS
$BODY$
	BEGIN

        return query
            SELECT invalids
                FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
                        'SELECT COUNT("'|| (column_name) ||'") FROM "' ||
                                (schema_name) || '"."' ||
                                (table_name)  ||'" WHERE "'||
                                (column_name) ||'" !~ '''|| regexp || ''' AND "' ||
                                (column_name) ||'" IS NOT NULL AND "'||
                                (column_name) ||'" != '''';') AS t1(invalids INTEGER);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
