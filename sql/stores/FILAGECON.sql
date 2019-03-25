CREATE OR REPLACE FUNCTION FILAGECON(
	IN tip_consul character varying,
	IN fix_usuari character varying,
	IN fix_detail character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			user_id_    integer;
			detail_id_  integer;

			Tip_ConTip	char(1);
			Tip_ConCon	char(1);

			Tip_Consu	char(1);
			Con_AccGen	char(1);

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	Tip_Consu	:= 'C';
	Con_AccGen	:= '1';

	IF tip_consul = Str_Vacio THEN
		RAISE EXCEPTION 'tip_consul cannot be void';
	END IF;

	IF fix_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'fix_usuari cannot be void';
	END IF;

	IF fix_detail = Str_Vacio THEN
		RAISE EXCEPTION 'fix_detail cannot be void';
	END IF;

	user_id_    := cast(fix_usuari as integer);
	detail_id_  := cast(fix_detail as integer);
	Tip_ConTip  := substring(Tip_Consul, 1, 1);
	Tip_ConCon  := substring(Tip_Consul, 2, 1);

	IF Tip_ConTip = Tip_Consu THEN /* 'L' Listas */
		IF Tip_ConCon = Con_AccGen THEN

		return query
		SELECT row_to_json(result)
				FROM (
					SELECT  fa.id as action_id, fa.name as function,
							CASE WHEN flg.param1 IS NULL OR flg.param1 = '''' OR flg.param1 = Str_Vacio
								THEN NULL
								ELSE flg.param1
							END AS param1,
							CASE WHEN flg.param2 IS NULL OR flg.param2 = '''' OR flg.param2 = Str_Vacio
								THEN NULL
								ELSE flg.param2
							END AS param2
						FROM fi_layoutgen flg
						INNER JOIN fi_accion fa
							ON flg.accion_id = fa.id
						WHERE flg.user_id   = user_id_
						  and flg.detail_id = detail_id_
					) as result;

		END IF;
	END IF;

END; $BODY$ LANGUAGE plpgsql VOLATILE;