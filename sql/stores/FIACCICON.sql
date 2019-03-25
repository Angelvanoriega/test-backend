CREATE OR REPLACE FUNCTION FIACCICON(
	IN tip_consul character varying,
	IN acc_usuari character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			Tip_Lista	char(1);
			Tip_Consut	char(1);
		/* Declaracion de Variables */
			Tip_ConTip	char(1);
			Tip_ConCon	char(1);
			Con_Accion	char(1);
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	Tip_Lista	:= 'L';
	Tip_Consut	:= 'C';
	Con_Accion	:= '1';

	IF Tip_Consul = Str_Vacio THEN
		RAISE EXCEPTION 'Tip_Consul cannot be void';
	END IF;

	IF acc_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'acc_usuari cannot be void';
	END IF;


	Tip_ConTip := substring(Tip_Consul, 1, 1);
	Tip_ConCon := substring(Tip_Consul, 2, 1);

	if Tip_ConTip = Tip_Lista then /* 'L' Listas */
		if Tip_ConCon = Con_Accion then
			return query
			SELECT array_to_json(array_agg(row_to_json(rules)))
                FROM
                    (SELECT fa.id, fa.name, fa.type_id,
                            __get_paramf__(fa.param1) as param1,
                            __get_paramf__(fa.lenparam1) as lenparam1,
                            __get_paramf__(fa.defparam1) as defparam1,
                            __get_paramf__(fa.param2) as param2,
                            __get_paramf__(fa.lenparam2) as lenparam2,
                            __get_paramf__(fa.defparam2) as defparam2
                        FROM
                            (SELECT DISTINCT user_accions.user_id, user_accions.accion_id
                                FROM
                                    (SELECT ppu.user_id, ppa.accion_id
                                        FROM pa_package_accions ppa
                                        INNER JOIN pa_package_users ppu
                                            ON ppu.package_id = ppa.package_id
                                        UNION ALL
                                    SELECT pu.user_id, pua.accion_id
                                        FROM permission_userprofile_accions pua
                                        INNER JOIN permission_userprofile pu
                                            ON pu.id = pua.userprofile_id
                                        INNER JOIN auth_user au
                                            ON pu.user_id = au.id
                                ) AS user_accions
                        ) AS pua
                        INNER JOIN fi_accion fa
                            ON fa.id = pua.accion_id
                        INNER JOIN permission_userprofile pu
                            ON pua.user_id = pu.user_id
                        WHERE pua.user_id = CAST(acc_usuari AS INTEGER)
                    ) AS rules;
		end if;
	end if;

END; $BODY$ LANGUAGE plpgsql VOLATILE;