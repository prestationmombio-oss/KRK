# KRK Multi-Services — Boutique PWA
1. Supabase : créer un projet → SQL Editor → coller `supabase.sql` → Run.
2. Auth > Providers > Email : désactiver "Confirm email" (plus simple pour vos clients).
3. Éditer `config.js` : URL + clé "anon public" (Project Settings > API).
4. S'inscrire sur le site, puis exécuter dans SQL Editor la dernière requête du fichier SQL (passer votre compte en admin).
5. Netlify : glisser-déposer tout le dossier (ou connecter le dépôt GitHub). Aucun build requis.
