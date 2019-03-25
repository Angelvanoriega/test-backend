CREATE OR REPLACE FUNCTION update_userprofile()
  RETURNS trigger AS
$BODY$
	DECLARE
		user_id_ integer := NEW.user_id;
		db_name_ character varying := quote_ident('db_' || lower((select username from auth_user where id = user_id_)));
	BEGIN
		-- Creamos usuario con su misma credencial de logueo.
        --UPDATE  permission_userprofile
        --      SET db_name = db_name_
        --    WHERE user_id = user_id_;
		RETURN NEW;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER IF EXISTS update_userprofile ON permission_userprofile;

CREATE TRIGGER update_userprofile
  AFTER INSERT
  ON permission_userprofile
  FOR EACH ROW
  EXECUTE PROCEDURE update_userprofile();