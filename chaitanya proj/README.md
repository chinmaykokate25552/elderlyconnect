# 🤝 ElderlyConnect — Setup Guide

A production-ready freelance platform where **students help elderly people** with everyday tasks — medicines, cleaning, groceries, and more.

---

## 📁 File Structure
```
elderlyconnect/
├── index.html      → Landing page (public)
├── auth.html       → Sign in / Sign up
├── elder.html      → Elder dashboard (post tasks)
├── helper.html     → Helper dashboard (browse & apply)
├── admin.html      → Admin master panel
├── style.css       → Global shared styles
├── supabase.js     → Supabase client + auth helpers
└── schema.sql      → Database schema (run once)
```

---

## 🚀 Quick Setup (5 minutes)

### Step 1 — Create Supabase Project
1. Go to [supabase.com](https://supabase.com) → New Project
2. Give it a name, set a database password, choose region

### Step 2 — Run the Schema
1. In Supabase → **SQL Editor** → New Query
2. Paste the entire contents of `schema.sql`
3. Click **Run**

### Step 3 — Add Your Keys
Open `supabase.js` and replace:
```js
const SUPABASE_URL  = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON = 'YOUR_ANON_KEY';
```
Find these in: Supabase → **Settings** → **API**

### Step 4 — Create Admin Account
1. Open `auth.html` in browser
2. Select **Admin** role, sign up with your email
3. Go to Supabase → SQL Editor and run:
```sql
update public.profiles
set role = 'admin', is_verified = true
where email = 'your-admin@email.com';
```

### Step 5 — Deploy
Upload all files to any static host:
- **Netlify** (drag & drop folder) — free
- **Vercel** — free
- **GitHub Pages** — free
- Any cPanel/shared hosting — just upload folder

---

## 👥 User Roles

| Role    | Dashboard     | Can Do                                |
|---------|--------------|---------------------------------------|
| Elder   | elder.html   | Post tasks, view applications, accept helpers |
| Helper  | helper.html  | Browse tasks, apply, track earnings   |
| Admin   | admin.html   | Manage all users, tasks, verify helpers |

---

## 🗄️ Database Tables

| Table        | Purpose                             |
|-------------|-------------------------------------|
| profiles    | All user accounts + roles           |
| tasks       | Tasks posted by elders              |
| applications| Helper applications to tasks        |

---

## 🔒 Security Notes
- Row Level Security (RLS) is enabled on all tables
- Elders can only manage their own tasks
- Helpers can only apply once per task
- Admins can manage everything
- Never expose your `service_role` key on the frontend

---

## 🎨 Tech Stack
- **HTML + CSS + Vanilla JS** — no frameworks
- **Supabase** — auth + database + RLS
- **Google Fonts** — Clash Display, Instrument Serif, DM Sans

Built with ❤️ for a kinder world.
