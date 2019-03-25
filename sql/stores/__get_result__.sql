DROP FUNCTION if exists __get_result__(
    IN fix_accion character varying,
	IN fix_valuex character varying,
	IN fix_param1 character varying,
	IN fix_param2 character varying
);
CREATE OR REPLACE FUNCTION __get_result__(
	IN fix_accion character varying,
	IN fix_valuex character varying,
	IN fix_param1 character varying,
	IN fix_param2 character varying
)
  RETURNS setof character varying AS
$BODY$
	declare Str_Vacio	character varying;
	        accion_id_  integer;
	        sentence    character varying;
			function_   character varying;
			param1_     character varying;
			param2_     character varying;
			result_     character varying;
    BEGIN
	Str_Vacio	:= '';


	IF fix_accion = Str_Vacio THEN
		RAISE EXCEPTION 'fix_accion cannot be void';
	END IF;

	accion_id_  := cast(fix_accion as integer);

	function_   := (SELECT func FROM fi_accion fa WHERE fa."id" = accion_id_);

	param1_     := (SELECT get_param(fa.param1, fa.defparam1, fix_valuex, fix_param1)
						FROM fi_accion fa WHERE fa."id" = accion_id_);

	param2_     := (SELECT get_param(fa.param2, fa.defparam2, fix_valuex, fix_param2)
						FROM fi_accion fa WHERE fa."id" = accion_id_);
	fix_valuex	:= replace(fix_valuex, '''','''''');

	sentence    := 'SELECT ' || function_ || '(''' || fix_valuex || '''' || param1_ || param2_ ||');';

	EXECUTE sentence into result_;

    return query
        SELECT result_ as result;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
