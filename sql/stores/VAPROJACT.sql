CREATE OR REPLACE FUNCTION VAPROJACT(
	IN Val_Usuari character varying,
	IN Val_Projec character varying)
	RETURNS setof JSON
AS $BODY$
		/* Declaracion de Constantes */
	declare Str_Vacio	char(1);
	        user_id_    INTEGER;
			projec_id_  INTEGER;
			StartTime   timestamptz;
		/* Declaracion de Variables */
BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	StartTime   := clock_timestamp();
	user_id_    := CAST(Val_Usuari AS INTEGER);
	projec_id_  := CAST(Val_Projec AS INTEGER);

	IF Val_Usuari = Str_Vacio THEN
		RAISE EXCEPTION 'Val_Usuari cannot be void';
	END IF;

	IF Val_Projec = Str_Vacio THEN
		RAISE EXCEPTION 'Val_Projec cannot be void';
	END IF;

	UPDATE permission_project
       SET validation_start = StartTime, validation_end = null,
           validation_status = 2
     WHERE id = projec_id_ and user_id = user_id_;

END; $BODY$ LANGUAGE plpgsql VOLATILE;