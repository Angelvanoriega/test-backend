CREATE OR REPLACE FUNCTION FILAYOBAJ(
	IN fix_usuari character varying,
	IN fix_detail character varying,
	IN fix_accion character varying,
	IN fix_valuex character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			accion_id_  integer;
			user_id_    integer;
			detail_id_  integer;
			param1_     character varying;
			param2_     character varying;
			function_   character varying;
			result_     character varying;
			id_         integer;
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

	accion_id_  := cast(fix_accion as integer);
	user_id_    := cast(fix_usuari as integer);
	detail_id_  := cast(fix_detail as integer);

	DELETE FROM fi_layout
		WHERE detail_id = detail_id_
		  and value     = fix_valuex
		  and user_id   = user_id_;

	select flg.param1, flg.param2, fa.name, fa.id
		into param1_, param2_, function_, id_
		from fi_layoutgen flg
			inner join fi_accion fa
			  on fa.id = flg.accion_id
		where detail_id = detail_id_ and user_id = user_id_;

	if function_ is not null then
		result_ := __get_result__(cast(id_ as character varying), fix_valuex, param1_, param2_);
	end if;

	return query
		SELECT row_to_json(response)
				FROM (
					SELECT	id_       as action_id,
							result_   as result,
							case when param1_ = Str_Vacio then null else param1_ end as param1,
							case when param2_ = Str_Vacio then null else param2_ end as param2_,
							function_ as function
					) as response;

END; $BODY$ LANGUAGE plpgsql VOLATILE;