-- DEPRECATED — this file is kept for history only.
-- This project no longer runs on Supabase. See schema.sql for the current
-- schema, which now runs on a self-hosted Postgres + PostgREST backend on
-- Railway (project: online-report-card-backend). Migrated 2026-07-04.
--
-- Original content below, preserved as-is for reference:

-- Online Report Card: lead + result table
-- Run this in the Supabase SQL editor.

create table if not exists report_cards (
  id              bigint generated always as identity primary key,
  created_at      timestamptz default now(),
  full_name       text not null,
  email           text not null,
  business_type   text,            -- consulting | personal | product
  linkedin        text,
  website         text,
  composite_grade text,
  composite_score int,
  first_read      text,
  report          jsonb,           -- full 7-category breakdown
  ip              text,            -- used only for rate limiting
  token           text unique      -- unguessable id for the shareable /report.html page
);

create index if not exists report_cards_created_idx    on report_cards (created_at desc);
create index if not exists report_cards_email_type_idx on report_cards (email, business_type, created_at desc);
create index if not exists report_cards_ip_idx         on report_cards (ip, created_at desc);

alter table report_cards enable row level security;
