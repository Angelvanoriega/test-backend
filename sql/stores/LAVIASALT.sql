
CREATE OR REPLACE FUNCTION laviasalt(
	IN Lay_Usuari character varying,
	IN Lay_Projec character varying,
	IN Lay_Column character varying,
	IN Lay_Rulexx character varying)
	RETURNS setof json
AS $BODY$
	/* Declaracion de Constantes */
	declare	Str_Vacio	char(1); 
		Lay_File	int;
		Lay_Table	int;

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';

	IF Lay_Usuari = Str_Vacio THEN
		RAISE EXCEPTION 'Lay_Usuari cannot be void';
	END IF;

	IF Lay_Projec = Str_Vacio THEN
		RAISE EXCEPTION 'Lay_Projec cannot be void';
	END IF;

	IF Lay_Column = Str_Vacio THEN
		RAISE EXCEPTION 'Lay_Column cannot be void';
	END IF;

	IF Lay_Rulexx = Str_Vacio THEN
		RAISE EXCEPTION 'Lay_Rulexx cannot be void';
	END IF;

	Lay_Table = (SELECT DISTINCT table_id FROM importation_column WHERE id = CAST(Lay_Column AS INTEGER));
	Lay_File = (SELECT DISTINCT file_upload_id FROM importation_table WHERE id = CAST(Lay_Table AS INTEGER));

	INSERT INTO la_layout(column_id, rule_id, file_id, project_id, table_id, user_id) 
		VALUES (CAST(Lay_Column AS INTEGER), CAST(Lay_Rulexx AS INTEGER), Lay_File, 
				CAST(Lay_Projec AS INTEGER), Lay_Table, CAST(Lay_Usuari AS INTEGER));

	return query
		SELECT row_to_json(result)
				FROM (
					SELECT	'000000' as codigo, 
							'Registro Agregado' as mensaje	
					) as result;


END; $BODY$ LANGUAGE plpgsql VOLATILE;