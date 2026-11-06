-- ============================================================
-- Gym & Fitness Management System - Supabase schema
-- Run this once in Supabase: Dashboard > SQL Editor > New query
-- ============================================================

create extension if not exists "pgcrypto";

-- ----------------------------------------------------------
-- 1. Profiles (one row per authenticated user: admin/trainer/member)
-- ----------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('admin','trainer','member')),
  phone text,
  created_at timestamptz not null default now()
);

-- Creates a profile row automatically whenever a new auth user signs up.
-- The role and full_name are passed in from the sign-up form as user metadata.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'New User'),
    coalesce(new.raw_user_meta_data->>'role', 'member')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Helper used inside policies to read the caller's role without recursion.
create or replace function public.current_role()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select role from public.profiles where id = auth.uid();
$$;

-- ----------------------------------------------------------
-- 2. Members
-- ----------------------------------------------------------
create table if not exists public.members (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  full_name text not null,
  email text,
  phone text,
  dob date,
  gender text,
  address text,
  medical_notes text,
  status text not null default 'active' check (status in ('active','inactive')),
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------
-- 6. Attendance
-- ----------------------------------------------------------
create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  check_in timestamptz not null default now(),
  check_out timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.trainer_attendance (
  id uuid primary key default gen_random_uuid(),
  trainer_id uuid not null references public.trainers(id) on delete cascade,
  check_in timestamptz not null default now(),
  check_out timestamptz,
  created_at timestamptz not null default now()
);

-- ----------------------------------------------------------
-- 7. Payments
-- ----------------------------------------------------------
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members(id) on delete cascade,
  plan_id uuid references public.membership_plans(id) on delete set null,
  amount numeric(10,2) not null,
  status text not null default 'pending' check (status in ('pending','paid','overdue')),
  invoice_date date not null default current_date,
  due_date date,
  paid_date date,
  notes text,
  created_at timestamptz not null default now()
);
