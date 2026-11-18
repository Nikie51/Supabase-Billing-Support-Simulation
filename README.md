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

The repository is organised into two main folders:

**`database/`** – Contains the PostgreSQL database structure and fictional customer and billing records used in the simulation.

- `billing_database_structure.sql` – Defines the database tables, relationships and constraints.
- `01_customers_and_projects.sql` – Contains sample organisations, users and projects.
- `02_usage_and_invoices.sql` – Contains customer usage records and invoice information.
- `03_payments_and_billing_activity.sql` – Contains payment records and billing events.
- `04_support_cases_and_restrictions.sql` – Contains customer support records and service restrictions.

**`support/`** – Contains the fictional customer cases used to practise billing investigations.

- `billing_support_case_scenarios.md` – Describes customer-reported issues and the supporting information available for investigation.

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

Alongside the PostgreSQL billing simulation, I am exploring the actual Supabase customer dashboard to understand the billing and project-management experience from a customer's perspective. This familiarisation will help connect the fictional investigation scenarios to the product experience customers encounter.

The live Supabase project will remain separate from the simulation database. No fictional customer records or billing data will be uploaded to it.