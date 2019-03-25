
CREATE OR REPLACE FUNCTION vadeprcon(
	IN Tip_Consul character varying,
	IN Val_Usuari character varying,
	IN Val_Detail character varying,
	IN Val_Header character varying)
	RETURNS setof json
AS $BODY$
	/* Declaracion de Constantes */
	declare	Str_Vacio	char(1);
		Tip_ConTip	char(1);
		Tip_Lista	char(1);
		Tip_ConCon	char(1);
		Lis_Correc	char(1);
		Lis_Incorr	char(1);
		Lis_Totals  char(1);
		user_id_    integer;
		detail_id_  integer;
		header_id_  integer;

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	Tip_Lista	:= 'L';
	Lis_Correc	:= '1';
	Lis_Incorr	:= '2';
	Lis_Totals	:= '3';
	user_id_	:= CAST(Val_Usuari AS INTEGER);
	detail_id_	:= CAST(Val_Detail AS INTEGER);
	header_id_	:= CAST(Val_Header AS INTEGER);

	IF Tip_Consul = Str_Vacio THEN
		RAISE EXCEPTION 'Tip_Consul cannot be void';
	END IF;

	IF Val_Usuari = Str_Vacio THEN
		RAISE EXCEPTION 'Val_Usuari cannot be void';
	END IF;

	IF Val_Detail = Str_Vacio THEN
		RAISE EXCEPTION 'Val_Detail cannot be void';
	END IF;

	IF Val_Header = Str_Vacio THEN
		RAISE EXCEPTION 'Val_Header cannot be void';
	END IF;

	Tip_ConTip := substring(Tip_Consul, 1, 1);
	Tip_ConCon := substring(Tip_Consul, 2, 1);

	IF Tip_ConTip = Tip_Lista THEN /* 'L' Listas */
		IF Tip_ConCon = Lis_Correc THEN
			return query
			SELECT row_to_json(result)
				FROM (
					select get_valids(pu.db_name, pp.folio, it."name", ic."name", vd.regexp)
						from va_detail vd
						inner join va_header vh
							on vh.checksum = vd.checksum
						inner join auth_user au
							on au."id" = vd.user_id
						inner join permission_userprofile pu
							on pu.user_id = au."id"
						inner join permission_project pp
							on pp."id" = vd.project_id
						inner join importation_table it
							on it."id" = vd.table_id
						inner join importation_column ic
							on ic."id" = vd.column_id
						where vd."id" = detail_id_
						  and vh."id" = header_id_) as result;
		END IF;
		IF Tip_ConCon = Lis_Incorr THEN

			CREATE TEMP TABLE INVALIDS AS
				select invalids.freq, invalids.data, vd.id as detail_id
					from va_detail vd
					inner join va_header vh
						on vh.checksum = vd.checksum
					inner join auth_user au
						on au."id" = vd.user_id
					inner join permission_userprofile pu
						on pu.user_id = au."id"
					inner join permission_project pp
						on pp."id" = vd.project_id
					inner join importation_table it
						on it."id" = vd.table_id
					inner join importation_column ic
						on ic."id" = vd.column_id
					, get_invalids(pu.db_name, pp.folio, it."name", ic."name", vd.regexp) as invalids
					where vd."id" = detail_id_
					  and vh."id" = header_id_;
--Never mind:
--"The CASE statement evaluates its conditions sequentially and stops with the first condition whose condition is satisfied."
			return query
				SELECT array_to_json(array_agg(row_to_json(result_)))
						FROM (
							SELECT v.data,v.freq,
								CASE WHEN fl.result IS NULL
										AND fa.id   IS NULL
										AND fa.name IS NULL THEN
											CASE WHEN flg.detail_id IS NOT NULL THEN
													  fa2.id
												 ELSE fa.id
											END
									ELSE fa.id
								END AS action_id,
								CASE WHEN fl.result IS NULL
										AND fa.id   IS NULL
										AND fa.name IS NULL THEN
											CASE WHEN flg.detail_id IS NOT NULL THEN
													  fa2.name
												 ELSE fa.name
											END
									ELSE fa.name
								END AS function,
								CASE WHEN fl.result IS NULL
										AND fa.id   IS NULL
										AND fa.name IS NULL THEN
											CASE WHEN flg.param1 = Str_Vacio OR fa2.param1 = 'self' THEN
													  NULL
												WHEN flg.detail_id IS NOT NULL THEN
													  flg.param1
												 ELSE fl.param1
											END
									WHEN fa.param1 = 'self' OR fl.param1 = Str_Vacio  THEN
											NULL
									ELSE fl.param1
								END AS param1,
								CASE WHEN fl.result IS NULL
										AND fa.id   IS NULL
										AND fa.name IS NULL THEN
											CASE WHEN flg.param2 = Str_Vacio OR fa2.param2 = 'self' THEN
													  NULL
												 WHEN flg.detail_id IS NOT NULL THEN
													  flg.param2
												 ELSE fl.param2
											END
									WHEN fa.param2 = 'self' OR fl.param2 = Str_Vacio  THEN
											NULL
									ELSE fl.param2
								END AS param2,
								CASE WHEN fl.result IS NULL
										AND fa.id   IS NULL
										AND fa.name IS NULL THEN
											CASE WHEN flg.detail_id IS NOT NULL THEN
													  __get_result__(cast(flg.accion_id AS character varying),
																	 v.data,
																	 flg.param1,
																	 flg.param2)
												 ELSE fl.result
											END
									ELSE fl.result
								END AS result
							FROM INVALIDS AS v
							LEFT JOIN fi_layout fl
								ON v.data = fl.value
								and fl.detail_id = v.detail_id
							LEFT JOIN fi_accion fa
								ON fa.id = fl.accion_id
							LEFT JOIN fi_layoutgen flg
								ON v.detail_id = flg.detail_id
							LEFT JOIN fi_accion fa2
								ON fa2.id = flg.accion_id) as result_;
		END IF;
		IF Tip_ConCon = Lis_Totals THEN
			return query
				SELECT row_to_json(result)
						FROM (
							select json_array_length(get_valids(pu.db_name, pp.folio, it."name", ic."name", vd.regexp)::json) as valid_totals,
								   count(get_invalids(pu.db_name, pp.folio, it."name", ic."name", vd.regexp)) as invalid_totals
								from va_detail vd
								inner join va_header vh
									on vh.checksum = vd.checksum
								inner join auth_user au
									on au."id" = vd.user_id
								inner join permission_userprofile pu
									on pu.user_id = au."id"
								inner join permission_project pp
									on pp."id" = vd.project_id
								inner join importation_table it
									on it."id" = vd.table_id
								inner join importation_column ic
									on ic."id" = vd.column_id
								where vd."id" = detail_id_
								  and vh."id" = header_id_
							) as result;
		end if;
	END IF;


END; $BODY$ LANGUAGE plpgsql VOLATILE;