CREATE OR REPLACE FUNCTION FILAYOALT(
	IN fix_usuari character varying,
	IN fix_detail character varying,
	IN fix_accion character varying,
	IN fix_valuex character varying,
	IN fix_param1 character varying,
	IN fix_param2 character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			accion_id_  integer;
			user_id_    integer;
			detail_id_  integer;
			param1_     character varying;
			param2_     character varying;
			result_     character varying;
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';

	IF fix_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'fix_usuari cannot be void';
	END IF;

	IF fix_detail = Str_Vacio THEN
		RAISE EXCEPTION 'fix_detail cannot be void';
	END IF;

	IF fix_accion = Str_Vacio THEN
		RAISE EXCEPTION 'fix_accion cannot be void';
	END IF;

	IF fix_valuex = Str_Vacio THEN
		RAISE EXCEPTION 'fix_valuex cannot be void';
	END IF;

	accion_id_  := cast(fix_accion as integer);
	user_id_  := cast(fix_usuari as integer);
	detail_id_  := cast(fix_detail as integer);

	param1_     := (SELECT get_param(fa.param1, fa.defparam1, fix_valuex, fix_param1)
						FROM fi_accion fa WHERE fa."id" = accion_id_);
	SELECT SUBSTR(param1_, 2, LENGTH(param1_)) INTO param1_;
	param1_   := replace(param1_, '''', '');

	param2_     := (SELECT get_param(fa.param2, fa.defparam2, fix_valuex, fix_param2)
						FROM fi_accion fa WHERE fa."id" = accion_id_);
	SELECT SUBSTR(param2_, 2, LENGTH(param2_)) INTO param2_;
	param2_   := replace(param2_, '''', '');


	result_     := __get_result__(fix_accion, fix_valuex, param1_, param2_);

	UPDATE fi_layout
		SET "result" = result_, param1 = param1_,
			param2 = param2_, accion_id = accion_id_
		WHERE detail_id = detail_id_
		  and value     = fix_valuex
		  and user_id   = user_id_;

	INSERT INTO fi_layout(value, param1, param2, result, accion_id, detail_id, user_id)
		SELECT fix_valuex, param1_, param2_, result_, accion_id_, detail_id_, user_id_
		WHERE NOT EXISTS (SELECT 1 FROM fi_layout
							  WHERE detail_id = detail_id_
								and value     = fix_valuex
								and user_id   = user_id_);

	return query
		SELECT row_to_json(response)
					FROM (
						SELECT result
							FROM fi_layout fl
							WHERE fl.detail_id = detail_id_ and value = fix_valuex
							) as response;

END; $BODY$ LANGUAGE plpgsql VOLATILE;