# Palatschinken-Stand – Verkaufszähler

Die öffentliche `index.html` zeigt nur den aktuellen Gesamtstand. Verkäufe können ausschließlich auf `Admin.html` nach Anmeldung mit einem Admin-Konto registriert werden.

## Website veröffentlichen (GitHub Pages)

1. Öffne **Settings → Pages** im Repository.
2. Wähle bei **Build and deployment** die Quelle **Deploy from a branch**.
3. Wähle den Branch **main** und den Ordner **/(root)** und speichere.
4. Die Website ist unter https://roms-evgym.github.io/Pala-Stand/ erreichbar.

## Einmalige Einrichtung der Datenbank (ohne GitHub Actions)

1. Ein kostenloses Projekt unter https://supabase.com erstellen.
2. Im Supabase-Dashboard den **SQL Editor** öffnen und den gesamten Inhalt von `supabase-setup.sql` ausführen.
3. Unter **Project Settings → API** die **Project URL** und den öffentlichen **anon/publishable key** kopieren und in `config.js` einsetzen. Niemals den `service_role`-Key in diese Website eintragen.
4. Unter **Authentication → Sign In / Providers** E-Mail/Passwort aktivieren.
5. Unter **Authentication → Settings** öffentliche Registrierungen/Sign-ups deaktivieren. Danach unter **Authentication → Users** für jeden Admin einen Benutzer anlegen. So kann nicht jeder Besucher selbst ein Admin-Konto erstellen.
6. Nach der Veröffentlichung GitHub Pages öffnen. Auf `Admin.html` mit einem angelegten Admin-Konto anmelden und pro Verkauf einmal den Button drücken.

Die Zahl wird in Supabase gespeichert, nicht in `sales.json`. Die Startseite zeigt sie öffentlich an; nur angemeldete Benutzer können den Zähler erhöhen. Die Website benötigt Internetzugriff auf Supabase.
