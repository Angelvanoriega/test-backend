CREATE OR REPLACE FUNCTION AUFORGALT(
	IN aut_emailx character varying,
	IN aut_checks character varying
	)
	RETURNS SETOF JSON
AS $BODY$
	declare Str_Vacio	char(1);
			token_date_ timestamp;
			user_id_    integer;
			old_pwd_    character varying;

BEGIN
	/* Asignacion de Constantes */
	Str_Vacio	:= '';
	token_date_ := (SELECT to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'));

	IF aut_emailx = Str_Vacio THEN
		RAISE EXCEPTION 'aut_emailx cannot be void';
	END IF;

	IF aut_checks = Str_Vacio THEN
		IF length(aut_checks) != 32 THEN
			RAISE EXCEPTION 'aut_checks: The size of the string must be 32 characters';
		END IF;
		RAISE EXCEPTION 'aut_checks: cannot be void';
	END IF;

	SELECT id, password
	    INTO user_id_, old_pwd_
	    FROM auth_user
	    WHERE email = aut_emailx;

	IF user_id_ is not null and user_id_ > 0 THEN

		UPDATE au_password
			SET token_active = FALSE
			WHERE user_id = user_id_;

		INSERT INTO au_password(token, token_date,
								token_used, password_new, user_id,
								email, token_active, password_old)
			VALUES (aut_checks, token_date_, FALSE, '',user_id_,
					aut_emailx, TRUE, old_pwd_);

		RETURN QUERY
			SELECT row_to_json(result)
					FROM (
						SELECT	'SUCCESS' as type,
								'Email has been sent to ' || aut_emailx || '' as message
						) as result;
	ELSE
		RETURN QUERY
		SELECT row_to_json(result)
				FROM (
					SELECT	'ERROR' as type,
							'Email does not correspond to any user' as message
					) as result;
	END IF;

END; $BODY$ LANGUAGE plpgsql VOLATILE;