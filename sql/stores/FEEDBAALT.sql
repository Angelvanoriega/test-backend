CREATE OR REPLACE FUNCTION FEEDBAALT(
	IN fee_usuari character varying,
	IN fee_module character varying,
	IN fee_subjec character varying,
	IN fee_descri character varying,
	IN fee_satisf character varying
	)
	RETURNS SETOF JSON
AS $BODY$
	declare Str_Vacio	char(1);
			user_id_    integer;
			module_id_  integer;
			date_now_   timestamp;
			satisfied_  boolean;

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';

	IF fee_usuari = Str_Vacio THEN
		RAISE EXCEPTION 'fee_usuari: cannot be void';
	END IF;

	IF fee_module = Str_Vacio THEN
		RAISE EXCEPTION 'fee_module: cannot be void';
	END IF;

	IF fee_subjec = Str_Vacio THEN
		RAISE EXCEPTION 'fee_subjec: cannot be void';
	END IF;

	IF fee_descri = Str_Vacio THEN
		RAISE EXCEPTION 'fee_descri: cannot be void';
	END IF;

	IF fee_satisf = Str_Vacio THEN
		RAISE EXCEPTION 'fee_satisf: cannot be void';
	END IF;

	date_now_   := (SELECT to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'));
	user_id_    := cast(fee_usuari as integer);
	module_id_  := cast(fee_module as integer);
	satisfied_  := cast(fee_satisf as boolean);


	INSERT INTO fe_feedback(date, subject, description, satisfied, module_id, user_id)
        VALUES (date_now_,fee_subjec,fee_descri,satisfied_,module_id_,user_id_);

    RETURN QUERY
        SELECT row_to_json(result)
                FROM (
                    SELECT	'SUCCESS' as type,
                            'FEMSG0001' as message_id
                    ) as result;

END; $BODY$ LANGUAGE plpgsql VOLATILE;