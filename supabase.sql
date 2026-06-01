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

-- Already have the table from an earlier version? Add the token column instead:
--   alter table report_cards add column if not exists token text unique;

-- Indexes for the cap / rate-limit / cache lookups.
-- (The unique constraint on token already provides an index for share-page reads.)
create index if not exists report_cards_created_idx    on report_cards (created_at desc);
create index if not exists report_cards_email_type_idx on report_cards (email, business_type, created_at desc);
create index if not exists report_cards_ip_idx         on report_cards (ip, created_at desc);

-- Lock the table down. The server uses the service-role key, which bypasses RLS.
-- With RLS on and no policies, the public anon key cannot read your leads.
alter table report_cards enable row level security;
