# Palatschinken-Stand

Öffentliche Verkaufsanzeige für den Palatschinken-Stand.

## Website veröffentlichen (GitHub Pages)

1. Öffne **Settings → Pages** im Repository.
2. Wähle bei **Build and deployment** die Quelle **Deploy from a branch**.
3. Wähle den Branch **main** und den Ordner **/(root)** und speichere.
4. Danach ist die Website normalerweise unter https://roms-evgym.github.io/Pala-Stand/ erreichbar.

## Verkäufe zählen

- Die öffentliche Website liest die Gesamtzahl aus `sales.json`.
- Ein Admin klickt auf **Verkauf registrieren (Admins)** und öffnet damit den GitHub-Actions-Workflow.
- In GitHub auf **Run workflow** klicken. Nach erfolgreichem Workflow wird `sales.json` automatisch um 1 erhöht.
- Wiederhole das pro verkaufter Palatschinke.

Die Zählung wird über GitHub Actions gespeichert, damit kein privater Zugriffstoken im öffentlich sichtbaren Website-Code liegt. Der Button benötigt daher zusätzlich die Bestätigung **Run workflow** in GitHub; ein einzelner Klick direkt auf einer rein statischen GitHub-Pages-Seite kann das Repository nicht sicher verändern.
