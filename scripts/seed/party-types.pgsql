begin;

DO $$
	
DECLARE utcNow timestamp := NOW() AT TIME ZONE 'UTC';

BEGIN
	insert into 
		party.party_types(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) 
		values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'Organization') 
		on conflict(name) do nothing;
END;
$$;

commit;