-- Current schema for online-report-card. Runs on a self-hosted Postgres +
-- PostgREST backend on Railway (project: online-report-card-backend), not
-- Supabase. Migrated 2026-07-04; see supabase.sql for the deprecated history.
--
-- To apply: Railway dashboard -> Postgres service -> Data tab -> paste and run.

create table if not exists report_cards (
  id              bigint generated always as identity primary key,
  created_at      timestamptz default now(),
  full_name       text not null,
  email           text not null,
  business_type   text,
  linkedin        text,
  website         text,
  composite_grade text,
  composite_score int,
  first_read      text,
  report          jsonb,
  ip              text,
  token           text unique,
  primary_job     text,
  secondary_job   text
);
create index if not exists report_cards_created_idx    on report_cards (created_at desc);
create index if not exists report_cards_email_type_idx on report_cards (email, business_type, created_at desc);
create index if not exists report_cards_ip_idx         on report_cards (ip, created_at desc);
alter table report_cards enable row level security;

create table if not exists scholarship_reports (
  id          bigint generated always as identity primary key,
  created_at  timestamptz default now(),
  full_name   text not null,
  email       text not null,
  sport       text,
  gpa         numeric,
  verdict     text,
  report      jsonb,
  ip          text,
  token       text unique
);
create index if not exists scholarship_reports_created_idx on scholarship_reports (created_at desc);
create index if not exists scholarship_reports_ip_idx      on scholarship_reports (ip, created_at desc);
alter table scholarship_reports enable row level security;

create table if not exists benchmark_reports (
  id          bigint generated always as identity primary key,
  created_at  timestamptz default now(),
  full_name   text not null,
  email       text not null,
  sport       text,
  event_key   text,
  gender      text,
  metric_raw  text,
  grad_year   int,
  verdict     text,
  report      jsonb,
  ip          text,
  token       text unique
);
create index if not exists benchmark_reports_created_idx on benchmark_reports (created_at desc);
create index if not exists benchmark_reports_ip_idx      on benchmark_reports (ip, created_at desc);
alter table benchmark_reports enable row level security;

create table if not exists timeline_reports (
  id          bigint generated always as identity primary key,
  created_at  timestamptz default now(),
  full_name   text not null,
  email       text not null,
  sport       text,
  grad_year   int,
  verdict     text,
  report      jsonb,
  ip          text,
  token       text unique
);
create index if not exists timeline_reports_created_idx on timeline_reports (created_at desc);
create index if not exists timeline_reports_ip_idx      on timeline_reports (ip, created_at desc);
alter table timeline_reports enable row level security;

create table if not exists eligibility_reports (
  id          bigint generated always as identity primary key,
  created_at  timestamptz default now(),
  full_name   text not null,
  email       text not null,
  division    text,
  core_done   int,
  core_gpa    numeric,
  grad_year   int,
  verdict     text,
  report      jsonb,
  ip          text,
  token       text unique
);
create index if not exists eligibility_reports_created_idx on eligibility_reports (created_at desc);
create index if not exists eligibility_reports_ip_idx      on eligibility_reports (ip, created_at desc);
alter table eligibility_reports enable row level security;
