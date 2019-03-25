CREATE OR REPLACE FUNCTION FILAGEBAJ(
	IN fix_usuari character varying,
	IN fix_detail character varying,
	IN fix_accion character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			accion_id_  integer;
			user_id_    integer;
			detail_id_  integer;

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

	DELETE FROM fi_layoutgen
		WHERE detail_id = detail_id_
		  AND user_id   = user_id_
		  AND accion_id = accion_id_;

	return query
		SELECT row_to_json(result)
				FROM (
					SELECT	'000000' as codigo,
							'Registro borrado' as mensaje
					) as result;

END; $BODY$ LANGUAGE plpgsql VOLATILE;