CREATE OR REPLACE FUNCTION laviascon(
	IN Tip_Consul character varying,
	IN Lay_Usuari character varying,
	IN Lay_Projec character varying)
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
		    FI_REMOVED  INTEGER;
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	Tip_Lista	:= 'L';
	Tip_Consut	:= 'C';
	Con_Layout	:= '1';
	FI_REMOVED  := 5;

	IF Tip_Consul = Str_Vacio THEN
		RAISE EXCEPTION 'Tip_Consul cannot be void';
	END IF;

	Tip_ConTip := substring(Tip_Consul, 1, 1);
	Tip_ConCon := substring(Tip_Consul, 2, 1);

	if Tip_ConTip = Tip_Consut then /* 'L' Listas */
		if Tip_ConCon = Con_Layout then
			return query 
				SELECT array_to_json(array_agg(row_to_json(files)))
					FROM (
						SELECT if.id, if.name, if.folio, if.checksum, if.status, 'file' as _entity,
							(SELECT array_to_json(array_agg(row_to_json(tables)))
								FROM (
									SELECT it.id, it.name, 'table' as _entity,
										(SELECT array_to_json(array_agg(row_to_json(columns)))
											FROM (
												SELECT ic.id, ic.name, 'column' as _entity,
													(SELECT array_to_json(array_agg(row_to_json(rules)))
														FROM (
															SELECT rr.id, rr.name, 'rule' as _entity
																FROM la_layout ll
																	inner join ru_rule rr
																	on rr.id = ll.rule_id
																WHERE ll.column_id = ic.id
															) AS rules
														) AS rules
													FROM importation_column ic
													WHERE ic.table_id = it.id
													  and it.active = TRUE
													order by ic.id ASC
												) AS columns
											) AS columns
										FROM importation_table it
										WHERE it.file_upload_id = if.id
										  AND it.active = true
									) AS tables
								) AS tables
							FROM importation_file if
								inner join permission_project pp
									on pp."id" = if.project_id
							WHERE pp.id = CAST(Lay_Projec AS INTEGER)
							  AND pp.user_id = CAST(Lay_Usuari AS INTEGER)
							  and if.status <> FI_REMOVED
							  order BY if.date_load DESC
						) AS files;
		end if;
	end if;

END; $BODY$ LANGUAGE plpgsql VOLATILE;