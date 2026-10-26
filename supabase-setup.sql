-- Im Supabase Dashboard unter SQL Editor ausführen.
create table if not exists public.sales (
  id integer primary key check (id = 1),
  total bigint not null default 0 check (total >= 0),
  updated_at timestamptz
);

insert into public.sales (id, total, updated_at)
values (1, 0, null)
on conflict (id) do nothing;

alter table public.sales enable row level security;

drop policy if exists "Sales counter is publicly readable" on public.sales;
create policy "Sales counter is publicly readable"
on public.sales for select
to anon, authenticated
using (true);

create or replace function public.increment_sales()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  update public.sales
  set total = total + 1,
      updated_at = now()
  where id = 1;

  if not found then
    raise exception 'Sales counter row is missing';
  end if;
end;
$$;

revoke all on function public.increment_sales() from public;
grant execute on function public.increment_sales() to authenticated;
grant select on public.sales to anon, authenticated;
revoke insert, update, delete on public.sales from anon, authenticated;

 
-- Weitere Admin-Aktionen: einmalig mit diesem Setup-Skript einrichten.
create or replace function public.decrement_sales()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  update public.sales
  set total = total - 1,
      updated_at = now()
  where id = 1 and total > 0;

  if not found then
    -- Bei 0 bleibt der Zähler unverändert und kann nicht negativ werden.
    if not exists (select 1 from public.sales where id = 1) then
      raise exception 'Sales counter row is missing';
    end if;
  end if;
end;
$$;

create or replace function public.reset_sales()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  update public.sales
  set total = 0,
      updated_at = now()
  where id = 1;

  if not found then
    raise exception 'Sales counter row is missing';
  end if;
end;
$$;

revoke all on function public.decrement_sales() from public;
revoke all on function public.reset_sales() from public;
grant execute on function public.decrement_sales() to authenticated;
grant execute on function public.reset_sales() to authenticated;
