
CREATE OR REPLACE FUNCTION count_voids(
    IN db_name character varying,
    IN schema_name character varying,
    IN table_name character varying,
    IN column_name character varying
)
  RETURNS setof integer AS
$BODY$
	BEGIN

        return query
            SELECT voids
                FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
                        'SELECT COUNT("'|| (column_name) ||'") FROM "' ||
                                (schema_name) || '"."' ||
                                (table_name)  ||'"  WHERE "'||
                                (column_name) ||'" IS NULL or "'||
                                (column_name) ||'" = '''';') AS t1(voids INTEGER);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
