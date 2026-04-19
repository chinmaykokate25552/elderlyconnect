
CREATE TABLE IF NOT EXISTS public.profiles (
  id              uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name       text,
  email           text,
  phone           text,
  city            text,
  college         text,
  bio             text,
  role            text NOT NULL DEFAULT 'elder' CHECK (role IN ('elder','helper','admin')),
  is_verified     boolean DEFAULT false,
  rating          numeric(3,1) DEFAULT 0,
  tasks_completed int DEFAULT 0,
  created_at      timestamptz DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;


DROP POLICY IF EXISTS "Enable all read access" ON public.profiles;
DROP POLICY IF EXISTS "Allow insert during signup" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can delete profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;


CREATE POLICY "Enable all read access" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Allow insert during signup" ON public.profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admins can delete profiles" ON public.profiles FOR DELETE USING (auth.uid() = id OR role = 'admin');


CREATE TABLE IF NOT EXISTS public.tasks (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  elder_id        uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  elder_name      text,
  category        text NOT NULL,
  title           text NOT NULL,
  description     text,
  budget          int NOT NULL,
  urgency         text DEFAULT 'flexible' CHECK (urgency IN ('flexible','today','urgent')),
  location        text,
  status          text DEFAULT 'open' CHECK (status IN ('open','in_progress','completed','cancelled')),
  assigned_helper uuid REFERENCES public.profiles(id),
  created_at      timestamptz DEFAULT now()
);

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;


DROP POLICY IF EXISTS "Anyone can view tasks" ON public.tasks;
DROP POLICY IF EXISTS "Elders can create tasks" ON public.tasks;
DROP POLICY IF EXISTS "Elder or admin can update tasks" ON public.tasks;
DROP POLICY IF EXISTS "Elder or admin can delete tasks" ON public.tasks;


CREATE POLICY "Anyone can view tasks" ON public.tasks FOR SELECT USING (true);
CREATE POLICY "Elders can create tasks" ON public.tasks FOR INSERT WITH CHECK (auth.uid() = elder_id);
CREATE POLICY "Elder or admin can update tasks" ON public.tasks 
  FOR UPDATE USING (auth.uid() = elder_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));
CREATE POLICY "Elder or admin can delete tasks" ON public.tasks 
  FOR DELETE USING (auth.uid() = elder_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE TABLE IF NOT EXISTS public.applications (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id     uuid REFERENCES public.tasks(id) ON DELETE CASCADE,
  helper_id   uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  helper_name text,
  status      text DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected')),
  applied_at  timestamptz DEFAULT now(),
  UNIQUE(task_id, helper_id)
);

ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;


DROP POLICY IF EXISTS "Anyone can view applications" ON public.applications;
DROP POLICY IF EXISTS "Helpers can apply" ON public.applications;
DROP POLICY IF EXISTS "Elder or admin can update application status" ON public.applications;

CREATE POLICY "Anyone can view applications" ON public.applications FOR SELECT USING (true);
CREATE POLICY "Helpers can apply" ON public.applications FOR INSERT WITH CHECK (auth.uid() = helper_id);
CREATE POLICY "Elder or admin can update application status" ON public.applications 
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.tasks WHERE id = task_id AND elder_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );
