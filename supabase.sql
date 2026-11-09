-- Shared garden + RSVPs for the wedding site.
-- Paste into Supabase → SQL Editor → New query, then Run.
-- Anyone can read the garden and add a well-formed flower; nobody can edit or delete.
-- Each browser (who) can plant one of each flower, so three at most.

create table if not exists public.flowers (
  id bigint generated always as identity primary key,
  f  text        not null check (f in ('daisy', 'tulip', 'sprig')),
  x  real        not null check (x between 0 and 100),
  h  int         not null check (h between 58 and 108),
  r  int         not null check (r between -10 and 10),
  who uuid       not null,
  t  timestamptz not null default now()
);
create index if not exists flowers_t on public.flowers (t desc);
create unique index if not exists flowers_one_each on public.flowers (who, f);

alter table public.flowers enable row level security;

drop policy if exists "garden is public" on public.flowers;
create policy "garden is public" on public.flowers for select to anon using (true);

drop policy if exists "anyone can bloom" on public.flowers;
create policy "anyone can bloom" on public.flowers for insert to anon with check (true);

-- guests may only send the flower itself; the time is always set by the server
revoke all on public.flowers from anon;
-- "who" can be written but never read back, so nobody can see which flowers came from whom
grant select (f, x, h, r, t) on public.flowers to anon;
grant insert (f, x, h, r, who) on public.flowers to anon;


-- RSVPs: guests can send one, but nobody can read them from the site.
-- You see them in Table Editor → rsvps (Export → CSV for a spreadsheet).

create table if not exists public.rsvps (
  id      bigint generated always as identity primary key,
  name    text        not null check (char_length(name) between 1 and 120),
  joining text        not null check (char_length(joining) <= 80),
  message text        not null default '' check (char_length(message) <= 1000),
  sent_to text        not null check (char_length(sent_to) <= 80),
  t       timestamptz not null default now()
);

alter table public.rsvps enable row level security;

drop policy if exists "guests can rsvp" on public.rsvps;
create policy "guests can rsvp" on public.rsvps for insert to anon with check (true);

revoke all on public.rsvps from anon;
grant insert (name, joining, message, sent_to) on public.rsvps to anon;
