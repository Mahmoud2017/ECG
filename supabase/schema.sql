-- =====================================================================
-- CardioPulse MD — schema of the live project xomswbnxqrxrjohjyhkm
-- (exported from the Supabase dashboard by the owner, 2026-11-19).
-- Reference only: table order, RLS policies and triggers are not included.
-- Identifiers that need quoting ("order", "job-title", camelCase names) are quoted here.
-- =====================================================================

CREATE TABLE public."privacyPolicy" (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text,
  description text,
  "order" bigint,
  is_active boolean DEFAULT true,
  CONSTRAINT "privacyPolicy_pkey" PRIMARY KEY (id)
);

CREATE TABLE public.terms (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text,
  description text,
  "order" smallint,
  CONSTRAINT terms_pkey PRIMARY KEY (id)
);

CREATE TABLE public.faq (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  title text,
  description text,
  like_count numeric DEFAULT '0'::numeric,
  unlike_count numeric DEFAULT '0'::numeric,
  "order" numeric,
  CONSTRAINT faq_pkey PRIMARY KEY (id)
);

CREATE TABLE public."socialLinks" (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  "phoneNo" text,
  "whatsApp" text,
  "faceBook" text,
  instagram text,
  x text,
  "linkedIn" text,
  email text DEFAULT 'info@cardioPlus.co'::text,
  CONSTRAINT "socialLinks_pkey" PRIMARY KEY (id)
);

CREATE TABLE public."onBoarding" (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  image text,
  content text,
  title text,
  orders smallint GENERATED ALWAYS AS IDENTITY NOT NULL,
  is_active boolean,
  CONSTRAINT "onBoarding_pkey" PRIMARY KEY (id)
);

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  full_name text,
  email text,
  "phoneNo" text,
  "job-title" text,
  specialty text,
  avatar_url text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

CREATE TABLE public.patients (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  doctor_id uuid NOT NULL DEFAULT auth.uid(),
  patient_code text NOT NULL CHECK (char_length(patient_code) >= 1 AND char_length(patient_code) <= 40),
  age integer CHECK (age >= 0 AND age <= 130),
  sex text CHECK (sex = ANY (ARRAY['male'::text, 'female'::text, 'other'::text])),
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT patients_pkey PRIMARY KEY (id),
  CONSTRAINT patients_doctor_id_fkey FOREIGN KEY (doctor_id) REFERENCES public.profiles(id)
);

CREATE TABLE public.contact_messages (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid DEFAULT auth.uid(),
  full_name text NOT NULL CHECK (char_length(full_name) >= 2 AND char_length(full_name) <= 120),
  email text NOT NULL CHECK (email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'::text),
  message text NOT NULL CHECK (char_length(message) >= 5 AND char_length(message) <= 5000),
  status text NOT NULL DEFAULT 'new'::text CHECK (status = ANY (ARRAY['new'::text, 'in_progress'::text, 'resolved'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT contact_messages_pkey PRIMARY KEY (id),
  CONSTRAINT contact_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
