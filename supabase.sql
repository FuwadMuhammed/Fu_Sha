-- Shared garden for the wedding site.
-- Paste into Supabase → SQL Editor → New query, then Run.
-- Anyone can read the garden and add a well-formed flower; nobody can edit or delete.

create table if not exists public.flowers (
  id bigint generated always as identity primary key,
  f  text        not null check (f in ('daisy', 'tulip', 'sprig')),
  x  real        not null check (x between 0 and 100),
  h  int         not null check (h between 58 and 108),
  r  int         not null check (r between -10 and 10),
  t  timestamptz not null default now()
);
create index if not exists flowers_t on public.flowers (t desc);

alter table public.flowers enable row level security;

drop policy if exists "garden is public" on public.flowers;
create policy "garden is public" on public.flowers for select to anon using (true);

drop policy if exists "anyone can bloom" on public.flowers;
create policy "anyone can bloom" on public.flowers for insert to anon with check (true);

-- guests may only send the flower itself; the time is always set by the server
revoke all on public.flowers from anon;
grant select on public.flowers to anon;
grant insert (f, x, h, r) on public.flowers to anon;
