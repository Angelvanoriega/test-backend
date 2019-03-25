
CREATE OR REPLACE FUNCTION count_totals(
    IN db_name character varying,
    IN schema_name character varying,
    IN table_name character varying,
    IN column_name character varying
)
  RETURNS setof integer AS
$BODY$
	BEGIN

        return query
            SELECT totals
                FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
                        'SELECT COUNT("'|| (column_name) ||'") FROM "' ||
                                (schema_name) || '"."' ||
                                (table_name)  ||'";') AS t1(totals INTEGER);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
