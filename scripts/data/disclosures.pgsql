begin;

DO $$
	
DECLARE 
	utcNow timestamp := NOW() AT TIME ZONE 'UTC';
    DECLARE tenantId text := ''; --CHECK TO MAKE SURE THIS IS WHAT WE WANT
BEGIN
	--if an orgId is null
    --it is for everyone, and is_default = true
    --if it is not null, then an entry into required disclosure
	INSERT INTO disclosure.disclosures (
		tenant_id
		, created_by
		, updated_by
		, created_at
		, updated_at
		, is_deleted
		, is_test_data
        , "name"
		, "location"
        , "version"
		, is_default)
	SELECT DISTINCT ON ("location")
		COALESCE((select "tenantId" from public.payment_party_configurations where "organizationId" = "organizationId" limit 1)::text, tenantId)
		, 'MIGRATION'
		, 'MIGRATION'
		, utcNow
		, utcNow
		, false
		, false
        , "location" --unsure, represents 'name' column
        , "location"
        , '1' --defaulting a value here
        , (CASE "organizationId"
			WHEN NULL then true
			ELSE false
		   END)
	FROM public.disclosures;
    
    --required disclosure inserts
    INSERT INTO disclosure.required_disclosures (
		tenant_id
		, created_by
		, updated_by
		, created_at
		, updated_at
		, is_deleted
		, is_test_data
        , party_id
		, "disclosure_id")
	SELECT DISTINCT ON ("location")
		(select "tenantId" from public.payment_party_configurations where "organizationId" = "organizationId" limit 1)
		, 'MIGRATION'
		, 'MIGRATION'
		, utcNow
		, utcNow
		, false
		, false
        , (select pp."id" from party.parties as pp 
			where pp."organization_id" = "organizationId"::text)
        , (select "id" from disclosure.disclosures where disclosure.disclosures."location" = public.disclosures."location" limit 1)
	FROM public.disclosures
    WHERE "organizationId" IS NOT NULL
	AND "organizationId"::text IN(select "organization_id" from party.parties);

	-- - insert rows from public.organization_disclosures (into disclosure.disclosure_acceptances)
	INSERT INTO disclosure.disclosure_acceptances (
		tenant_id
		, created_by
		, updated_by
		, created_at
		, updated_at
		, is_deleted
		, is_test_data
        , party_id
		, accepted_by
		, "disclosure_id"
		, accepted_at)
	SELECT
		(select "tenantId" from public.payment_party_configurations where "organizationId" = "organizationId" limit 1)
		, 'MIGRATION'
		, 'MIGRATION'
		, utcNow
		, utcNow
		, false
		, false
        , (select pp."id" from party.parties as pp 
			where pp."organization_id" = "organizationId"::text)
		, "acceptedBy"
        , (select disc."id" from disclosure.disclosures as disc
			inner join public.disclosures as pubDisc
			on disc."location" = pubDisc."location"
			where pubDisc."id" = "disclosureId")
		, "acceptedAt"
	FROM public.organization_disclosures
	where "organizationId"::text IN(select organization_id from party.parties);

    -- - insert rows from public.organization_disclosures (into disclosure.disclosure_acceptances)
    --     - can use orgId to look up party_id
    --     - getting disclosure_id a little more involved
    --         - use public.organization_disclosure.disclosureId to join on public.disclosure.id
    --             - use location from there
    --             - using location, join on disclosure.disclosures.location
    --                 - use disclosure.disclosures.id from that match
END;
$$;

commit;