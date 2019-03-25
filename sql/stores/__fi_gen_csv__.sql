
CREATE OR REPLACE FUNCTION __fi_gen_csv__(
	IN db_name		character varying,
	IN schema_name	character varying,
	IN table_name	character varying,
	IN table_tmp	character varying
)
  RETURNS SETOF TEXT AS
$BODY$

	declare Str_Vacio	character varying;
			con_name	character varying;
			tex_query   TEXT;
			tbl_cursor	REFCURSOR;
			col_cursor	REFCURSOR;
			rec_colums	RECORD;
			sub_colums	RECORD;
			corpus		text;
			base_table	integer;
			iterable	integer;
			tbl_corpus	text;
			tbl_co_tmp	text;
			from_corpus text;
			bol_hascol	boolean;

	BEGIN

	Str_Vacio	:= '';
	con_name	:= cast(clock_timestamp() as character varying);
	corpus		:= '';
	tbl_corpus	:= '';
	tbl_co_tmp	:= '';
	iterable	:= 1;
	from_corpus := '';
	bol_hascol	:= false;

	PERFORM		dblink_connect(con_name, 'user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '');

	OPEN tbl_cursor FOR
		SELECT result.column_name, result.table_name
			FROM dblink(con_name,
					'SELECT column_name, table_name
						FROM information_schema.columns
						WHERE table_name	= ''' || table_name		|| '''
						  AND table_schema	= ''' || schema_name	|| ''' order by ordinal_position;') 
				AS result(column_name text, table_name text);

	base_table := iterable;
	LOOP
		FETCH tbl_cursor INTO rec_colums;
			EXIT WHEN NOT FOUND;

			iterable	:= iterable + 1;
			corpus		:= corpus   || 't' || base_table || '."' || rec_colums.column_name || '",';
			tbl_corpus	:= '"' || schema_name || '"."' || rec_colums.table_name || '" as t' || base_table;

			OPEN col_cursor FOR
				SELECT result.column_name, result.table_name
					FROM dblink(con_name,
							'SELECT distinct column_name, table_name
								FROM information_schema.columns
								WHERE table_name	like ''' || table_name	|| '\_%''
								  AND table_schema	=    ''' || schema_name	|| '''
								  AND column_name   <>   ''' || rec_colums.column_name || '''
								  AND column_name 	~ ''' || rec_colums.column_name || '\_[^\_][\w]+'';')
						AS result(column_name text, table_name text);

			LOOP
				FETCH col_cursor INTO sub_colums;
					EXIT WHEN NOT FOUND;

					bol_hascol 	:= true;
					tbl_co_tmp	:= sub_colums.table_name;
					IF sub_colums.column_name LIKE '%\_Result' THEN
							corpus		:= corpus   || 'CASE WHEN ' || 't' || iterable || '."'||
											sub_colums.column_name || '" IS NULL THEN t' || base_table || '."' ||
											rec_colums.column_name || '" ELSE t' || iterable || '."'|| sub_colums.column_name || '" END AS "' ||
											sub_colums.column_name || '",';
						ELSE
							corpus		:= corpus   || 't' || iterable || '."'|| sub_colums.column_name || '",';
					END IF;
			END	LOOP;
			CLOSE col_cursor;
			
			if bol_hascol = true then
				from_corpus :=	from_corpus || 'LEFT JOIN "' || schema_name || '"."' || tbl_co_tmp || '" as t' 
							|| iterable || ' ON t'  || base_table || '."' || rec_colums.column_name 
							||'" = t' || iterable || '."' || rec_colums.column_name ||'" ' ;
				bol_hascol	:= false;
			end if;
	END LOOP;
	close tbl_cursor;

	corpus := SUBSTR(corpus, 1, LENGTH(corpus) - 1);

	tex_query   :=  'COPY (SELECT '
					|| corpus		|| ' FROM '
					|| tbl_corpus	|| ' '
					|| from_corpus	|| ') TO STDOUT DELIMITER ''|'' CSV HEADER FORCE quote *;';

	PERFORM dblink_disconnect(con_name);

	return query
		SELECT tex_query;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
