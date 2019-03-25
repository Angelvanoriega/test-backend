CREATE OR REPLACE FUNCTION FITABLPRO(
	IN fix_usuari character varying,
	IN fix_header character varying,
	IN fix_tablex character varying)
	RETURNS setof json
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
			table_id_   integer;
			user_id_    integer;
			header_id_  integer;
			status      integer;
			total_rows  integer;
			db_name     character varying;
			schema_name character varying;
			table_name  character varying;
			checksum_   character varying;
			table_tmp   character varying;
			username_   character varying;
			StartTime   timestamptz;
			Val_Date    TIMESTAMP;
			tex_query   TEXT;
BEGIN
    StartTime   := clock_timestamp();
    Val_Date    := (SELECT to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'));
	Str_Vacio	:= '';
	status  	:= 0;

	IF fix_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'fix_usuari cannot be void';
	END IF;

	IF fix_header = Str_Vacio THEN
		RAISE EXCEPTION 'fix_header cannot be void';
	END IF;

	IF fix_tablex = Str_Vacio THEN
		RAISE EXCEPTION 'fix_tablex cannot be void';
	END IF;

	header_id_  := cast(fix_header as integer);
	user_id_    := cast(fix_usuari as integer);
	table_id_   := cast(fix_tablex as integer);

	SELECT pu.db_name, au.username, pp.folio, it.name, vh.checksum
		INTO db_name, username_, schema_name, table_name, checksum_
		FROM va_header vh
			INNER JOIN permission_project pp
				ON pp.id = vh.project_id
			INNER JOIN permission_userprofile pu
				ON pu.user_id = vh.user_id
			INNER JOIN auth_user au
				ON au.id = pu.user_id,
			importation_table it
		WHERE vh.user_id = user_id_
		  AND vh.id = header_id_
		  AND it.id = table_id_;

	IF count(table_name) > 0 THEN
		table_tmp := (table_name)  ||'_' || (checksum_);

		CREATE TEMP TABLE drop_tabcls AS
			SELECT __fi_drop_tabcl__(db_name, schema_name, table_name, 
					checksum_, ic.name) as result_
				FROM va_detail vd
					INNER JOIN va_header vh
						ON vh.checksum = vd.checksum
					INNER JOIN ru_rule rr
						ON rr.id = vd.rule_id
					INNER JOIN importation_column ic
						ON ic.id = vd.column_id
					WHERE vh.checksum = checksum_
					  AND vh.id       = header_id_
					  AND vd.table_id = table_id_
					  AND vd.user_id  = user_id_
					ORDER BY ic.id;
		DROP TABLE IF EXISTS drop_tabcls;

		CREATE TEMP TABLE invalids AS
			SELECT __fi_set_invalids__(db_name, schema_name, table_name, checksum_, ic.name,
					(replace(initcap(rr.name),' ', '') || '_' || rr.id), vd.regexp) as result_
				FROM va_detail vd
					INNER JOIN va_header vh
						ON vh.checksum = vd.checksum
					INNER JOIN ru_rule rr
						ON rr.id = vd.rule_id
					INNER JOIN importation_column ic
						ON ic.id = vd.column_id
					WHERE vh.checksum = checksum_
					  AND vh.id       = header_id_
					  AND vd.table_id = table_id_
					  AND vd.user_id  = user_id_
					ORDER BY ic.id;
		DROP TABLE IF EXISTS invalids;

		CREATE TEMP TABLE result_gen AS
			SELECT __fi_set_result_gen__(db_name, schema_name, table_name, checksum_, ic.name,
					(replace(initcap(rr.name),' ', '') || '_' || rr.id), vd.regexp, cast(fa.id as character varying),
					flg.param1, flg.param2)
				FROM fi_layoutgen flg
					INNER JOIN va_detail vd
						ON vd.id = flg.detail_id
					INNER JOIN va_header vh
						ON vh.checksum = vd.checksum
					INNER JOIN ru_rule rr
						ON rr.id = vd.rule_id
					INNER JOIN importation_column ic
						ON ic.id = vd.column_id
					INNER JOIN fi_accion fa
						ON fa.id = flg.accion_id
				WHERE vh.checksum = checksum_
				  AND vh.id = header_id_
				  AND vd.table_id = table_id_
				  AND vd.user_id = user_id_
				ORDER BY ic.id;
		DROP TABLE IF EXISTS result_gen;

		PERFORM __fi_create_table__(db_name, schema_name, table_name, checksum_);

		CREATE TEMP TABLE result_inv AS
			SELECT __fi_set_result__(db_name, schema_name, table_name, checksum_, ic.name,
					(replace(initcap(rr.name),' ', '') || '_' || rr.id), fl.value, fl.result)
				FROM fi_layout fl
					INNER JOIN va_detail vd
						ON vd.id = fl.detail_id
					INNER JOIN va_header vh
						ON vh.checksum = vd.checksum
					INNER JOIN ru_rule rr
						ON rr.id = vd.rule_id
					INNER JOIN importation_column ic
						ON ic.id = vd.column_id
				WHERE vh.checksum = checksum_
				  AND vh.id = header_id_
				  AND vd.table_id = table_id_
				  AND vd.user_id = user_id_
				ORDER BY ic.id;
		DROP TABLE IF EXISTS result_inv;

		tex_query   := __fi_gen_csv__(db_name, schema_name, table_name, table_tmp);

		SELECT (sum(vd.unique_records)+ sum(total_gen)/count(vd.unique_records)) INTO total_rows
            FROM va_detail vd
                LEFT JOIN va_header vh
                    ON vh.checksum = vd.checksum,
            (SELECT (count(ic.id))*(sum(it.total_rows)/count(ic.id)) AS total_gen
                FROM importation_column ic
                    INNER JOIN importation_table it
                        ON ic.table_id = it.id
                WHERE table_id = table_id_) AS total_cols
            WHERE vd.table_id = table_id_
            AND vh.id = header_id_;

		INSERT INTO fi_header(gen_date, duration, total_unicos, link, table_id, user_id,
            header_id)
            VALUES (Val_date, (extract(epoch from (clock_timestamp() - StartTime) )), total_rows, '',
            table_id_, user_id_, header_id_);


		return query
		SELECT row_to_json(result)
				FROM (
					SELECT	tex_query as tex_query,
					        db_name as db_name,
					        '/tmp/' || (table_tmp)  || '.csv' as filepath,
							'' || username_ || '/' || schema_name || '/' || (table_name)  || '.csv' as s3aws,
							clean_end, clean_start, clean_status, id as table_id,
							header_id_ as report_id
						FROM importation_table
						WHERE id = table_id_
					) as result;
	END IF;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
