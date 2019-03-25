CREATE OR REPLACE FUNCTION crear_usuarios()
  RETURNS trigger AS
$BODY$
	DECLARE
		user_id integer := NEW.id;
		usuario CHARACTER VARYING := quote_ident(lower(NEW.username));
		contra CHARACTER VARYING := quote_literal(NEW.password);
		db_name CHARACTER VARYING := quote_ident('db_' || lower(NEW.username));
	BEGIN
		EXECUTE 'CREATE USER '|| usuario ||' WITH password '|| contra ||' INHERIT';
        --EXECUTE 'createdb -h localhost -p 5432 -e '|| db_name;
		IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN

			PERFORM dblink_exec('user=dataclean password=da8T_mEjUPr8 dbname=' || current_database() ,
			                    ' CREATE DATABASE ' || db_name);
            INSERT INTO public.pa_package_users(package_id, user_id)
                select 1, user_id;
			EXECUTE 'GRANT ALL PRIVILEGES ON DATABASE '|| db_name ||' TO '||usuario;
			EXECUTE 'GRANT ALL PRIVILEGES ON DATABASE '|| db_name ||' TO dataclean';
		EXECUTE 'GRANT '||usuario||' TO dataclean';
		END IF;
		RETURN NEW;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER crear_usuarios ON auth_user;

CREATE TRIGGER crear_usuarios
  AFTER INSERT
  ON auth_user
  FOR EACH ROW
  EXECUTE PROCEDURE crear_usuarios();