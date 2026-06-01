# Deploy LOR Alliance Academy with GitHub Pages + Supabase

## 1. Create Supabase database

1. Go to https://supabase.com and create a project.
2. Open `SQL Editor`.
3. Copy all SQL from `supabase-schema.sql`.
4. Paste it into Supabase and click `Run`.
5. Go to `Project Settings` > `API`.
6. Copy:
   - `Project URL`
   - `anon public` key

## 2. Test database in the app

1. Open `index.html` or `alliance-academy.html`.
2. Click the shield/admin icon.
3. Paste:
   - Supabase Project URL
   - Supabase Anon Key
4. Click `Save Database`.
5. Click `Sync Now`.

If it says `Synced with Supabase`, database is connected.

## 3. Upload to GitHub

Create a new GitHub repository, then upload these files from the `outputs` folder:

- `index.html`
- `cat-icon.png`
- `supabase-schema.sql`
- `DEPLOY-GITHUB-SUPABASE.md`

`index.html` must be in the repository root so GitHub Pages opens it automatically.

## 4. Enable GitHub Pages

1. Open the repository on GitHub.
2. Go to `Settings` > `Pages`.
3. Under `Build and deployment`, choose:
   - Source: `Deploy from a branch`
   - Branch: `main`
   - Folder: `/root`
4. Click `Save`.

Your public site URL will look like:

`https://YOUR-GITHUB-USERNAME.github.io/YOUR-REPO-NAME/`

## 5. Important

This version stores Supabase URL and anon key in browser localStorage after you paste them in Admin.
For a public academy, the anon key is expected to be visible. The SQL policies allow public lesson reads, lesson edits, and quiz result inserts so the static site can work without a backend server.

The Admin screen has a browser-side password lock. This prevents normal members from casually opening Admin, but it is not the same as server-side security.

For stricter admin security later, add Supabase Auth and restrict lesson editing to admin users only.
