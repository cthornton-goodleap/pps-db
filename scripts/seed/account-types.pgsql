begin;

DO $$
	
DECLARE utcNow timestamp := NOW() AT TIME ZONE 'UTC';
DECLARE tenantId text := ''; --CHECK TO MAKE SURE THIS IS WHAT WE WANT

BEGIN
	insert into account.account_types(tenant_id, created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values(tenantId, 'MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'ConnectedAccount') on conflict(name) do nothing;
	insert into account.account_types(tenant_id, created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values(tenantId, 'MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'FinancialAccount') on conflict(name) do nothing;
	insert into account.account_types(tenant_id, created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values(tenantId, 'MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'PlatformAccount') on conflict(name) do nothing;
	insert into account.account_types(tenant_id, created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, name) values(tenantId, 'MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, 'ExternalAccount') on conflict(name) do nothing;
END;
$$;

commit;