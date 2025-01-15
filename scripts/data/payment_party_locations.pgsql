begin;

DO $$
	
DECLARE 
	utcNow timestamp := NOW() AT TIME ZONE 'UTC';
BEGIN
	--insert stripe_connected_account_locations
	--from payment_party_locations
	INSERT INTO account.stripe_connected_account_locations (
		tenant_id
		, created_by
		, updated_by
		, created_at
		, updated_at
		, is_deleted
		, is_test_data
		, location_id
		, account_id)
	SELECT
		(select "tenantId" from public.payment_party_configurations where "paymentPartyConfigurationId" = "id" limit 1)
		, 'MIGRATION'
		, 'MIGRATION'
		, utcNow
		, utcNow
		, false
		, false
		, "locationId"
		, (
			select a."id" from account.accounts as a
			inner join party.parties as p
			on a."party_id" = p."id"
			inner join public.payment_party_configurations as ppc
			on ppc."organizationId"::text = p."organization_id"
			where "paymentPartyConfigurationId" = ppc."id"
		)  FROM public.payment_party_locations as ppl 
		inner join public.payment_party_configurations as parentPPC
		on ppl."paymentPartyConfigurationId" = parentPPC."id"
		where parentPPC."tenantId" IS NOT NULL;
END;
$$;

commit;