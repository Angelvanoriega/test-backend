CREATE OR REPLACE FUNCTION IMFILEBAJ(
	IN imp_usuari character varying,
	IN imp_projec character varying,
	IN imp_filexx character varying)
	RETURNS SETOF JSON
AS $BODY$
	/* Declaracion de Constantes */
	declare	Str_Vacio	char(1);
			user_id_	integer;
			project_id_	integer;
			file_id_    integer;

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';

	IF imp_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'imp_usuari cannot be void';
	END IF;

	IF imp_projec = Str_Vacio THEN
		RAISE EXCEPTION 'imp_projec cannot be void';
	END IF;

	IF imp_filexx = Str_Vacio THEN
		RAISE EXCEPTION 'imp_filexx cannot be void';
	END IF;

	user_id_    := CAST(imp_usuari AS INTEGER);
	project_id_ := (SELECT id FROM permission_project pp
						WHERE pp.folio = imp_projec
						  and pp.user_id = user_id_);
	file_id_    := (SELECT id FROM importation_file if
	                    WHERE if.name = imp_filexx
	                      and if.project_id = project_id_);

	DELETE FROM importation_file
		WHERE project_id = project_id_
		  AND id = file_id_;

	return query
		SELECT row_to_json(result)
				FROM (
					SELECT	user_id_ as user_id,
							project_id_ as project_id,
							file_id_ as file_id
					) as result;


END; $BODY$ LANGUAGE plpgsql VOLATILE;