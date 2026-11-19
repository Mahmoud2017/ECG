-- =====================================================================
-- RECONSTRUCTED schema for CardioPulse MD (project xomswbnxqrxrjohjyhkm)
--
-- Table/column names come from strings inside the release binary.
-- Types, constraints, RLS and the exact layout of `content` / `contact_info`
-- are BEST GUESSES. Your real database is still live on Supabase — prefer
-- dumping the real schema (see RECOVERY.md) over running this file.
-- =====================================================================

-- ---------- profiles (1 row per auth user) ----------
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  full_name     text,
  email         text,
  phone_number  text,
  location      text,
  avatar_url    text,
  specialty     text,
  role          text default 'doctor',
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "own profile read"   on public.profiles for select using (auth.uid() = id);
create policy "own profile update" on public.profiles for update using (auth.uid() = id);

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, phone_number)
  values (new.id, new.email,
          new.raw_user_meta_data->>'full_name',
          new.raw_user_meta_data->>'phone_number');
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- patients (one analysed ECG per row) ----------
create table if not exists public.patients (
  id                 uuid primary key default gen_random_uuid(),
  doctor_id          uuid not null references auth.users(id) on delete cascade,
  patient_code       text not null check (char_length(patient_code) <= 40),
  age                int  check (age between 0 and 130),
  biological_sex     text check (biological_sex in ('male','female','other')),
  lead_configuration text,
  sampling_rate      int,
  notes              text,
  severity           text check (severity in ('normal','borderline','abnormal')),
  heart_rate         int,
  pr_interval        int,
  qrs_duration       int,
  qtc_interval       int,
  findings           jsonb default '[]'::jsonb,
  summary            text,
  confidence         numeric,
  engine             text,
  created_at         timestamptz default now()
);
alter table public.patients enable row level security;
create policy "doctor owns patients" on public.patients
  for all using (auth.uid() = doctor_id) with check (auth.uid() = doctor_id);

-- ---------- content (privacy / terms / faq per locale) ----------
create table if not exists public.content (
  id            uuid primary key default gen_random_uuid(),
  kind          text not null check (kind in ('privacy','terms','faq')),
  locale        text not null default 'en',
  title         text,
  body          text,
  like_count    int default 0,
  unlike_count  int default 0,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);
alter table public.content enable row level security;
create policy "content public read" on public.content for select using (true);

-- ---------- faq_votes + faq_vote RPC ----------
create table if not exists public.faq_votes (
  faq_id   uuid references public.content(id) on delete cascade,
  user_id  uuid references auth.users(id) on delete cascade default auth.uid(),
  helpful  boolean not null,
  created_at timestamptz default now(),
  primary key (faq_id, user_id)
);
alter table public.faq_votes enable row level security;
create policy "own votes" on public.faq_votes for all using (auth.uid() = user_id);

create or replace function public.faq_vote(faq_id uuid, helpful boolean) returns void
language plpgsql security definer set search_path = public as $$
begin
  insert into faq_votes (faq_id, user_id, helpful) values (faq_vote.faq_id, auth.uid(), faq_vote.helpful)
  on conflict (faq_id, user_id) do update set helpful = excluded.helpful;
  update content c set
    like_count   = (select count(*) from faq_votes v where v.faq_id = c.id and v.helpful),
    unlike_count = (select count(*) from faq_votes v where v.faq_id = c.id and not v.helpful)
  where c.id = faq_vote.faq_id;
end $$;

-- ---------- contact_messages ----------
create table if not exists public.contact_messages (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete set null,
  name       text not null,
  email      text not null,
  phone      text,
  message    text not null check (char_length(message) between 5 and 5000),
  created_at timestamptz default now()
);
alter table public.contact_messages enable row level security;
create policy "anyone can send" on public.contact_messages for insert with check (true);

-- ---------- contact_info (GUESS: single row of links) ----------
create table if not exists public.contact_info (
  id         int primary key default 1 check (id = 1),
  phone      text,
  email      text,
  whatsapp   text,
  facebook   text,
  instagram  text,
  linkedin   text,
  twitter    text
);
alter table public.contact_info enable row level security;
create policy "contact info public read" on public.contact_info for select using (true);
