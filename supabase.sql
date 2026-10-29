-- KRK Multi-Services : à exécuter dans Supabase > SQL Editor
create table profiles(id uuid primary key references auth.users on delete cascade, full_name text, phone text, role text not null default 'client');
create table products(id uuid primary key default gen_random_uuid(), name text not null, category text default 'Ordinateurs portables', description text, price int not null, old_price int, stock int default 10, image_url text, active boolean default true, created_at timestamptz default now());
create table zones(id uuid primary key default gen_random_uuid(), name text not null, fee int not null default 0);
create table orders(id uuid primary key default gen_random_uuid(), user_id uuid references auth.users, name text, phone text, address text, zone text, fee int default 0, items jsonb, total int, method text, pay_ref text, status text default 'nouvelle', created_at timestamptz default now());

create function handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into profiles(id,full_name,phone) values(new.id,new.raw_user_meta_data->>'full_name',new.raw_user_meta_data->>'phone'); return new; end $$;
create trigger on_signup after insert on auth.users for each row execute function handle_new_user();

create function is_admin() returns boolean language sql security definer set search_path=public stable as $$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;

alter table profiles enable row level security; alter table products enable row level security; alter table zones enable row level security; alter table orders enable row level security;
create policy "profil lecture" on profiles for select using (id=auth.uid() or is_admin());
create policy "profil maj" on profiles for update using (id=auth.uid()) with check (id=auth.uid() and role='client');
create policy "produits lecture" on products for select using (active or is_admin());
create policy "produits admin" on products for all using (is_admin()) with check (is_admin());
create policy "zones lecture" on zones for select using (true);
create policy "zones admin" on zones for all using (is_admin()) with check (is_admin());
create policy "commande creation" on orders for insert with check (user_id=auth.uid());
create policy "commande lecture" on orders for select using (user_id=auth.uid() or is_admin());
create policy "commande admin" on orders for update using (is_admin());

insert into storage.buckets(id,name,public) values('products','products',true) on conflict do nothing;
create policy "images publiques" on storage.objects for select using (bucket_id='products');
create policy "images admin" on storage.objects for all using (bucket_id='products' and is_admin()) with check (bucket_id='products' and is_admin());

insert into zones(name,fee) values('Bingerville',0),('Abidjan (autres communes)',2000),('Intérieur du pays',5000);
insert into products(name,category,description,price,stock,image_url) values
('Dell Latitude 5420','Ordinateurs portables','Core i5 11e gén. · 16 Go RAM · SSD 512 Go · Écran 14" · Pavé numérique · Windows + Office installés',240000,10,'img/dell5420.jpg'),
('Ordinateur de bureau Dell','Ordinateurs de bureau','Core i5 · 8 Go RAM · SSD 512 Go · Écran HD · Windows 10 ou supérieur · Clavier + souris',175000,10,'img/bureau.jpg'),
('Ordinateur portable HP','Ordinateurs portables','Portable professionnel HP sous Windows 11. Produit original, garantie constructeur. Prix sur demande.',0,5,'img/portable.jpg'),
('Cartes PVC personnalisées (x100)','Cartes PVC','Impression HD recto-verso : identité pro, VIP, accès, membre, fidélité. 1 000 F/carte pour 100.',100000,100,'img/cartes.jpg');

-- Après votre inscription sur le site, vous passer admin :
-- update profiles set role='admin' where id=(select id from auth.users where email='VOTRE_EMAIL');
