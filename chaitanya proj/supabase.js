// ============================================================
//  ElderlyConnect — Supabase Config
//  Replace the two constants below with your project values
// ============================================================
const SUPABASE_URL  = 'https://nxtiopkjqerybcwjsoto.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54dGlvcGtqcWVyeWJjd2pzb3RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MDIxNjcsImV4cCI6MjA5MjE3ODE2N30.9IwZhv5OcQaTP9ej9Wx-puKv6nAvpzmNmk8mk0PGfpw';

const { createClient } = supabase;
const sb = createClient(SUPABASE_URL, SUPABASE_ANON);

// ── Auth helpers ────────────────────────────────────────────
async function getSession() {
  const { data } = await sb.auth.getSession();
  return data.session;
}

async function getProfile(userId) {
  const { data } = await sb
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single();
  return data;
}

async function signOut() {
  await sb.auth.signOut();
  window.location.href = 'index.html';
}

// ── Route guard ─────────────────────────────────────────────
async function requireAuth(allowedRole) {
  const session = await getSession();
  if (!session) { window.location.href = 'auth.html'; return null; }

  const profile = await getProfile(session.user.id);
  if (!profile) { window.location.href = 'auth.html'; return null; }

  if (allowedRole && profile.role !== allowedRole && profile.role !== 'admin') {
    window.location.href = 'index.html'; return null;
  }
  return { session, profile };
}
