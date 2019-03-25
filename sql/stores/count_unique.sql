
CREATE OR REPLACE FUNCTION count_unique(
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
            SELECT unique_
                FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
                        'SELECT COUNT( DISTINCT "'|| (column_name) ||'") FROM "' ||
                                (schema_name) || '"."' ||
                                (table_name)  ||'";') AS t1(unique_ INTEGER);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
