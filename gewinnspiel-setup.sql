-- Pala-Stand Gewinnspiel. Tipps bleiben privat; öffentlich lesbar sind nur Gewinner.
create table if not exists public.pala_contest(id boolean primary key default true check(id),active boolean not null default false,stopped_at timestamptz,final_total bigint);
insert into public.pala_contest(id) values(true) on conflict(id) do nothing;
create table if not exists public.pala_contest_entries(id bigint generated always as identity primary key,name text not null check(char_length(name) between 1 and 60),guess integer not null check(guess between 0 and 1000000),pancake_name text not null check(char_length(pancake_name) between 1 and 60),ingredients text not null check(char_length(ingredients) between 1 and 240),created_at timestamptz not null default now(),is_winner boolean not null default false);
alter table public.pala_contest enable row level security;
alter table public.pala_contest_entries enable row level security;
drop policy if exists contest_status_public on public.pala_contest;
create policy contest_status_public on public.pala_contest for select to anon,authenticated using(true);
drop policy if exists contest_admin_read on public.pala_contest_entries;
create policy contest_admin_read on public.pala_contest_entries for select to authenticated using(true);
drop policy if exists contest_winners_public on public.pala_contest_entries;
create policy contest_winners_public on public.pala_contest_entries for select to anon using(is_winner=true);
grant select on public.pala_contest,public.pala_contest_entries to anon,authenticated;
revoke insert,update,delete on public.pala_contest,public.pala_contest_entries from anon,authenticated;
create or replace function public.submit_pala_guess(p_name text,p_guess integer,p_pancake_name text,p_ingredients text) returns void language plpgsql security definer set search_path='' as $$
begin
 if not exists(select 1 from public.pala_contest where id=true and active) then raise exception 'Gewinnspiel geschlossen'; end if;
 if char_length(trim(p_name)) not between 1 and 60 or char_length(trim(p_pancake_name)) not between 1 and 60 or char_length(trim(p_ingredients)) not between 1 and 240 or p_guess not between 0 and 1000000 then raise exception 'Bitte alle Felder korrekt ausfuellen'; end if;
 insert into public.pala_contest_entries(name,guess,pancake_name,ingredients) values(trim(p_name),p_guess,trim(p_pancake_name),trim(p_ingredients));
end; $$;
create or replace function public.start_pala_contest() returns void language plpgsql security definer set search_path='' as $$
begin
 if auth.uid() is null then raise exception 'Admin-Anmeldung erforderlich'; end if;
 delete from public.pala_contest_entries where true;
 update public.pala_contest set active=true,stopped_at=null,final_total=null where id=true;
end; $$;
create or replace function public.stop_pala_contest() returns bigint language plpgsql security definer set search_path='' as $$
declare actual bigint;
begin
 if auth.uid() is null then raise exception 'Admin-Anmeldung erforderlich'; end if;
 select coalesce(sum(total),0) into actual from public.sales_counters where id in ('marille','erdbeere','nutella','himbeere','powidl');
 update public.pala_contest_entries set is_winner=false where true;
 if exists(select 1 from public.pala_contest_entries) then
  update public.pala_contest_entries set is_winner=true where true and abs(guess::bigint-actual)=(select min(abs(guess::bigint-actual)) from public.pala_contest_entries);
 end if;
 update public.pala_contest set active=false,stopped_at=now(),final_total=actual where id=true;
 return actual;
end; $$;
revoke all on function public.submit_pala_guess(text,integer,text,text) from public;
revoke all on function public.start_pala_contest() from public;
revoke all on function public.stop_pala_contest() from public;
grant execute on function public.submit_pala_guess(text,integer,text,text) to anon,authenticated;
grant execute on function public.start_pala_contest() to authenticated;
grant execute on function public.stop_pala_contest() to authenticated;

-- Oeffentliche, auf Gewinner beschraenkte Ansicht fuer die Zaehlseite.
-- Die Ansicht gibt ausschliesslich Gewinnernamen und deren Palatschinken-Daten frei.
create or replace view public.pala_contest_winners as
 select id, name, pancake_name, ingredients
 from public.pala_contest_entries
 where is_winner = true;
grant select on public.pala_contest_winners to anon, authenticated;

notify pgrst,'reload schema';
