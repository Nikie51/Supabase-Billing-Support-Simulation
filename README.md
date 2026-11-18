# Supabase Billing Support Simulation

A PostgreSQL-based practice project for investigating billing discrepancies, payment issues, subscription changes, and customer support cases using fictional data.

## Project Purpose

This project was developed to practise and demonstrate technical investigation skills relevant to billing support.

It simulates a billing environment where customer-reported issues can be investigated by querying related records, tracing billing activity, examining invoices and payments, and assessing the available evidence before making a support decision.

The focus is not simply on writing SQL queries. It is on using data to understand reported problems, identify discrepancies, distinguish confirmed findings from assumptions, and communicate clear support outcomes.

## Project Development and AI Assistance

Claude was used as an AI-assisted development tool during the initial creation of the database structure, fictional dataset, and support scenarios.

I am responsible for reviewing and working through the generated material, understanding the database relationships, adapting the project where necessary, and developing the SQL queries and investigation logic as part of my learning process.

This repository documents that work and the practical skills I am developing through it. AI assistance is acknowledged as part of the project's development rather than presented as independent authorship of all its original components.

## Technology

- PostgreSQL
- SQL
- pgAdmin 4

## Data and Scope

The simulation contains fictional records representing organisations, users, projects, subscriptions, usage, invoices, payments, billing events, and support tickets.

The scenarios are informed by publicly available Supabase documentation and community discussions, including:

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Community Discussions](https://discord.com/invite/supabase)
- [Supabase GitHub Issues](https://github.com/supabase/supabase/issues)

These resources provide context for the practice scenarios. The database structure, records, and investigation rules are an independent simulation. They are not a reproduction of Supabase's internal billing infrastructure or a verified account of its production workflows.

## Project Structure

- `README.md` - Introduces the project, its purpose, development approach, and scope.
- `database/schema.sql` - Creates the database schema, tables, and relationships.
- `database/seed_1_orgs_projects.sql` - Loads organization and project records.
- `database/seed_2_usage_invoices.sql` - Loads usage and invoice records.
- `database/seed_3_payments_events.sql` - Loads payment and billing event records.
- `database/seed_4_support_queue.sql` - Loads support tickets and related records.
- `support_queue.md` - Describes the fictional customer support scenarios.
- `investigations/` - Contains documented investigations of selected support cases.

## Skills Practised

- Writing SQL queries to retrieve, filter, and organise billing records.
- Joining related tables to trace customer and billing activity.
- Using aggregate functions to examine usage, invoices, and payments.
- Investigating billing discrepancies and potential causes.
- Examining relationships between subscriptions, usage records, invoices, and payments.
- Evaluating available evidence before reaching a support decision.
- Identifying missing information and distinguishing it from confirmed findings.
- Translating technical findings into clear customer-facing explanations and support recommendations.

## Limitations

This is an independent learning project built with fictional data. It does not connect to Supabase services, Stripe, or any production billing system.

Some billing behaviours and investigation rules are simplified for practice. The simulation should not be treated as evidence of Supabase's actual internal billing processes. Where the available data does not establish a definitive explanation, that limitation should be documented rather than replaced with an unsupported assumption.

## Supabase Product Familiarisation

Alongside the PostgreSQL billing simulation, this project includes familiarization with the actual Supabase customer dashboard. The goal is to understand the customer-facing billing and project-management experience and connect it to the billing investigation scenarios developed in the simulation.

The live Supabase project will remain separate from the simulation database. No fictional customer records or billing data will be uploaded to it.
