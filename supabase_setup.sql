-- Create a table for user profiles
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Create RLS policies for profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows users to view their own profile
CREATE POLICY "Users can view their own profile" 
  ON public.profiles 
  FOR SELECT 
  USING (auth.uid() = id);

-- Create a policy that allows users to update their own profile
CREATE POLICY "Users can update their own profile" 
  ON public.profiles 
  FOR UPDATE 
  USING (auth.uid() = id);

-- Create a secure function to handle new user signups
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url, email)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url',
    new.email
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to call the function when a new user is created
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create a table for user progress
CREATE TABLE IF NOT EXISTS public.user_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  topic_id TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  score INTEGER DEFAULT 0,
  last_accessed TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Add progress_percentage column to user_progress table
ALTER TABLE public.user_progress 
ADD COLUMN IF NOT EXISTS progress_percentage DOUBLE PRECISION DEFAULT 0;

-- Enable RLS for user_progress
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows users to view their own progress
CREATE POLICY "Users can view their own progress" 
  ON public.user_progress 
  FOR SELECT 
  USING (auth.uid() = user_id);

-- Create a policy that allows users to update their own progress
CREATE POLICY "Users can update their own progress" 
  ON public.user_progress 
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- Create a policy that allows users to insert their own progress
CREATE POLICY "Users can insert their own progress" 
  ON public.user_progress 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Create a table for user achievements
CREATE TABLE IF NOT EXISTS public.user_achievements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  achievement_id TEXT NOT NULL,
  unlocked_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Enable RLS for user_achievements
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows users to view their own achievements
CREATE POLICY "Users can view their own achievements" 
  ON public.user_achievements 
  FOR SELECT 
  USING (auth.uid() = user_id);

-- Create a policy that allows users to insert their own achievements
CREATE POLICY "Users can insert their own achievements" 
  ON public.user_achievements 
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Create a table for quizzes
CREATE TABLE IF NOT EXISTS public.quizzes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    topic TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    question_count INTEGER NOT NULL,
    score INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Create a table for quiz questions
CREATE TABLE IF NOT EXISTS public.quiz_questions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE NOT NULL,
    question TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_answer_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Enable RLS for quizzes
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;

-- Enable RLS for quiz questions
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;

-- Create policies for quizzes
CREATE POLICY "Users can view their own quizzes"
    ON public.quizzes
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own quizzes"
    ON public.quizzes
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quizzes"
    ON public.quizzes
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Create policies for quiz questions
CREATE POLICY "Users can view questions of their quizzes"
    ON public.quiz_questions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.quizzes
            WHERE quizzes.id = quiz_questions.quiz_id
            AND quizzes.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert questions for their quizzes"
    ON public.quiz_questions
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.quizzes
            WHERE quizzes.id = quiz_questions.quiz_id
            AND quizzes.user_id = auth.uid()
        )
    );