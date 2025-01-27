begin;

DO $$
	
DECLARE utcNow timestamp := NOW() AT TIME ZONE 'UTC';

BEGIN
	insert into account.account_status(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'New') on conflict(name) do nothing;
	insert into account.account_status(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'Onboarding') on conflict(name) do nothing;
	insert into account.account_status(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'Active') on conflict(name) do nothing;
	insert into account.account_status(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'Disabled') on conflict(name) do nothing;
END;
$$;

commit;