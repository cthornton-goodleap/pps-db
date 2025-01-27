begin;

DO $$
	
DECLARE utcNow timestamp := NOW() AT TIME ZONE 'UTC';

BEGIN
	insert into account.account_types(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'ConnectedAccount') on conflict(name) do nothing;
	insert into account.account_types(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'FinancialAccount') on conflict(name) do nothing;
	insert into account.account_types(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'PlatformAccount') on conflict(name) do nothing;
	insert into account.account_types(created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values('MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'ExternalAccount') on conflict(name) do nothing;
END;
$$;

commit;