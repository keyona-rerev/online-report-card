# Online Report Card

A ReRev Labs Pixie. Visitors enter their name, email, and a link or two, and get a graded report card of their online presence, rendered as a gallery piece. Every run captures a lead in Supabase and emails the visitor their card. Built as a static page plus two Netlify Functions so it scales to zero and costs nothing when idle.

The key is never in the browser. The page calls `/api/report`; the function holds every secret server-side.

## What's where

- `index.html` — the tool people use
- `report.html` — the shareable result page, with a Download-as-PNG button; reached at `/report.html?t=TOKEN`
- `netlify/functions/report.js` — runs a report: validate, Turnstile, grade via Anthropic, save to Supabase, email the visitor
- `netlify/functions/get-report.js` — reads one saved report by its token so `report.html` can render it
- `supabase.sql` — the leads/results table

## Setup (one time)

### 1. Supabase
1. Create a project at supabase.com.
2. SQL editor, paste and run `supabase.sql`.
3. Project Settings, API: copy the **Project URL** and the **service_role** key (the secret one, not anon).

### 2. Cloudflare Turnstile (the bot check)
1. Cloudflare dashboard, Turnstile, add a widget for your domain.
2. Copy the **Site key** and the **Secret key**.
3. In `index.html`, replace `YOUR_TURNSTILE_SITE_KEY` with the Site key.

### 3. Resend (the email)
1. Create an account at resend.com and an API key.
2. To send to anyone, add and verify your sending domain under Resend, Domains (paste the DNS records it gives you). Until verified, Resend's sandbox only delivers to your own account address from `onboarding@resend.dev`.

### 4. Netlify
1. Add a new site from this GitHub repo. Build settings are read from `netlify.toml`, nothing to type.
2. Site configuration, Environment variables, add:

| Variable | Value |
|---|---|
| `ANTHROPIC_API_KEY` | your Anthropic key |
| `SUPABASE_URL` | the Project URL |
| `SUPABASE_SERVICE_KEY` | the service_role key |
| `TURNSTILE_SECRET` | the Turnstile Secret key |
| `DAILY_CAP` | a number, e.g. `100` (max runs per day) |
| `RESEND_API_KEY` | your Resend key (email is skipped until this is set) |
| `EMAIL_FROM` | sender address, e.g. `ReRev Labs <reports@rerev.io>`; use `onboarding@resend.dev` while in the Resend sandbox |
| `EMAIL_REPLY_TO` | where replies go; defaults to `keyona@rerev.io` if unset |

3. Deploy. Env var changes only take effect on a new deploy. Test the live URL: a run should drop a row in `report_cards` and (if `RESEND_API_KEY` is set and not cached) send an email.

### 5. Surface on rerev.io
Add a button anywhere on the site linking to the Netlify URL (or a `report.rerev.io` subdomain pointed at the site).

## Guards in place
- Key isolation (all secrets server-side)
- Required name + email gate before any run
- Cloudflare Turnstile human check
- Hard daily budget cap (`DAILY_CAP`)
- Per-IP rate limit (4 runs / 10 min)
- 24h result cache (same person + type)
- Server-side input validation and output validation
- HTML-escaped rendering
- Shareable pages keyed by an unguessable token; leads table stays private behind RLS

## Notes
- The Turnstile check activates only once `TURNSTILE_SECRET` is set, so you can test before wiring it. Likewise, email sends only once `RESEND_API_KEY` is set.
- The 24h cache returns a saved result for the same email + business type and skips the email step on repeats. When testing email, vary the email or business type each run, or you'll keep hitting the cache.
- `DAILY_CAP` is your spend ceiling. Size it against current Anthropic pricing for one Sonnet call plus up to 5 web searches.
