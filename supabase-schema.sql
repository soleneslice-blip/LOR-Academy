-- LOR Alliance Academy Supabase schema
-- Run this in Supabase Dashboard > SQL Editor > New query.

create extension if not exists pgcrypto;

create table if not exists public.lessons (
  slug text primary key,
  category text not null default 'Alliance Rules',
  title text not null,
  content text not null,
  question text not null,
  options jsonb not null default '[]'::jsonb,
  answer text not null,
  quizzes jsonb,
  position integer not null default 1,
  enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.lessons add column if not exists category text not null default 'Alliance Rules';
alter table public.lessons add column if not exists quizzes jsonb;

create table if not exists public.quiz_results (
  id uuid primary key default gen_random_uuid(),
  ign text not null,
  alliance text not null,
  state_no text not null,
  lesson_id text not null,
  lesson_title text not null,
  score integer not null default 0,
  correct boolean not null default false,
  selected_answer text,
  correct_answer text,
  duration_seconds integer not null default 0,
  completed_at timestamptz not null default now()
);

create table if not exists public.app_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create or replace view public.leaderboard as
select
  ign,
  alliance,
  state_no,
  round(avg(score))::integer as average_score,
  count(distinct lesson_id)::integer as lessons_completed,
  coalesce(sum(duration_seconds), 0)::integer as total_time_seconds,
  (
    count(distinct lesson_id) >= (select count(*) from public.lessons where enabled = true)
    and avg(score) >= 80
  ) as certified,
  max(completed_at) as updated_at
from public.quiz_results
group by ign, alliance, state_no
order by average_score desc, total_time_seconds asc, lessons_completed desc;

alter table public.lessons enable row level security;
alter table public.quiz_results enable row level security;
alter table public.app_settings enable row level security;

drop policy if exists "Public can read lessons" on public.lessons;
drop policy if exists "Public can write lessons" on public.lessons;
drop policy if exists "Public can read quiz results" on public.quiz_results;
drop policy if exists "Public can insert quiz results" on public.quiz_results;
drop policy if exists "Public can read app settings" on public.app_settings;
drop policy if exists "Public can write app settings" on public.app_settings;

create policy "Public can read lessons"
on public.lessons for select
using (true);

create policy "Public can write lessons"
on public.lessons for all
using (true)
with check (true);

create policy "Public can read quiz results"
on public.quiz_results for select
using (true);

create policy "Public can insert quiz results"
on public.quiz_results for insert
with check (true);

create policy "Public can read app settings"
on public.app_settings for select
using (true);

create policy "Public can write app settings"
on public.app_settings for all
using (true)
with check (true);

insert into public.lessons (slug, category, title, content, question, options, answer, quizzes, position, enabled)
values
('bear-rally-calling', 'Bear Hunt', 'Bear Hunt - Rally Calling', 'TG2 and above members may call rallies.

Minute 1: First row may call rallies.
Minute 2: Second row may call rallies.
Minute 3: Third row may call rallies.
Final 7 minutes: All members may call rallies.', 'Who can call rallies during the final 7 minutes?', '["Only first row players","Only R4/R5","All members"]'::jsonb, 'All members', null, 1, true),
('bear-rally-participation', 'Bear Hunt', 'Bear Hunt - Rally Participation', 'Always join the rally with the shortest remaining march time.

Preferred joining heroes: Chenko, Amane, Yeonwo, Hilde, Amadeus, or No Hero.

Maximum troops: 80,000 troops.', 'How many troops should be sent?', '["50,000","80,000","120,000"]'::jsonb, '80,000', null, 2, true),
('sanctuary-attack', 'Sanctuary Battle', 'Sanctuary Battle - Attack Rules', 'Solo attacks are prohibited.

Only rally attacks are allowed.', 'Are solo attacks allowed?', '["Yes","No","Only during the first minute"]'::jsonb, 'No', null, 3, true),
('sanctuary-defense', 'Sanctuary Battle', 'Sanctuary Battle - Defense Setup', 'Recommended defensive heroes: Patrick, Howard, Saul, and Hilde.

Use defensive heroes only when reinforcing or holding objectives.', 'Which heroes should be used for defense?', '["Defensive heroes only","Gathering heroes","Any heroes"]'::jsonb, 'Defensive heroes only', null, 4, true),
('sanctuary-troops', 'Sanctuary Battle', 'Sanctuary Battle - Troop Limits', 'Rally leaders: maximum 80,000 troops.

Rally joiners: maximum 80,000 troops.', 'What is the troop limit?', '["60,000 troops","80,000 troops","No limit"]'::jsonb, '80,000 troops', null, 5, true),
('sanctuary-rewards', 'Sanctuary Battle', 'Sanctuary Battle - Reward Distribution', 'Rewards are distributed within 24 hours by R4/R5.

Highest contributors receive maximum rewards. Remaining rewards are shared equally among active participants.', 'Who distributes rewards?', '["R4/R5","Any participant","The highest contributor"]'::jsonb, 'R4/R5', null, 6, true),
('swordland-registration', 'Swordland', 'Swordland Registration', 'Participation is optional.

Members must register before the event starts. Only registered members will be included in planning and team assignments.', 'Can unregistered members join planning?', '["Yes","No","Only if they ask in Discord"]'::jsonb, 'No', null, 7, true),
('tri-alliance-registration', 'Tri Alliance Clash', 'Tri Alliance Clash Registration', 'Participation is optional.

Members must register before the event starts. Only registered members will be included in planning and team assignments.', 'Who will be assigned to teams?', '["Everyone online","Registered members only","Only R4/R5"]'::jsonb, 'Registered members only', null, 8, true)
on conflict (slug) do update set
  category = excluded.category,
  title = excluded.title,
  content = excluded.content,
  question = excluded.question,
  options = excluded.options,
  answer = excluded.answer,
  quizzes = excluded.quizzes,
  position = excluded.position,
  enabled = excluded.enabled,
  updated_at = now();
