-- Function: public.aupermcon(character, character)

-- DROP FUNCTION public.aupermcon(character, character);

CREATE OR REPLACE FUNCTION RUSEARCON(
	IN tip_consul character varying,
	IN rul_usuari character varying,
	IN rul_typesx character varying,
	IN rul_catego character varying,
	IN rul_offset character varying,
	IN rul_limitx character varying,
	IN rul_search character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			Tip_Lista	char(1);
			Tip_Consut	char(1);
		/* Declaracion de Variables */
			Tip_ConTip	char(1);
			Tip_ConCon	char(1);
			Con_Layout	char(1);
			con_countr	char(1);
			var_rulesx	text;
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	Tip_Lista	:= 'L';
	Tip_Consut	:= 'C';
	Con_Layout	:= '1';
	con_countr	:= '2';

	IF Tip_Consul = Str_Vacio THEN
		RAISE EXCEPTION 'Tip_Consul cannot be void';
	END IF;

	IF rul_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'rul_usuari cannot be void';
	END IF;

	IF (array_length(regexp_split_to_array(rul_typesx, '"'),1) / 2) > 0 THEN
		rul_typesx := replace(rul_typesx, '[','(');
		rul_typesx := replace(rul_typesx, ']',')');
		rul_typesx := replace(rul_typesx, '"','');
		rul_typesx := 'AND type_id IN ' || rul_typesx;
	ELSE
		rul_typesx := '';
	END IF;

	IF (rul_catego = Str_Vacio) OR (rul_catego = '1') THEN --general
		rul_catego := ' order by name asc';
	ELSIF rul_catego = '2' THEN -- favoritos
		rul_catego := ' AND favorite is TRUE order by name asc';
	ELSIF rul_catego = '3' THEN -- frecuente
		rul_catego := ' order by frecuency desc';
	ELSE 
		rul_catego := '';
	END IF;

	IF rul_offset = Str_Vacio THEN
		rul_offset := '0';
	END IF;

	IF rul_limitx = Str_Vacio THEN
		rul_limitx := '100000000';
	END IF;

	IF	rul_search <> Str_Vacio THEN
		rul_search := ' AND (lower(name) like ''%' || lower(rul_search)
			|| '%'' OR lower(description) like ''%' || lower(rul_search)
			|| '%'' OR lower(tags::text) like ''%' || lower(rul_search) || '%'') ';
	END IF;

	Tip_ConTip := substring(Tip_Consul, 1, 1);
	Tip_ConCon := substring(Tip_Consul, 2, 1);

	DROP TABLE IF EXISTS RULEZ;
	CREATE TEMP TABLE RULEZ AS
		(SELECT rr.id, rr.name, rr.description, rt.id AS type_id, rt.name AS type, pur.user_id,
				CASE WHEN puf.rule_id IS NULL THEN false
				ELSE true
				END AS favorite,
				count(ll.rule_id) as frecuency,
				(SELECT array_to_json(array_agg(row_to_json(tagx)))
					FROM
						(SELECT rt.id, rt.name
							FROM ru_tag rt
							INNER JOIN ru_rule_tags rrt
								ON rt.id = rrt.tag_id
							INNER JOIN ru_rule rr_
								ON rrt.rule_id = rr_.id
							WHERE rr_.id = rr.id
						) AS tagx
				) AS tags
				FROM
					(SELECT DISTINCT user_rules.user_id, user_rules.rule_id
						FROM
							(SELECT ppu.user_id, ppr.rule_id
								FROM pa_package_rules ppr
								INNER JOIN pa_package_users ppu
									ON ppu.package_id = ppr.package_id
								UNION ALL
							SELECT pu.user_id, pur.rule_id
								FROM permission_userprofile_rules pur
								INNER JOIN permission_userprofile pu
									ON pu.id = pur.userprofile_id
								INNER JOIN auth_user au
									ON pu.user_id = au.id
						) AS user_rules
				) AS pur
				INNER JOIN ru_rule rr
					ON rr.id = pur.rule_id
				INNER JOIN ru_type rt
					ON rt.id = rr.type_id
				INNER JOIN permission_userprofile pu
					ON pur.user_id = pu.user_id
				LEFT  JOIN permission_userprofile_favs puf
					ON pur.rule_id = puf.rule_id
					AND puf.userprofile_id = pu.id
				LEFT JOIN la_layout ll
					ON pur.rule_id = ll.rule_id
					AND pur.user_id = ll.user_id
				group by rr.id, rr.name, rt.name, rr.description, puf.rule_id, rt.id, pur.user_id);

	var_rulesx := 'SELECT RULEZ.* FROM RULEZ';

	if Tip_ConTip = Tip_Consut then /* 'L' Listas */
		if Tip_ConCon = Con_Layout then
			return query 
			EXECUTE '
			SELECT array_to_json(array_agg(row_to_json(rules)))
				FROM
					( ' || var_rulesx || '
						WHERE user_id = '|| rul_usuari ||
							rul_typesx || rul_search || rul_catego || ' OFFSET ' || rul_offset || ' LIMIT ' || rul_limitx || '
				) AS rules';
		end if;
	end if;

	if Tip_ConTip = Tip_Consut then /* 'L' Listas */
		if Tip_ConCon = con_countr then
			return query 
				EXECUTE '
				select row_to_json(TotReg)
					from (
						select count(*) as total
							from (' || var_rulesx || '
							WHERE user_id = '|| rul_usuari ||
								rul_typesx || rul_search || rul_catego || ') as TotReg) as TotReg';
		end if;
	end if;

END; $BODY$ LANGUAGE plpgsql VOLATILE;