# Supabase setup (Sprint 1 - Person 1 and Person 2)

## Included files

- `js/config.js` — Supabase project URL and anon public key supplied for this project.
- `supabase/schema.sql` — combined database setup for the `profiles` and `members` tables.

## Apply the database schema

1. Open your Supabase project dashboard.
2. Go to **SQL Editor** and create a new query.
3. Open `supabase/schema.sql`, copy its complete contents, and paste them into the SQL Editor.
4. Run the query.
5. In **Table Editor**, confirm that `profiles` and `members` were created.

## Configuration note

`js/config.js` contains the project URL and Supabase anon public key provided by the team. The anon key is intended for frontend use; database access must still be protected by appropriate Row Level Security (RLS) policies. This schema file does not add RLS policies because none were included in the supplied Person 1/Person 2 SQL.

## Scope

This update covers only the supplied Person 1 and Person 2 work: Supabase configuration, the profiles setup, and the members table. Existing Gym Management System pages and styling have been preserved. The current HTML pages are still static mockups; this update does not connect their forms to Supabase.
