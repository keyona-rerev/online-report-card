// Netlify Function: GET /api/cleanup?key=YOUR_CLEANUP_KEY
// ONE-TIME maintenance. Strips stray markup (e.g. <cite index=...>) from rows
// that were saved before the sanitizer existed, so old share links render clean.
// Set CLEANUP_KEY in Netlify env, hit this URL once, then you can delete this file.

const json = (statusCode, obj) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(obj),
});

const strip = (s) => String(s == null ? '' : s)
  .replace(/<\/?cite[^>]*>/gi, '')
  .replace(/<[^>]+>/g, '')
  .replace(/\s+/g, ' ')
  .trim();

function cleanReport(rep) {
  if (!rep || typeof rep !== 'object') return rep;
  const out = { ...rep };
  for (const k of ['piece_title', 'first_read', 'narrative', 'audience_read', 'harmony']) {
    if (typeof out[k] === 'string') out[k] = strip(out[k]);
  }
  if (Array.isArray(out.categories)) {
    out.categories = out.categories.map((c) => {
      const cc = { ...c };
      for (const k of ['label', 'sublabel', 'finding', 'win', 'fix']) {
        if (typeof cc[k] === 'string') cc[k] = strip(cc[k]);
      }
      return cc;
    });
  }
  return out;
}

exports.handler = async (event) => {
  const { SUPABASE_URL, SUPABASE_SERVICE_KEY, CLEANUP_KEY } = process.env;
  const key = (event.queryStringParameters || {}).key || '';
  if (!CLEANUP_KEY || key !== CLEANUP_KEY) return json(403, { error: 'Forbidden.' });
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) return json(500, { error: 'Not configured.' });

  const sb = (path, opts = {}) => fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...opts,
    headers: {
      apikey: SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      ...(opts.headers || {}),
    },
  });

  let rows;
  try {
    const r = await sb('report_cards?select=id,first_read,report&order=id.asc');
    rows = await r.json();
  } catch (e) {
    return json(502, { error: 'Could not read rows.' });
  }
  if (!Array.isArray(rows)) return json(502, { error: 'Unexpected response.' });

  let touched = 0, skipped = 0, failed = 0;
  for (const row of rows) {
    const newFirst = strip(row.first_read || '');
    const newReport = cleanReport(row.report);
    const changed = newFirst !== (row.first_read || '') ||
      JSON.stringify(newReport) !== JSON.stringify(row.report);
    if (!changed) { skipped++; continue; }
    try {
      await sb(`report_cards?id=eq.${row.id}`, {
        method: 'PATCH',
        headers: { Prefer: 'return=minimal' },
        body: JSON.stringify({ first_read: newFirst, report: newReport }),
      });
      touched++;
    } catch (e) { failed++; }
  }

  return json(200, { total: rows.length, cleaned: touched, alreadyClean: skipped, failed });
};
