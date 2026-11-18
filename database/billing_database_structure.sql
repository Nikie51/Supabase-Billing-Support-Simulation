-- =====================================================================
/*
Supabase Billing Support Simulation [SIM]
Database Schema
PostgreSQL 18

[SIM] This schema defines the tables and relationships used in this practice database to investigate billing and customer support cases.

The database uses fictional organisations, users, projects, subscriptions, usage records, invoices and payment information.

[DOC] The scenarios are informed by publicly documented Supabase billing concepts, product behaviour and pricing rules.

[UNKNOWN] Behaviour or policy that cannot be confirmed from publicly available Supabase documentation and requires internal verification.

[SIM] This project does not reproduce Supabase's private production database or internal billing infrastructure.

Billing calculations are investigated through SQL queries rather than enforced through database constraints.
This allows me to identify and investigate discrepancies between related records.
 */

-- =====================================================================

-- DROP SCHEMA IF EXISTS billing_sim CASCADE; --CASCADE also deletes objects inside that schema and dependent objects.

CREATE SCHEMA billing_sim;
SET search_path = billing_sim, public; -- Tells PostgreSQL where to look first when the SQL refers to an object without specifying its schema. It checks billing_sim first, then public.

-- ---------------------------------------------------------------------
-- USERS AND ORGANISATIONS
-- ---------------------------------------------------------------------

/* [SIM] Stores individual users who may submit support tickets or belong to one or more organisations.*/

CREATE TABLE users (
  user_id       text        PRIMARY KEY,
  email         text        NOT NULL UNIQUE,
  full_name     text        NOT NULL,
  country_code  char(2)     NOT NULL,
  created_at    timestamptz NOT NULL
);

/* [SIM] Stores the organisations used in the billing scenarios.
[DOC] On the Supabase Platform, an organisation is the billing unit.
Each organisation has its own subscription, billing cycle, payment methods, billing details and invoices.
[SIM] billing_anchor_day records the day used to determine the organisation's monthly billing cycle.
*/

CREATE TABLE organizations (
  org_id              text        PRIMARY KEY,
  name                text        NOT NULL,
  created_at          timestamptz NOT NULL,
  billing_anchor_day  smallint    NOT NULL CHECK (billing_anchor_day BETWEEN 1 AND 31),
  deleted_at          timestamptz 		-- That gives us a way to distinguish an organisation with no recorded deletion from one with a deletion timestamp. It does not physically remove the organisation.
);

/*  [SIM] Records the relationship between users and organisations, including the user's role and membership dates.
[DOC] Supabase uses roles such as Owner, Administrator, Developer and Read-Only. No-access is available on the Team and Enterprise plans. It is not available on Free or Pro.
[SIM] This database stores selected roles using shorter values. The value 'admin' represents the Administrator role.
[DOC] The Free Plan project limit considers organisations where a user is an Owner or Administrator.*/

CREATE TABLE org_members (
  org_id      text        NOT NULL REFERENCES organizations(org_id), 	-- This means you cannot add an organisation membership pointing to an organisation that does not exist in organizations.
  user_id     text        NOT NULL REFERENCES users(user_id),			-- Same as org_id
  role        text        NOT NULL CHECK (role IN ('owner','admin','developer','read_only')),
  added_at    timestamptz NOT NULL,
  removed_at  timestamptz, 		-- When the person was removed. NULL means no removal date is recorded.
  PRIMARY KEY (org_id, user_id),
  CHECK (removed_at IS NULL OR removed_at > added_at)	-- removed_at to be NULL, meaning there is no recorded removal date or the removal date to be later than the date the person was added.
);


 /* Historical billing details.
 [SIM] Stores dated versions of an organisation's billing details.
This allows us to identify which billing details were recorded at a particular point in time.
[DOC] Changes to billing email, billing address and tax ID apply to upcoming invoices. Previously issued invoices cannot be regenerated through the documented billing process. */

CREATE TABLE billing_details_history (
  detail_id       bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  org_id          text        NOT NULL REFERENCES organizations(org_id),
  billing_email   text        NOT NULL,
  company_name    text,
  address_line    text,
  city            text,
  postal_code     text,
  address_country char(2),
  tax_id_type     text,        -- Identifies the type of tax registration number entered. e.g. 'eu_vat', 'gb_vat' (NULL if none entered)
  tax_id          text,        -- Stores the actual tax identification number.
  valid_from      timestamptz NOT NULL,		-- When this version of the billing details became valid.
  valid_to        timestamptz,  	-- When this version stopped being valid. NULL represents the current version.
  CHECK (valid_to IS NULL OR valid_to > valid_from) --This prevents a version from ending before it starts.
);

-- ---------------------------------------------------------------------
-- SUBSCRIPTIONS AND BILLING CYCLES
-- ---------------------------------------------------------------------

/* [SIM] Stores dated subscription periods for each organisation.
[DOC] A Supabase organisation has one subscription and one plan at a time.
[SIM] Historical records allow us to investigate which plan and Spend Cap setting applied during a particular period.
[DOC] Spend Cap is available on the Pro Plan. */

CREATE TABLE subscriptions (
  subscription_id    text        PRIMARY KEY,
  org_id             text        NOT NULL REFERENCES organizations(org_id),
  plan               text        NOT NULL CHECK (plan IN ('free','pro','team','enterprise')),
  spend_cap_enabled  boolean,		-- Stores whether Spend Cap is enabled. It uses a Boolean value: TRUE or FALSE.
  started_at         timestamptz NOT NULL,
  ended_at           timestamptz,
  CHECK (ended_at IS NULL OR ended_at > started_at), 	-- If an end date exists, it must be later than the start date.
  CHECK ((plan = 'pro') = (spend_cap_enabled IS NOT NULL)) 	-- Ensures spend_cap_enabled is populated only when the plan is Pro.
);

/* [SIM] Stores the billing periods used in our practice scenarios.
[DOC] An organisation's billing cycle is anchored to its creation date, and an invoice is issued at the monthly reset.
[DOC] Fixed fees are charged in advance, while usage-based fees are charged in arrears.
A plan change can also trigger billing for usage accumulated up to that point.

[SIM] ended_reason records why a billing cycle ended.
A Spend Cap setting change does not end a billing cycle.
A plan change can end a cycle before its scheduled reset. cycle_end is exclusive in this simulation.

[SIM] subscription_id identifies the subscription period associated with the beginning of each billing cycle. */

CREATE TABLE billing_cycles (
  cycle_id         text        PRIMARY KEY,
  org_id           text        NOT NULL REFERENCES organizations(org_id),
  subscription_id  text        NOT NULL REFERENCES subscriptions(subscription_id),
  cycle_start      timestamptz NOT NULL,
  cycle_end        timestamptz NOT NULL,
  ended_reason     text        CHECK (ended_reason IN ('scheduled_reset','plan_change')),
  CHECK (cycle_end > cycle_start)
);

-- ---------------------------------------------------------------------
-- PROJECTS
-- ---------------------------------------------------------------------

/* [SIM] Stores the projects associated with each organisation.
[DOC] Each Supabase project has a dedicated Postgres instance and platform services. Projects belong to an organisation and benefit from that organisation's subscription plan.

[DOC] Compute usage is billed according to the project's
Compute size and running time.
Paused projects do not incur Compute charges.
Only Free Plan projects can currently be paused.
[SIM] status records whether a project is active, paused or deleted. project_ref represents the project's reference identifier. */

CREATE TABLE projects (
  project_ref  char(20)    PRIMARY KEY,
  org_id       text        NOT NULL REFERENCES organizations(org_id),
  name         text        NOT NULL,
  region       text        NOT NULL,
  status       text        NOT NULL CHECK (status IN ('active','paused','deleted')),
  created_at   timestamptz NOT NULL,
  paused_at    timestamptz,
  deleted_at   timestamptz
);

-- ---------------------------------------------------------------------
-- USAGE ITEMS AND PRICING REFERENCE
-- ---------------------------------------------------------------------

/*
[SIM] Stores billable usage items, their pricing and included quotas.

[DOC] Supabase billing distinguishes usage within a plan quota, overage beyond that quota, and items billed on full usage.

[SIM] billing_basis classifies these billing approaches:
- quota_overage: Only usage above the included quota is billable.
- hourly_full_usage: Our label for items billed on full hourly usage.

[SIM] spend_cap_covered records whether an item is eligible for Pro Plan Spend Cap protection, based on Supabase's documented coverage rules.
The organisation's Spend Cap setting is stored separately in subscriptions.spend_cap_enabled.

[SIM] plan_fees stores base monthly subscription fees. Enterprise pricing is custom [DOC].

[DOC] Usage quota scope varies by item: some are organisation-wide, while others apply per project.
*/

CREATE TABLE usage_items (
  usage_item         text    PRIMARY KEY,
  display_name       text    NOT NULL,
  unit               text    NOT NULL,  -- such as GB or hours
  billing_basis      text    NOT NULL CHECK (billing_basis IN ('quota_overage','hourly_full_usage')),
  spend_cap_covered  boolean NOT NULL,
  docs_url           text    NOT NULL
);

-- Fixed monthly plan fee. NULL for Enterprise (custom).
CREATE TABLE plan_fees (
  plan         text          PRIMARY KEY CHECK (plan IN ('free','pro','team','enterprise')),
  monthly_fee  numeric(10,2),
  source_url   text          NOT NULL
);

/* [SIM] Stores the included quota and unit price for each billable item under the applicable plan and configuration.
Some items have variants, such as Compute size (Micro, Small, Medium, Large) or Point-in-Time Recovery (PITR) retention period (e.g. 7 or 14 days).
The variant (a particular version or configuration of an item) is blank when an item has no separate configuration.
'all_paid' is a simulation label for prices shared by Pro and Team. */

CREATE TABLE usage_item_prices (
  usage_item         text           NOT NULL REFERENCES usage_items(usage_item),
  variant            text           NOT NULL DEFAULT '', 	-- Distinguishes different versions, such as compute sizes or PITR (Point In Time Recovery) retention periods
  plan               text           NOT NULL CHECK (plan IN ('free','pro','team','enterprise','all_paid')),
  included_quantity  numeric(18,4)  NOT NULL DEFAULT 0, 	--Quantity included before additional charges, deafulting to zero.
  unit_price         numeric(12,6),
  source_url         text           NOT NULL,
  PRIMARY KEY (usage_item, variant, plan)
);

-- ---------------------------------------------------------------------
-- ADD-ON CONFIGURATION AND USAGE
-- ---------------------------------------------------------------------

/*
[SIM] Records the history of add-ons and Compute configurations assigned to each project, including when each configuration starts and ends.

addon_type references an item in usage_items, such as compute, ipv4, custom_domain or pitr.

variant identifies the configuration where applicable, such as Compute size or PITR retention period. It is blank when no variant applies.

[SIM] Usage can be investigated against these configuration periods, but the database does not automatically calculate usage from them.

Compute size changes are represented by closing the previous period and opening a new one.
*/

CREATE TABLE project_addons (
  addon_id     bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_ref  char(20)    NOT NULL REFERENCES projects(project_ref),
  addon_type   text        NOT NULL REFERENCES usage_items(usage_item),
  variant      text        NOT NULL DEFAULT '',
  started_at   timestamptz NOT NULL,
  ended_at     timestamptz,
  CHECK (ended_at IS NULL OR ended_at > started_at)
);

/*
[SIM] Stores platform-reported usage by billing cycle, organisation, project where applicable, and usage item.

Organisation-wide usage has a NULL project_ref.
Hourly usage items are recorded in hours.

[SIM] Each combination of billing cycle, project, usage item and variant can appear only once.

[DOC] Usage quotas and billing scope vary by item. Some usage is aggregated across an organisation, while other limits apply per project.
*/
CREATE TABLE usage_records (
  usage_record_id  bigint         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cycle_id         text           NOT NULL REFERENCES billing_cycles(cycle_id),
  org_id           text           NOT NULL REFERENCES organizations(org_id),
  project_ref      char(20)       REFERENCES projects(project_ref),
  usage_item       text           NOT NULL REFERENCES usage_items(usage_item),
  variant          text           NOT NULL DEFAULT '',
  quantity         numeric(18,4)  NOT NULL CHECK (quantity >= 0),
  recorded_at      timestamptz    NOT NULL
);
CREATE UNIQUE INDEX usage_records_uniq
  ON usage_records (cycle_id, COALESCE(project_ref, ''), usage_item, variant);

-- ---------------------------------------------------------------------
-- INVOICES
-- ---------------------------------------------------------------------

-- One invoice per issue event.
-- [DOC] An invoice issued at a cycle reset mixes fixed fees for the
-- current cycle (fixed_fee_cycle_id) with usage fees for the previous
-- cycle (usage_cycle_id).
-- [SIM] status vocabulary, invoice_kind and tax_treatment values are
-- simulation labels; Supabase's actual labels are not public.
-- [SIM] Intended arithmetic in the seed data:
--   subtotal  = sum of non-tax line items
--   total_due = subtotal - account_credits_applied + tax_amount
-- [UNKNOWN] whether real tax is computed before or after credits.
-- billing_country_snapshot and tax_id_snapshot hold what was in force at
-- issue time ([DOC]: later detail changes do not rewrite old invoices).
CREATE TABLE invoices (
  invoice_id               text          PRIMARY KEY,
  invoice_number           text          NOT NULL UNIQUE,
  org_id                   text          NOT NULL REFERENCES organizations(org_id),
  invoice_kind             text          NOT NULL CHECK (invoice_kind IN ('cycle_reset','plan_change','credit_top_up')),
  fixed_fee_cycle_id       text          REFERENCES billing_cycles(cycle_id),
  usage_cycle_id           text          REFERENCES billing_cycles(cycle_id),
  issued_at                timestamptz   NOT NULL,
  status                   text          NOT NULL CHECK (status IN ('paid','open','overdue','void')),
  currency                 char(3)       NOT NULL DEFAULT 'USD',
  subtotal                 numeric(12,2) NOT NULL,
  account_credits_applied  numeric(12,2) NOT NULL DEFAULT 0 CHECK (account_credits_applied >= 0),
  tax_treatment            text          NOT NULL DEFAULT 'none'
                           CHECK (tax_treatment IN ('none','standard','reverse_charge','exempt')),
  tax_rate                 numeric(6,4)  NOT NULL DEFAULT 0,
  tax_amount               numeric(12,2) NOT NULL DEFAULT 0,
  total_due                numeric(12,2) NOT NULL CHECK (total_due >= 0),
  paid_at                  timestamptz,
  billing_country_snapshot char(2),
  tax_id_snapshot          text
);

-- Invoice lines. Discounts and credits are negative amounts.
-- line_type: fixed_fee | usage | quota_discount | compute_credit | other
-- cycle_id says which cycle the line relates to (current for fixed
-- fees, previous for usage). project_ref and usage_item trace a charge
-- back to a resource.
CREATE TABLE invoice_line_items (
  line_id      bigint         GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  invoice_id   text           NOT NULL REFERENCES invoices(invoice_id),
  line_type    text           NOT NULL CHECK (line_type IN ('fixed_fee','usage','quota_discount','compute_credit','other')),
  cycle_id     text           REFERENCES billing_cycles(cycle_id),
  usage_item   text           REFERENCES usage_items(usage_item),
  variant      text           NOT NULL DEFAULT '',
  project_ref  char(20)       REFERENCES projects(project_ref),
  description  text           NOT NULL,
  quantity     numeric(18,4),
  unit         text,
  unit_price   numeric(12,6),
  amount       numeric(12,2)  NOT NULL
);

-- ---------------------------------------------------------------------
-- PAYMENTS AND CREDITS
-- ---------------------------------------------------------------------

-- [DOC] Credit cards only. Several can be on file; only one is active.
-- A new card must be added before the old one is removed.
CREATE TABLE payment_methods (
  payment_method_id  text        PRIMARY KEY,
  org_id             text        NOT NULL REFERENCES organizations(org_id),
  brand              text        NOT NULL,
  last4              char(4)     NOT NULL,
  exp_month          smallint    NOT NULL CHECK (exp_month BETWEEN 1 AND 12),
  exp_year           smallint    NOT NULL,
  is_active          boolean     NOT NULL,
  added_at           timestamptz NOT NULL,
  removed_at         timestamptz
);

-- Each charge attempt. [DOC] failed charges are retried several times and
-- the customer can trigger a charge via "Pay now".
-- [SIM] failure_code vocabulary: expired_card, card_declined,
-- insufficient_funds, no_payment_method (these mirror the reasons the
-- Billing FAQ lists) plus authentication_required (simulation-only
-- extra). Supabase's real decline-code taxonomy is not public.
-- payment_method_id is NULL when no card was on record.
CREATE TABLE payment_attempts (
  attempt_id         bigint        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  invoice_id         text          NOT NULL REFERENCES invoices(invoice_id),
  payment_method_id  text          REFERENCES payment_methods(payment_method_id),
  attempt_number     smallint      NOT NULL CHECK (attempt_number >= 1),
  attempted_at       timestamptz   NOT NULL,
  triggered_by       text          NOT NULL CHECK (triggered_by IN ('automatic','manual_pay_now')),
  amount             numeric(12,2) NOT NULL,
  status             text          NOT NULL CHECK (status IN ('succeeded','failed')),
  failure_code       text,
  failure_message    text
);

-- Credit balance history. [DOC] Credits are used on future invoices
-- before the card is charged; they do not expire; top-ups cannot pay an
-- outstanding invoice; no cash refunds. amount: positive adds credit,
-- negative uses or removes it. balance_after is the running balance.
CREATE TABLE credit_ledger (
  entry_id            bigint        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  org_id              text          NOT NULL REFERENCES organizations(org_id),
  entry_type          text          NOT NULL
                      CHECK (entry_type IN ('downgrade_proration','top_up','applied_to_invoice','transfer_in','transfer_out','manual_adjustment')),
  amount              numeric(12,2) NOT NULL,
  balance_after       numeric(12,2) NOT NULL CHECK (balance_after >= 0),
  related_invoice_id  text          REFERENCES invoices(invoice_id),
  created_at          timestamptz   NOT NULL,
  note                text
);

-- ---------------------------------------------------------------------
-- OPERATIONS
-- ---------------------------------------------------------------------

-- Timeline of what happened to an organisation. Start here when
-- investigating. `details` is free-form jsonb whose keys depend on the
-- event_type.
CREATE TABLE organization_events (
  event_id       bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  org_id         text        NOT NULL REFERENCES organizations(org_id),
  occurred_at    timestamptz NOT NULL,
  actor_user_id  text        REFERENCES users(user_id),   -- NULL = system
  event_type     text        NOT NULL CHECK (event_type IN (
                   'org_created','plan_changed','spend_cap_enabled','spend_cap_disabled',
                   'payment_method_added','payment_method_removed','payment_method_set_active',
                   'billing_details_updated','credit_top_up','restriction_applied','restriction_lifted',
                   'project_created','project_paused','project_resumed','project_deleted',
                   'addon_enabled','addon_disabled','compute_size_changed')),
  details        jsonb       NOT NULL DEFAULT '{}'::jsonb
);

-- Restrictions applied to an organisation. [DOC] Fair Use Policy
-- restrictions can be triggered by exceeded quotas, overdue invoices or
-- an expired card, and are lifted when the cause is fixed.
-- restriction_type vocabulary follows the Fair Use Policy page.
CREATE TABLE service_restrictions (
  restriction_id      bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  org_id              text        NOT NULL REFERENCES organizations(org_id),
  reason              text        NOT NULL CHECK (reason IN ('quota_exceeded','overdue_invoice','expired_card','abuse_suspected','other')),
  restriction_type    text        NOT NULL CHECK (restriction_type IN ('project_paused','read_only','http_402','new_projects_blocked')),
  applied_at          timestamptz NOT NULL,
  lifted_at           timestamptz,
  related_invoice_id  text        REFERENCES invoices(invoice_id),
  CHECK (lifted_at IS NULL OR lifted_at > applied_at)
);

-- The incoming queue: the OPENING message of each ticket, customer text
-- only. There is no category, priority, owner or answer column. Triage is
-- your job.
-- org_id is NULL when the sender could not be tied to an organisation.
-- requester_user_id is NULL when the sender is not a known user. A known
-- user is not necessarily a member of org_id, so check org_members before
-- deciding what you can safely share with them.
CREATE TABLE support_tickets (
  ticket_id         text        PRIMARY KEY,
  org_id            text        REFERENCES organizations(org_id),
  requester_email   text        NOT NULL,
  requester_user_id text        REFERENCES users(user_id),
  received_at       timestamptz NOT NULL,
  subject           text        NOT NULL,
  body              text        NOT NULL
);

-- Everything after the opening message: customer follow-ups and any
-- earlier replies from support (fictional). seq starts at 1 per ticket.
-- [SIM] Earlier support replies are part of the case file. They may be
-- accurate, incomplete or wrong; verify them like any other claim.
CREATE TABLE ticket_messages (
  message_id   bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ticket_id    text        NOT NULL REFERENCES support_tickets(ticket_id),
  seq          smallint    NOT NULL CHECK (seq >= 1),
  sent_at      timestamptz NOT NULL,
  sender_role  text        NOT NULL CHECK (sender_role IN ('customer','support')),
  sender_email text        NOT NULL,
  body         text        NOT NULL,
  UNIQUE (ticket_id, seq)
);

-- ---------------------------------------------------------------------
-- Helpful (non-answer-revealing) indexes
-- ---------------------------------------------------------------------
CREATE INDEX ON projects (org_id);
CREATE INDEX ON subscriptions (org_id, started_at);
CREATE INDEX ON billing_cycles (org_id, cycle_start);
CREATE INDEX ON project_addons (project_ref, started_at);
CREATE INDEX ON usage_records (org_id, cycle_id);
CREATE INDEX ON invoices (org_id, issued_at);
CREATE INDEX ON invoice_line_items (invoice_id);
CREATE INDEX ON payment_attempts (invoice_id, attempted_at);
CREATE INDEX ON credit_ledger (org_id, created_at);
CREATE INDEX ON organization_events (org_id, occurred_at);
CREATE INDEX ON billing_details_history (org_id, valid_from);
