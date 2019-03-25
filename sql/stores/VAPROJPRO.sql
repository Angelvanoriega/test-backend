CREATE OR REPLACE FUNCTION VAPROJPRO(
	IN Val_Usuari character varying,
	IN Val_Projec character varying)
	RETURNS setof JSON
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	CHAR(1);
			Val_Date    TIMESTAMP;
			username_   CHARACTER VARYING;
			user_id_    INTEGER;
			projec_id_  INTEGER;
			checksum_   CHAR(32);
			valid_pro   INTEGER;
			is_valid    INTEGER;
			StartTime   timestamptz;
			EndTime     timestamptz;

BEGIN
	StartTime := clock_timestamp();
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	is_valid    := 0;

	user_id_    := CAST(Val_Usuari AS INTEGER);
	projec_id_  := CAST(Val_Projec AS INTEGER);

	Val_Date    := (SELECT to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'));
	username_   := (SELECT username FROM auth_user WHERE id = user_id_);

	checksum_   := (SELECT md5(array_to_json(array_agg(row_to_json(checksum)))::character varying)
						FROM (
							SELECT ll.rule_id, ll.column_id, rr.regexp
								FROM la_layout ll
									INNER JOIN ru_rule rr
										ON ll.rule_id = rr.id
								WHERE ll.user_id = user_id_
								  AND ll.project_id = projec_id_
								ORDER BY 1,2,3
						) AS checksum);

	valid_pro   := (select count(checksum) from va_header where checksum = checksum_);

	IF valid_pro = is_valid THEN

		UPDATE permission_project
		   SET validation_start = StartTime, validation_end = null
		 WHERE id = projec_id_ and user_id = user_id_;

		CREATE TEMP TABLE WORK_TABLE AS
			SELECT	Val_Date as val_date, ll.user_id, ll.project_id, file_id,
					ll.table_id, column_id, rule_id,
					count_valids(pu.db_name,pp.folio,it.name,ic.name, rr.regexp),
					count_invalids(pu.db_name,pp.folio,it.name,ic.name, rr.regexp),
					count_voids(pu.db_name,pp.folio,it.name,ic.name),
					it.total_rows as count_totals,
					count_unique(pu.db_name,pp.folio,it.name,ic.name, rr.regexp), rr.regexp
					FROM  la_layout ll
						  inner join importation_column ic
							on ll.column_id = ic.id
						  inner join ru_rule rr
							on rr.id = ll.rule_id
						  inner join permission_project pp
							on pp.id = ll.project_id
						  inner join importation_table it
							on ll.table_id = it.id
						  inner join permission_userprofile pu
							on pu.user_id = ll.user_id
					WHERE ll.user_id = user_id_
					  AND ll.project_id = projec_id_;

		INSERT INTO va_detail(
				gen_date, user_id, project_id, file_id, table_id, column_id,
				rule_id, valid_records, invalid_records, void_records,
				total_records, unique_records, checksum, regexp)
			SELECT  wt.val_date, user_id, project_id, file_id, table_id, column_id,
					rule_id, count_valids, count_invalids, count_voids,
					count_totals, count_unique, checksum_, regexp
				FROM WORK_TABLE as wt;

		INSERT INTO va_header(
				gen_date, user_id, project_id, valid_total, invalid_total,
				void_total, total_total, checksum, duration)
			SELECT  wt.val_date, user_id, project_id,
					sum(count_valids) as valid_total,
					sum(count_invalids) as invalid_total,
					sum(count_voids) as void_total,
					sum(count_totals) as total_total,
					(SELECT md5(array_to_json(array_agg(row_to_json(checksum)))::character varying)
						FROM (select rule_id, column_id, regexp
							FROM WORK_TABLE as wt order by 1,2,3
						) as checksum) as checksum,
					(extract(epoch from (clock_timestamp() - StartTime) ))
				FROM WORK_TABLE as wt
				WHERE project_id = projec_id_
				  AND user_id = user_id_
				GROUP BY wt.val_date, user_id, project_id;

		UPDATE permission_project
		   SET validation_end = clock_timestamp(),
				validation_status = 1
		 WHERE id = projec_id_ and user_id = user_id_;

		RETURN query
			SELECT row_to_json(response)
				FROM (
					SELECT	checksum_ as checksum,
						'Proceso correcto' as mensaje,
						'1' as type
					) response;
	ELSE
	    UPDATE permission_project
		   SET validation_status = 1
		 WHERE id = projec_id_ and user_id = user_id_;

    INSERT INTO va_header(
				gen_date, user_id, project_id, valid_total, invalid_total,
				void_total, total_total, checksum, duration)
			SELECT  Val_Date, user_id, project_id, valid_total, invalid_total,
				    void_total, total_total, checksum, duration
				FROM va_header vh
				where vh.checksum = checksum_
				group by user_id, project_id, valid_total, invalid_total,
				    void_total, total_total, checksum, duration, gen_date
				having vh.gen_date = min(vh.gen_date);

		RETURN query
			SELECT row_to_json(response)
				FROM (
					SELECT	checksum_ as checksum,
						'Procesado anteriormente' as mensaje,
						'2' as type
					) response;
	END IF;

END; $BODY$ LANGUAGE plpgsql;