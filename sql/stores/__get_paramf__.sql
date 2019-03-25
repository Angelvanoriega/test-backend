DROP FUNCTION __get_paramf__(character varying);
CREATE OR REPLACE FUNCTION __get_paramf__(
	IN param character varying
)
  RETURNS setof character varying AS
$BODY$
	declare Str_Vacio	character varying;
BEGIN

	Str_Vacio	:= '';

	return query
		SELECT
			CASE
			   WHEN param = 'self' OR param = 'default' OR param = 'void' OR  param = Str_Vacio THEN
					NULL
			   ELSE param
			END;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
