// Netlify Function: GET /api/get-report?t=TOKEN
// Returns one stored report by its unguessable token. Reads with the service key
// (RLS stays on, leads table stays private). Only ever returns a single report.

const json = (statusCode, obj) => ({
  statusCode,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(obj),
});

exports.handler = async (event) => {
  const token = ((event.queryStringParameters || {}).t || '').trim();
  if (!token || token.length > 80) return json(400, { error: 'Missing or invalid token.' });

  const { SUPABASE_URL, SUPABASE_SERVICE_KEY } = process.env;
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) return json(500, { error: 'Not configured.' });

  try {
    const r = await fetch(
      `${SUPABASE_URL}/rest/v1/report_cards?select=full_name,primary_job,secondary_job,composite_grade,composite_score,first_read,report&token=eq.${encodeURIComponent(token)}&limit=1`,
      { headers: { apikey: SUPABASE_SERVICE_KEY, Authorization: `Bearer ${SUPABASE_SERVICE_KEY}` } }
    );
    const rows = await r.json();
    if (!Array.isArray(rows) || !rows.length) return json(404, { error: 'Report not found.' });
    const row = rows[0];
    const rep = row.report || {};
    return json(200, {
      full_name: row.full_name,
      primary_job: row.primary_job,
      secondary_job: row.secondary_job,
      composite_grade: row.composite_grade,
      composite_score: row.composite_score,
      first_read: row.first_read,
      piece_title: rep.piece_title || 'Your Presence',
      narrative: rep.narrative || '',
      audience_read: rep.audience_read || '',
      harmony: rep.harmony || '',
      categories: rep.categories || [],
    });
  } catch (e) {
    return json(500, { error: 'Could not load the report.' });
  }
};
