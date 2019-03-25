
CREATE OR REPLACE FUNCTION count_valids(
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
            SELECT valids
                FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
                        'SELECT COUNT("'|| (column_name) ||'") FROM "' ||
                                (schema_name) || '"."' ||
                                (table_name)  ||'" WHERE "'||
                                (column_name) ||'" ~ '''|| regexp ||''';') AS t1(valids INTEGER);

END; $BODY$ LANGUAGE plpgsql VOLATILE;
