CREATE OR REPLACE FUNCTION FITACLBAJ(
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
			db_name     character varying;
			schema_name character varying;
			table_name  character varying;
			checksum_   character varying;
BEGIN
	Str_Vacio	:= '';

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

	SELECT pu.db_name, pp.folio, it.name, vh.checksum
		INTO db_name, schema_name, table_name, checksum_
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

		UPDATE  importation_table
		   SET  clean_end    = clock_timestamp(),
				clean_status = 1
		WHERE id = table_id_;

		return query
		SELECT row_to_json(result)
				FROM (
					SELECT  clean_end, clean_status
						FROM importation_table
						WHERE id = table_id_
					) as result;
	END IF;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
