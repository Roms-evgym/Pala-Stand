# Palatschinken-Stand – Verkaufszähler

Die öffentliche `index.html` zeigt die Gesamtzahl sowie getrennte Verkaufszahlen für Marille, Erdbeere, Nutella, Himbeere, Powidl und „Kaffee · eigene Kategorie“. Nur angemeldete Benutzer können Zähler auf `Admin.html` ändern.

## Website veröffentlichen (GitHub Pages)

1. Öffne **Settings → Pages** im Repository.
2. Wähle bei **Build and deployment** die Quelle **Deploy from a branch**.
3. Wähle den Branch **main** und den Ordner **/(root)** und speichere.
4. Die Website ist unter https://roms-evgym.github.io/Pala-Stand/ erreichbar.

## Supabase einrichten (ohne GitHub Actions)

1. Öffne dein Supabase-Projekt und den **SQL Editor**.
2. Führe den gesamten Inhalt von `supabase-setup.sql` aus. Das Skript erstellt die Tabelle `sales_counters`, sechs Kategorien und geschützte RPC-Funktionen. Die bisherige Tabelle `sales` bleibt bestehen.
3. `config.js` muss die Projekt-URL und den öffentlichen Publishable Key enthalten. Niemals den `service_role`- oder Secret-Key in die Website eintragen.
4. Unter **Authentication → Sign In / Providers** E-Mail/Passwort aktivieren.
5. Öffentliche Registrierungen deaktivieren und Admin-Konten unter **Authentication → Users** manuell anlegen.
6. Öffne `Admin.html`, melde dich an und verwende pro Sorte die Buttons **+1**, **−1** und **Zurücksetzen**.

Die Zähler werden zentral in Supabase gespeichert. Die öffentliche Seite kann sie nur lesen und aktualisiert sich automatisch. GitHub Actions werden nicht verwendet.

„Kaffee“ ist derzeit als eigene, separat gezählte Kategorie eingerichtet; die genaue Bedeutung kann später im Label geändert werden.
