CREATE OR REPLACE FUNCTION __fi_set_result_gen__(
	IN db_name		character varying,
	IN schema_name	character varying,
	IN table_name	character varying,
	IN checksum		character varying,
	IN column_name	character varying,
	IN rule_name	text,
	IN regexp		character varying,
	IN fix_accion	character varying,
	IN fix_param1	character varying,
	IN fix_param2	character varying
)
  RETURNS setof integer AS
$BODY$
	declare Str_Vacio	character varying;
			accion_id_	integer;
			function_	character varying;
			md5_colname	character varying;
			param1_		character varying;
			defparam1_	character varying;
			param2_		character varying;
			defparam2_	character varying;
			result_		character varying;
			con_name	character varying;
			ori_table	character varying;
			tab_col_na	character varying;
			col_rul_na	character varying;

	BEGIN

	con_name	:= cast(clock_timestamp() as character varying);
	ori_table	:= (schema_name || '"."' || table_name);
	tab_col_na	:= ( ori_table  ||  '_'  || md5(column_name ||  '_'  || checksum));
	col_rul_na	:= (column_name	||  '_'	 || rule_name	|| '_Result');
	md5_colname	:= (column_name ||  '_'  || md5(ori_table || '_' || column_name));

	Str_Vacio	:= '';

	IF fix_accion = Str_Vacio THEN
		RAISE EXCEPTION 'fix_accion cannot be void';
	END IF;

	accion_id_  := cast(fix_accion as integer);

	SELECT fa.func, fa.param1, fa.defparam1,fa.param2, fa.defparam2
		INTO function_, param1_, defparam1_, param2_, defparam2_
		FROM fi_accion fa
		WHERE fa."id" = accion_id_;

	param1_     := __get_param_gen__(param1_,defparam1_, '"' || (column_name) || '"', fix_param1);
	param2_     := __get_param_gen__(param2_,defparam2_, '"' || (column_name) || '"', fix_param2);

	result_		:= (function_) || '("' || (column_name) || '"' || param1_ || param2_ ||')';

	PERFORM dblink_connect(con_name, 'user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '');

	PERFORM		dblink_exec(con_name,	'CREATE INDEX IF NOT EXISTS "' ||
											(md5_colname) || '" ON "' ||
											(ori_table)   || '"("' ||
											(column_name) || '" COLLATE pg_catalog."en_US.utf8" text_pattern_ops);');

	PERFORM		dblink_exec(con_name,	'CREATE INDEX IF NOT EXISTS "' ||
											(md5_colname) || '_" ON "' ||
											(ori_table)   || '"("' ||
											(column_name) || '" COLLATE pg_catalog."en_US.utf8");');

	PERFORM		dblink_exec(con_name,	'CREATE TABLE IF NOT EXISTS "'|| tab_col_na ||'" AS
											SELECT DISTINCT "' ||
												(column_name)  || '" FROM "' ||
												(ori_table)    || '";');

	PERFORM		dblink_exec(con_name,	'DROP TABLE IF EXISTS tmp_table;');

	PERFORM		dblink_exec(con_name,	'CREATE TEMPORARY TABLE tmp_table AS
											SELECT DISTINCT "' ||
												(column_name)  || '", NULL AS "Result" FROM "' ||
												(ori_table)    || '";');

	PERFORM		dblink_exec(con_name,	'UPDATE tmp_table
											SET "Result" = '||
											(result_)		|| ' WHERE "'	||
											(column_name)	|| '" IS NOT NULL
											  AND "' 		|| (column_name) || '" != ''''
											  AND "' 		|| (column_name) || '" !~ '''|| regexp || ''';');

	PERFORM		dblink_exec(con_name,	'UPDATE tmp_table
											SET "Result"="'	||
											(column_name)	|| '" WHERE "'	||
											(column_name)	|| '" IS NULL
											  AND "' 		|| (column_name) || '" = ''''
											  AND "' 		|| (column_name) || '" ~ '''|| regexp || ''';');

	PERFORM		dblink_exec(con_name,	'DROP TABLE IF EXISTS tmp_table_back;');

	PERFORM		dblink_exec(con_name,	'CREATE TEMPORARY TABLE tmp_table_back AS TABLE "' || tab_col_na || '";');

	PERFORM		dblink_exec(con_name,	'DROP TABLE IF EXISTS "' || tab_col_na || '";');

	PERFORM		dblink_exec(con_name,	'CREATE TABLE "' || tab_col_na || '" AS
											SELECT t1.*, t2."Result" AS "'|| col_rul_na || '"
												FROM tmp_table_back AS t1
												LEFT JOIN tmp_table t2
													ON t1."' ||
													(column_name) || '" = t2."' ||
													(column_name) || '";');

	PERFORM dblink_disconnect(con_name);

	return query
		select 1;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
