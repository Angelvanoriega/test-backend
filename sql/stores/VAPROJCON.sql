CREATE OR REPLACE FUNCTION VAPROJCON(
	IN Tip_Consul character varying,
	IN Val_Usuari character varying,
	IN Val_Projec character varying)
	RETURNS setof JSON
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			Tip_Lista	char(1);
			Tip_Consut	char(1);
		/* Declaracion de Variables */
			Tip_ConTip	char(1);
			Tip_ConCon	char(1);
			Con_Layout	char(1);
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	Tip_Lista	:= 'L';
	Tip_Consut	:= 'C';
	Con_Layout	:= '1';

	IF Tip_Consul = Str_Vacio THEN
		RAISE EXCEPTION 'Tip_Consul cannot be void';
	END IF;

	IF Val_Usuari = Str_Vacio THEN
		RAISE EXCEPTION 'Val_Usuari cannot be void';
	END IF;

	IF Val_Projec = Str_Vacio THEN
		RAISE EXCEPTION 'Val_Projec cannot be void';
	END IF;

	Tip_ConTip := substring(Tip_Consul, 1, 1);
	Tip_ConCon := substring(Tip_Consul, 2, 1);

	IF Tip_ConTip = Tip_Lista THEN /* 'L' Listas */
		IF Tip_ConCon = Con_Layout THEN
			RETURN query
				SELECT row_to_json(report)
					FROM (
						SELECT vh.id, vh.gen_date, vh.checksum, 'report' as _entity,
							(SELECT row_to_json(_results)
								FROM (
									SELECT  sum(vd.valid_records) as valid_records,
											round(((cast(sum(vd.valid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as valid,
											sum(vd.invalid_records)as invalid_records,
											round(((cast(sum(vd.invalid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as invalid,
											sum(vd.void_records) as void_records,
											round(((cast(sum(vd.void_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as voids,
											sum(vd.total_records) as total_records, 'result' as _entity
										FROM va_detail vd
													WHERE vd.project_id = pp.id
													  and vd.checksum = vh.checksum
													GROUP BY vd.project_id
											) AS _results
										) AS _results,
									(SELECT array_to_json(array_agg(row_to_json(files)))
										FROM (
											SELECT if.id, if.name, if.folio, if.checksum, if.status, 'file' as _entity,
												(SELECT array_to_json(array_agg(row_to_json(tables)))
													FROM (
														SELECT it.id, it.name, 'table' as _entity, it.clean_status,
															(SELECT array_to_json(array_agg(row_to_json(columns)))
																FROM (
																	SELECT ic.id, ic.name, 'column' as _entity,
																		(SELECT row_to_json(_results)
																			FROM (
																				SELECT  sum(vd.valid_records) as valid_records,
																						round(((cast(sum(vd.valid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as valid,
																						sum(vd.invalid_records)as invalid_records,
																						round(((cast(sum(vd.invalid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as invalid,
																						sum(vd.void_records) as void_records,
																						round(((cast(sum(vd.void_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as voids,
																						sum(vd.total_records) as total_records, 'result' as _entity
																					FROM va_detail vd
																					WHERE vd.column_id = ic.id
																					  and vd.checksum = vh.checksum
																					GROUP BY vd.column_id
																			) AS _results
																		) AS _results,
																		(SELECT array_to_json(array_agg(row_to_json(rules)))
																			FROM (
																				SELECT  rr.id, rr.name, 'rule' as _entity,
																					(SELECT row_to_json(_results)
																						FROM (
																							SELECT
																								vd.id,
																								sum(vd.valid_records) as valid_records,
																								round(((cast(sum(vd.valid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as valid,
																								sum(vd.invalid_records) as invalid_records,
																								round(((cast(sum(vd.invalid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as invalid,
																								sum(vd.void_records) as void_records,
																								round(((cast(sum(vd.void_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as voids,
																								sum(vd.total_records) as total_records
																							FROM va_detail vd
																							WHERE   vd.column_id = ic.id
																							  and   vd.rule_id = rr.id
																							  and   vd.checksum = vh.checksum
																							  group by vd.id
																							) AS _results
																						) AS _results
																					FROM ru_rule rr
																				) AS rules
																				WHERE _results IS NOT NULL
																		) AS rules
																		FROM importation_column ic
																		WHERE ic.table_id = it.id
																		  AND it.active = TRUE
																	) AS columns
																	WHERE rules IS NOT NULL
															) AS columns,
															(SELECT row_to_json(_results)
																FROM (
																	SELECT  sum(vd.valid_records) as valid_records,
																			round(((cast(sum(vd.valid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as valid,
																			sum(vd.invalid_records)as invalid_records,
																			round(((cast(sum(vd.invalid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as invalid,
																			sum(vd.void_records) as void_records,
																			round(((cast(sum(vd.void_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as voids,
																			sum(vd.total_records) as total_records, 'result' as _entity
																		FROM va_detail vd
																		WHERE vd.table_id = it.id
																		  and vd.checksum = vh.checksum
																		GROUP BY vd.table_id
																	) AS _results
															) AS _results
															FROM importation_table it
															WHERE it.file_upload_id = if.id
														) AS tables
														WHERE columns IS NOT NULL
													) AS tables,
													(SELECT row_to_json(_results)
														FROM (
															SELECT  sum(vd.valid_records) as valid_records,
																	round(((cast(sum(vd.valid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as valid,
																	sum(vd.invalid_records)as invalid_records,
																	round(((cast(sum(vd.invalid_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as invalid,
																	sum(vd.void_records) as void_records,
																	round(((cast(sum(vd.void_records) as numeric) / cast(sum(vd.total_records) as numeric)) * 100),2) as voids,
																	sum(vd.total_records) as total_records, 'result' as _entity
																FROM va_detail vd
																WHERE vd.file_id = if.id
																  and vd.checksum = vh.checksum
																GROUP BY vd.file_id
														) AS _results
													) AS _results
												FROM importation_file if
												WHERE if.project_id = pp.id
											) AS files
											WHERE tables IS NOT NULL
										) AS files
									FROM permission_project pp
										inner join va_header vh
											on vh.project_id = pp.id
									WHERE pp.id = CAST(Val_Projec AS INTEGER)
										AND pp.user_id = CAST(Val_Usuari AS INTEGER)
										and vh.gen_date = (select max(gen_date)
															from va_header
															where project_id = CAST(Val_Projec AS INTEGER)
															  and user_id = CAST(Val_Usuari AS INTEGER))
								) AS report
							WHERE files IS NOT NULL;
		end if;
	end if;

	IF Tip_ConTip = Tip_Consut THEN /* 'L' Listas */
		IF Tip_ConCon = Con_Layout THEN
			RETURN query
				SELECT row_to_json(response)
					FROM (
						SELECT project_id, validation_status,
                                   sum(count_totals) AS count_totals,
                                   (CASE
                                        WHEN (extract(epoch
                                                      FROM (clock_timestamp() - validation_start))) >= SUM(stimated_time) THEN 0
                                        ELSE (sum(stimated_time) - (extract(epoch
                                                                            FROM (clock_timestamp() - validation_start))))
                                    END) AS time_left,
                                   sum(stimated_time) AS stimated_time
                            FROM
                              (SELECT rr.id AS rule_id,
                                      pp."id" AS project_id,
                                      ll.user_id,
                                      pp.validation_status,
                                      pp.validation_start,
                                      SUM(it.total_rows) AS count_totals,
                                      (SUM(it.total_rows) *
                                         (SELECT (sum(cast(duration AS decimal)) / sum(total_total))
                                          FROM va_header vh
                                          INNER JOIN va_detail vd ON vh.checksum = vd.checksum
                                          AND vd.rule_id = rr.id)) AS stimated_time
                               FROM la_layout ll
                                   INNER JOIN importation_column ic ON ll.column_id = ic.id
                                   INNER JOIN ru_rule rr ON rr.id = ll.rule_id
                                   INNER JOIN permission_project pp ON pp.id = ll.project_id
                                   INNER JOIN importation_table it ON ll.table_id = it.id
                                   INNER JOIN auth_user au ON au.id = ll.user_id
                               GROUP BY pp."id",
                                        pp.validation_status,
                                        pp.validation_start,
                                        rr.id,
                                        ll.user_id,
                                        validation_start) statimated_by_rule
                            WHERE statimated_by_rule.project_id = CAST(Val_Projec AS INTEGER)
                              AND statimated_by_rule.user_id = CAST(Val_Usuari AS INTEGER)
                            GROUP BY statimated_by_rule.project_id,
                                     validation_status,
                                     validation_start) AS response;
		END IF;
	END IF;

END; $BODY$ LANGUAGE plpgsql VOLATILE;