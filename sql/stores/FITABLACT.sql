CREATE OR REPLACE FUNCTION FITABLACT(
	IN fix_usuari character varying,
	IN fix_tablex character varying)
	RETURNS setof JSON
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
	        user_id_    INTEGER;
			table_id_  INTEGER;
			StartTime   timestamptz;
			table_owner BOOLEAN;
		/* Declaracion de Variables */
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	StartTime   := clock_timestamp();
	user_id_    := CAST(fix_usuari AS INTEGER);
	table_id_   := CAST(fix_tablex AS INTEGER);

	IF fix_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'fix_usuari cannot be void';
	END IF;

	IF fix_tablex = Str_Vacio THEN
		RAISE EXCEPTION 'fix_tablex cannot be void';
	END IF;

	SELECT CASE WHEN count(*) = 1 THEN true
                ELSE false
           END INTO table_owner
        FROM permission_project pp
            INNER JOIN importation_table it 
                ON pp.id = it.project_id
        WHERE pp.user_id = user_id_
          AND it.id = table_id_;

    if table_owner = true then
        UPDATE  importation_table
           SET  clean_start  = StartTime,
                clean_end    = null,
                clean_status = 2
         WHERE id = table_id_;
    end if;

END; $BODY$ LANGUAGE plpgsql VOLATILE;