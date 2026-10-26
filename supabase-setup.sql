-- Palatschinken-Stand: getrennte, gemeinsam gespeicherte Zähler.
-- Dieses Skript kann mehrfach ausgeführt werden. Bestehende Tabelle public.sales bleibt unverändert.

create table if not exists public.sales_counters (
  id text primary key check (id in ('marille', 'erdbeere', 'nutella', 'himbeere', 'powidl', 'kaffee')),
  label text not null,
  total bigint not null default 0 check (total >= 0),
  updated_at timestamptz
);

insert into public.sales_counters (id, label, total, updated_at) values
  ('marille', 'Marille', 0, null),
  ('erdbeere', 'Erdbeere', 0, null),
  ('nutella', 'Nutella', 0, null),
  ('himbeere', 'Himbeere', 0, null),
  ('powidl', 'Powidl', 0, null),
  ('kaffee', 'Kaffee', 0, null)
on conflict (id) do nothing;

-- Falls die frühere Kategorie "Käfer" bereits angelegt wurde, Daten sicher zu "Kaffee" migrieren.
update public.sales_counters
set id = 'kaffee', label = 'Kaffee'
where id = 'kaefer'
  and not exists (select 1 from public.sales_counters where id = 'kaffee');

alter table public.sales_counters enable row level security;

drop policy if exists "Sales counters are publicly readable" on public.sales_counters;
create policy "Sales counters are publicly readable"
on public.sales_counters for select
to anon, authenticated
using (true);

grant select on public.sales_counters to anon, authenticated;
revoke insert, update, delete on public.sales_counters from anon, authenticated;

create or replace function public.increment_sales_counter(p_counter_id text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  update public.sales_counters
  set total = total + 1, updated_at = now()
  where id = p_counter_id;
  if not found then raise exception 'Unknown sales counter'; end if;
end;
$$;

create or replace function public.decrement_sales_counter(p_counter_id text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  update public.sales_counters
  set total = total - 1, updated_at = now()
  where id = p_counter_id and total > 0;
  if not found and not exists (select 1 from public.sales_counters where id = p_counter_id) then
    raise exception 'Unknown sales counter';
  end if;
end;
$$;

create or replace function public.reset_sales_counter(p_counter_id text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  update public.sales_counters
  set total = 0, updated_at = now()
  where id = p_counter_id;
  if not found then raise exception 'Unknown sales counter'; end if;
end;
$$;

revoke all on function public.increment_sales_counter(text) from public;
revoke all on function public.decrement_sales_counter(text) from public;
revoke all on function public.reset_sales_counter(text) from public;
grant execute on function public.increment_sales_counter(text) to authenticated;
grant execute on function public.decrement_sales_counter(text) to authenticated;
grant execute on function public.reset_sales_counter(text) to authenticated;

-- PostgREST-Schema aktualisieren, damit die neuen RPC-Funktionen gefunden werden.
notify pgrst, 'reload schema';
