CREATE OR REPLACE FUNCTION aupermcon(
	IN Tip_Consul character varying,
	IN Per_Usuari character varying,
	IN Per_Permid character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			Tip_Lista	char(1);
		/* Declaracion de Variables */
			Tip_ConTip	char(1);
			Tip_Consut	char(1);
			Tip_ConCon	char(1);
			Lis_Permi	char(1);
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	Tip_Lista	:= 'L';
	Tip_Consut	:= 'C';
	Lis_Permi	:= '1';

	IF Tip_Consul = Str_Vacio THEN
		RAISE EXCEPTION 'Tip_Consul cannot be void';
	END IF;

	IF Per_Usuari = Str_Vacio THEN
		RAISE EXCEPTION 'Per_Usuari cannot be void';
	END IF;

	Tip_ConTip := substring(Tip_Consul, 1, 1);
	Tip_ConCon := substring(Tip_Consul, 2, 1);

	if Tip_ConTip = Tip_Lista then /* 'L' Listas */
		if Tip_ConCon = Lis_Permi then
			return query 
					SELECT row_to_json(auth_user)
						FROM (
							SELECT id, username, (
								SELECT array_to_json(array_agg(row_to_json(permissions)))
									FROM (
										SELECT auup.permission_id as id, ap.codename
											FROM auth_permission ap
											INNER JOIN auth_user_user_permissions auup
												ON auup.permission_id = ap.id
											WHERE auup.user_id = auth_user.id
										UNION
										SELECT ap.id as id, ap.codename
											FROM auth_permission ap
											INNER JOIN auth_group_permissions agp
												ON agp.permission_id = ap.id
											INNER JOIN auth_user_groups aug
												ON aug.group_id = agp.group_id
											WHERE aug.user_id = auth_user.id
										) AS permissions
								) AS permissions
							FROM auth_user
							WHERE auth_user.id = cast(Per_Usuari as integer)
						) AS auth_user;
		end if;
	end if;

	if Tip_ConTip = Tip_Consut then /* 'C' Consultas */
		if Tip_ConCon = Lis_Permi then
			return query
					SELECT row_to_json(auth_user)
						FROM (
							SELECT id, username, (
								SELECT row_to_json(permission)
									FROM (
										SELECT auup.permission_id as id, ap.codename
											FROM auth_permission ap
											INNER JOIN auth_user_user_permissions auup
												ON auup.permission_id = ap.id
											WHERE auup.user_id = auth_user.id
											  AND ap.id = cast(Per_Permid as integer)
										UNION
										SELECT ap.id as id, ap.codename
											FROM auth_permission ap
											INNER JOIN auth_group_permissions agp
												ON agp.permission_id = ap.id
											INNER JOIN auth_user_groups aug
												ON aug.group_id = agp.group_id
											WHERE aug.user_id = auth_user.id
											  AND ap.id = cast(Per_Permid as integer)
										) AS permission
								) AS permission
							FROM auth_user
							WHERE auth_user.id = cast(Per_Usuari as integer)
						) AS auth_user;
		end if;
	end if;

END; $BODY$ LANGUAGE plpgsql VOLATILE;