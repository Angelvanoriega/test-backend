
CREATE OR REPLACE FUNCTION get_param(
	IN param_bd character varying,
	IN default_bd character varying,
	IN value_user character varying,
	IN param_usr character varying
)
  RETURNS setof text AS
$BODY$
	declare Str_Vacio	character varying;
			param_bd_	character varying;
			param_usr_	character varying;
			value_user_ character varying;
			default_bd_ character varying;

	BEGIN

	param_bd_   := replace(param_bd,   '''', '');
	param_usr_  := replace(param_usr,  '''', '');
	value_user_ := replace(value_user, '''', '');
	default_bd_ := replace(default_bd, '''', '');

		return query
			SELECT
				CASE
					WHEN param_bd_ = 'self' THEN (',''' || value_user_ || '''')
					WHEN param_bd_ = '' THEN ''
					WHEN param_bd_ = 'default' THEN (',' || (CASE
																WHEN default_bd_ = 'void' THEN ''''''
																ELSE default_bd_
															 END))
					WHEN param_bd_ = 'int' THEN (',' || param_usr_)
					WHEN param_bd_ = 'string' THEN (',''' || param_usr_ || '''')
					ELSE (',' || param_usr_)
				END;

END; $BODY$ LANGUAGE plpgsql VOLATILE;
