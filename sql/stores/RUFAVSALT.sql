CREATE OR REPLACE FUNCTION rufavsalt(
	IN Rul_Usuari character varying,
	IN Rul_Rulexx character varying)
	RETURNS setof json
AS $BODY$
	/* Declaracion de Constantes */
	declare	Str_Vacio	char(1);
			userprofile int;
			rule_id_    int;
			user_id_    int;

BEGIN
    Str_Vacio	:= '';

	IF Rul_Usuari = Str_Vacio THEN
		RAISE EXCEPTION 'Rul_Usuari cannot be void';
	END IF;

	IF Rul_Rulexx = Str_Vacio THEN
		RAISE EXCEPTION 'Rul_Rulexx cannot be void';
	END IF;

	rule_id_    := CAST(Rul_Rulexx AS INTEGER);
	user_id_    := CAST(Rul_Usuari AS INTEGER);

	userprofile = (SELECT id FROM public.permission_userprofile
		WHERE user_id = user_id_);

	INSERT INTO permission_userprofile_favs(userprofile_id, rule_id)
		VALUES (userprofile, rule_id_);

	return query
		SELECT row_to_json(result)
				FROM (
					SELECT	'Favorito agregado' as mensaje,
							user_id_ as user_id,
							rule_id_ as rule_id
					) as result;


END; $BODY$ LANGUAGE plpgsql VOLATILE;