# Home Assistant Add-on Repository

Dieses Repo ist ein Home Assistant **Add-on-Repository** mit zwei Add-ons:

- [`netdaemon/`](netdaemon) – die eigentlichen Automatisierungen, geschrieben in C# mit [NetDaemon](https://netdaemon.xyz).
- [`github-runner/`](github-runner) – ein self-hosted GitHub Actions Runner, der bei jedem Push nach `main` das NetDaemon-Add-on neu baut und neu startet (siehe [.github/workflows/deploy-netdaemon.yml](.github/workflows/deploy-netdaemon.yml)).

## Einmalige manuelle Einrichtung

Diese Schritte lassen sich nicht automatisieren, da sie einmalig in deiner HA-Oberfläche bzw. auf GitHub passieren müssen.

### 1. Repo als Add-on-Repository hinzufügen
In Home Assistant: **Einstellungen → Add-ons → Add-on Store → ⋮ (oben rechts) → Repositories** → URL dieses Repos einfügen (`https://github.com/makabie/ha`).

### 2. GitHub Personal Access Token erstellen
Für den Runner brauchst du ein Fine-grained PAT mit **Administration: Read & write** auf dieses Repo (damit der Runner sich selbst registrieren/deregistrieren kann).

### 3. GitHub-Runner-Add-on installieren
Im Add-on Store erscheint jetzt "GitHub Actions Runner". Installieren, dann unter Konfiguration setzen:
- `repo`: `makabie/ha`
- `github_pat`: das PAT aus Schritt 2
- `runner_name`: z.B. `homeassistant`

Danach starten. Unter GitHub → Repo → **Settings → Actions → Runners** sollte der Runner als "Idle" erscheinen.

### 4. Long-Lived Access Token erstellen
In Home Assistant: **Profil (unten links) → Sicherheit → Long-Lived Access Tokens → Token erstellen**. Der `SUPERVISOR_TOKEN` des Add-ons ist nur gegenüber der Supervisor-API gültig, nicht gegenüber Home Assistant Core direkt - NetDaemon braucht deshalb einen normalen Token.

### 5. NetDaemon-Add-on installieren
Ebenfalls im Add-on Store: "NetDaemon" installieren, unter Konfiguration `ha_token` auf den Token aus Schritt 4 setzen, dann starten. In den Add-on-Logs prüfen, ob die Verbindung zu Home Assistant erfolgreich aufgebaut wird (WebSocket-Connect zu `homeassistant:8123`, kein "Unauthorized").

### 6. Pipeline testen
Eine Kleinigkeit in `netdaemon/apps/**` ändern, committen, nach `main` pushen. Der Workflow [deploy-netdaemon.yml](.github/workflows/deploy-netdaemon.yml) sollte über den self-hosted Runner laufen und das NetDaemon-Add-on neu bauen + neu starten.

## Laufende Entwicklung

Neue Automatisierungen kommen als eigene `.cs`-Dateien unter `netdaemon/apps/` (siehe die mitgelieferten Beispiele `HelloWorld`, `LightOnMovement`, `Scheduling`). Push nach `main` deployt automatisch.
