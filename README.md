# Online Report Card

A ReRev Labs Pixie. Visitors enter their name, email, and a link or two, and get a graded report card of their online presence, rendered as a gallery piece. Every run captures a lead in Supabase. Built as a static page plus one Netlify Function so it scales to zero and costs nothing when idle.

The key is never in the browser. The page calls `/api/report`; the function holds every secret server-side.

## Setup (one time)

### 1. Supabase
1. Create a project at supabase.com.
2. SQL editor, paste and run `supabase.sql`.
3. Project Settings, API: copy the **Project URL** and the **service_role** key (the secret one, not anon).

### 2. Cloudflare Turnstile (the bot check)
1. Cloudflare dashboard, Turnstile, add a widget for your domain.
2. Copy the **Site key** and the **Secret key**.
3. In `index.html`, replace `YOUR_TURNSTILE_SITE_KEY` with the Site key.

### 3. Netlify
1. Add a new site from this GitHub repo. Build settings are read from `netlify.toml`, nothing to type.
2. Site configuration, Environment variables, add:

| Variable | Value |
|---|---|
| `ANTHROPIC_API_KEY` | your Anthropic key |
| `SUPABASE_URL` | the Project URL |
| `SUPABASE_SERVICE_KEY` | the service_role key |
| `TURNSTILE_SECRET` | the Turnstile Secret key |
| `DAILY_CAP` | a number, e.g. `100` (max runs per day) |

3. Deploy. Test the live URL: a run should drop a row in the `report_cards` table.

### 4. Surface on rerev.io
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
- RLS on the leads table

## Notes
- The Turnstile check activates only once `TURNSTILE_SECRET` is set, so you can test before wiring it.
- `DAILY_CAP` is your spend ceiling. Size it against current Anthropic pricing for one Sonnet call plus up to 5 web searches.
