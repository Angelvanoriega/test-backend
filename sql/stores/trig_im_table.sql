CREATE OR REPLACE FUNCTION trig_im_table()
  RETURNS trigger AS
$BODY$
	DECLARE
		table_id INTEGER := NEW.id;
		table_name CHARACTER VARYING := NEW.name;
		schema_name CHARACTER VARYING :=
			(SELECT pp.folio FROM permission_project pp
				WHERE pp.id = NEW.project_id);
		db_name CHARACTER VARYING :=
			(SELECT pu.db_name FROM permission_project pp
				inner join permission_userprofile pu
					on pu.user_id = pp.user_id
				WHERE pp.id = NEW.project_id);
	BEGIN
		UPDATE importation_table
			SET total_rows = (SELECT totals
				FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
						'SELECT COUNT(*) FROM "' ||
								(schema_name) || '"."' ||
								(table_name)  ||'";') AS t1(totals INTEGER))
				WHERE importation_table.id = table_id;
		INSERT INTO importation_column(table_id, name)
		    SELECT table_id, name
				FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname='|| db_name || '',
						'SELECT column_name
                            FROM information_schema.columns
                            where table_schema = '''|| (schema_name) ||'''
	                          and table_name = '''|| (table_name)  ||''';') AS t1(name CHARACTER VARYING);
		RETURN NEW;
	END;
	$BODY$
  LANGUAGE plpgsql VOLATILE;

DROP TRIGGER trig_im_table ON importation_table;

CREATE TRIGGER trig_im_table
  AFTER INSERT
  ON importation_table
  FOR EACH ROW
  EXECUTE PROCEDURE trig_im_table();

-- UPDATE importation_table
-- 	SET total_rows = (SELECT totals
-- 	-- FROM dblink('user=dataclean password=da8T_mEjUPr8 dbname=db_'|| au.username || '',
-- 		 'SELECT COUNT(*) FROM "' ||
-- 			-- (pp.folio) || '"."' ||
-- 			(it.name)  ||'";') AS t1(totals INTEGER))
-- 	from importation_table as it
-- 		inner join permission_project as pp
-- 			on pp.id = it.project_id
-- 		inner join auth_user as au
-- 			on au.id = pp.user_id
-- 	where importation_table.id = it.id