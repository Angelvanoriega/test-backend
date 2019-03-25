CREATE OR REPLACE FUNCTION AUUSERALT(
  IN aut_userna CHARACTER VARYING,
  IN aut_passwo CHARACTER VARYING,
  IN aut_emailx CHARACTER VARYING,
  IN aut_firstn CHARACTER VARYING,
  IN aut_lastna CHARACTER VARYING,
  IN aut_phonex CHARACTER VARYING,
  IN aut_countr CHARACTER VARYING
)
  RETURNS SETOF JSON
AS $BODY$
DECLARE Str_Vacio   CHAR(1);
        date_join_  TIMESTAMP;
        is_staff_   BOOLEAN;
        is_super_   BOOLEAN;
        is_active_  BOOLEAN;
        user_id_    INTEGER;
        db_name_    CHARACTER VARYING;
BEGIN
  /* Asignacion de Constantes */
    Str_Vacio   := '';
    date_join_  := (SELECT to_char(current_timestamp, 'YYYY-MM-DD HH24:MI:SS'));
    is_staff_   := FALSE;
    is_super_   := FALSE;
    is_active_  := TRUE;

  IF aut_userna = Str_Vacio THEN
    RAISE EXCEPTION 'aut_userna: cannot be void';
  END IF;

  IF aut_passwo = Str_Vacio THEN
    RAISE EXCEPTION 'aut_passwo: cannot be void';
  END IF;

  IF aut_emailx = Str_Vacio THEN
    RAISE EXCEPTION 'aut_emailx: cannot be void';
  END IF;

  IF aut_firstn = Str_Vacio THEN
    RAISE EXCEPTION 'aut_firstn: cannot be void';
  END IF;

  IF aut_lastna = Str_Vacio THEN
    RAISE EXCEPTION 'aut_lastna: cannot be void';
  END IF;

  IF aut_phonex = Str_Vacio THEN
    RAISE EXCEPTION 'aut_phonex: cannot be void';
  END IF;

  IF aut_countr = Str_Vacio THEN
    RAISE EXCEPTION 'aut_countr: cannot be void';
  END IF;

  INSERT INTO auth_user(
            username, password, email, first_name, last_name,
            is_staff, is_superuser, is_active, date_joined)
    VALUES (aut_userna, aut_passwo,aut_emailx,aut_firstn, aut_lastna,
            is_staff_, is_super_, is_active_, date_join_)
    returning id into user_id_;

  db_name_    := (SELECT 'db_' || aut_userna);

  INSERT INTO permission_userprofile(
              telefono, user_id, db_name, country)
    VALUES (aut_phonex, user_id_, db_name_, aut_countr);

  RETURN QUERY
      SELECT row_to_json(result)
        FROM (
               SELECT
                 'SUCCESS'   AS type,
                 'AUMSG0001' AS message_id
                 --'User registered correctly' AS message
             ) AS result;

END; $BODY$ LANGUAGE plpgsql VOLATILE;