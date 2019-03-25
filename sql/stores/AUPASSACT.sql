CREATE OR REPLACE FUNCTION AUPASSACT(
	IN aut_tokenx character varying,
	IN aut_newpwd character varying
	)
	RETURNS SETOF JSON
AS $BODY$
	declare Str_Vacio	char(1);
			token_date_ timestamp;
			user_id_    integer;
			old_pwd_    character varying;
			exist_pwd   boolean;
			yes_exist   boolean;
			is_active_  boolean;
			not_used_   boolean;
			is_valid_   boolean;
			token_      boolean;

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	token_date_ := (SELECT to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'));
	yes_exist   := TRUE;
	is_active_  := TRUE;
    not_used_   := FALSE;
    is_valid_   := TRUE;

	IF aut_newpwd = Str_Vacio THEN
		RAISE EXCEPTION 'aut_newpwd cannot be void';
	END IF;

	IF aut_tokenx = Str_Vacio THEN
		IF length(aut_tokenx) != 32 THEN
			RAISE EXCEPTION 'aut_tokenx: The size of the string must be 32 characters';
		END IF;
		RAISE EXCEPTION 'aut_tokenx: cannot be void';
	END IF;

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

    IF token_ != is_valid_ THEN
        RETURN QUERY
            SELECT row_to_json(result)
                FROM (
                    SELECT	'ERROR' as type,
                            'AUMSG0003' as message_id
                    ) as result;
    END IF;

	SELECT user_id
		INTO user_id_
		FROM au_password
		WHERE token = aut_tokenx;

	SELECT case when count(*) = 0 then
			FALSE
			ELSE TRUE END AS exist
		into exist_pwd
	FROM au_password
	where user_id = user_id_
	  and password_old = aut_newpwd;

	/*IF exist_pwd = yes_exist THEN
		RETURN QUERY
			SELECT row_to_json(result)
					FROM (
						SELECT	'ERROR' as type,
								--'Password previously used' as message_id
								'AUMSG0001' as message_id
						) as result;
	END IF;*/

	IF user_id_ is not null and user_id_ > 0 THEN

		UPDATE au_password
		    SET password_new = aut_newpwd,
		        token_active = FALSE,
		        token_used = TRUE
			WHERE token = aut_tokenx
			  AND user_id = user_id_;

		UPDATE auth_user
		    SET password = aut_newpwd
			WHERE id = user_id_;

		RETURN QUERY
			SELECT row_to_json(result)
					FROM (
						SELECT	'SUCCESS' as type,
								'AUMSG0002' as message_id
						) as result;
	ELSE
		RETURN QUERY
		SELECT row_to_json(result)
				FROM (
					SELECT	'ERROR' as type,
							'AUMSG0003' as message_id
					) as result;
	END IF;

END; $BODY$ LANGUAGE plpgsql VOLATILE;