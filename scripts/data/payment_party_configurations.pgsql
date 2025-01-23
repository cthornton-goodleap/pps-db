begin;

DO $$
	
DECLARE 
	utcNow timestamp := NOW() AT TIME ZONE 'UTC';
	rec RECORD;
	new_party_id INTEGER;
BEGIN
	--insert party/party identifiers
	FOR rec IN SELECT * FROM public.payment_party_configurations where "tenantId" IS NOT NULL LOOP
        INSERT INTO 
			party.parties (tenant_id, created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, type_id, organization_id) 
		VALUES 
			(rec."tenantId", 'MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, (select id from party.party_types where name = 'Organization' limit 1), rec."organizationId")
		RETURNING id INTO new_party_id;

		INSERT INTO 
			party.party_identifiers (tenant_id, created_by, updated_by, created_at, updated_at, is_deleted, is_test_data, party_id, type_id, identifier)
		VALUES
			(rec."tenantId", 'MIGRATION', 'MIGRATION', utcNow, utcNow, false, false, new_party_id, (select id from party.party_identifier_types where name = 'OrganizationId' limit 1), rec."organizationId");
    END LOOP;

	--insert accounts
	--Do we need type and type_id?
	INSERT INTO
		account.accounts (
			"type"
			, tenant_id
			, created_by
			, updated_by
			, created_at
			, updated_at
			, is_deleted
			, is_test_data
			, processor_identifier
			, onboarding_completed
			, apple_ttp_tos_accepted
			, type_id
			, status_id
			, party_id)
	SELECT
		'STRIPE_CONNECTED_ACCOUNT'
		, "tenantId"
		, 'MIGRATION'
		, 'MIGRATION'
		, utcNow
		, utcNow
		, false
		, false
		, "connectedAccountId"
		, "onboardingCompleted"
		, "appleTtpTosAccepted"
		, (select "id" from account.account_types where name = 'ConnectedAccount' limit 1)
		, (CASE "goodPayStatus"
			WHEN 'off' then (select "id" from account.account_status where name = 'Disabled' limit 1)
			WHEN 'esa' then (select "id" from account.account_status where name = 'Onboarding' limit 1)
			WHEN 'organization' then (select "id" from account.account_status where name = 'Active' limit 1)
			ELSE (select "id" from account.account_status where name = 'New' limit 1) 
		   END)
		, (select pp."id" from party.parties as pp 
			where pp."organization_id" = "organizationId"::text)
	FROM public.payment_party_configurations where "tenantId" IS NOT NULL;
END;
$$;

commit;