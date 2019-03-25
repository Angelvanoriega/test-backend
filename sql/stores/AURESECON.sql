CREATE OR REPLACE FUNCTION AURESECON(
	IN tip_consul character varying,
	IN aut_tokenx character varying
	)
	RETURNS SETOF JSON
AS $BODY$
	declare Str_Vacio	char(1);
			token_date_ timestamp;
			Tip_ConTip	char(1);
			Tip_ConCon	char(1);
		/* Declaracion de Variables */
			Tip_Consut	char(1);
			Con_ValTok	char(1);
			is_active_  boolean;
			not_used_   boolean;
			is_valid_   boolean;
			token_      boolean;

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	token_date_	:= (SELECT to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'));
    is_active_  := TRUE;
    not_used_   := FALSE;
    is_valid_   := TRUE;

    Tip_ConTip := substring(Tip_Consul, 1, 1);
	Tip_ConCon := substring(Tip_Consul, 2, 1);

	Tip_Consut	:= 'C';
	Con_ValTok	:= '1';

	IF aut_tokenx = Str_Vacio THEN
		RAISE EXCEPTION 'aut_tokenx: cannot be void';
	END IF;

	IF Tip_ConTip = Tip_Consut THEN /* 'L' Listas */
		IF Tip_ConCon = Con_ValTok THEN
            SELECT case when COUNT(*) = 0 then
                        FALSE
                   else TRUE
                   END AS _token
                INTO token_
                FROM au_password ap
                WHERE ap."token" = aut_tokenx
                  AND ap.token_active = is_active_
                  AND ap.token_used = not_used_
                  -- token menor a 24hrs de haberse generado.
                  AND   (DATE_PART('second', CURRENT_TIMESTAMP - ap.token_date) +
                        (DATE_PART('day', CURRENT_TIMESTAMP - ap.token_date) * 86400) +
                        (DATE_PART('minute', CURRENT_TIMESTAMP - ap.token_date) * 60) +
                        (DATE_PART('hour', CURRENT_TIMESTAMP - ap.token_date)* 3600)) <= 86400;

            IF token_ = is_valid_ THEN
                RETURN QUERY
                    SELECT row_to_json(result)
                            FROM (
                                SELECT	'SUCCESS' as type,
                                        'token ''' || aut_tokenx || ''' is valid.' as message
                                ) as result;
            ELSE
                RETURN QUERY
                    SELECT row_to_json(result)
                            FROM (
                                SELECT	'ERROR' as type,
                                        'token ''' || aut_tokenx || ''' is not valid.' as message
                                ) as result;
            END IF;
		END IF;
	END IF;

END; $BODY$ LANGUAGE plpgsql VOLATILE;