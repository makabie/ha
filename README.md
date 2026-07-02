# Home Assistant Add-on Repository

Dieses Repo ist ein Home Assistant **Add-on-Repository** mit zwei Add-ons:

- [`netdaemon/`](netdaemon) – die eigentlichen Automatisierungen, geschrieben in C# mit [NetDaemon](https://netdaemon.xyz).
- [`github-runner/`](github-runner) – ein self-hosted GitHub Actions Runner, der bei jedem Push nach `main` das NetDaemon-Add-on neu baut und neu startet (siehe [.github/workflows/deploy-netdaemon.yml](.github/workflows/deploy-netdaemon.yml)) und die HA-Config synchronisiert (siehe [.github/workflows/deploy-ha-config.yml](.github/workflows/deploy-ha-config.yml)).
- [`homeassistant/`](homeassistant) – versionierte YAML-Config (`configuration.yaml`, `automations.yaml`, ...) für den `/config`-Ordner deiner Instanz.

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

### 7. HA-Config-Versionierung einrichten
Das `github-runner`-Add-on braucht jetzt zusätzlich Schreibzugriff auf den `/config`-Ordner (`map: homeassistant_config:rw`) – dafür einmal **deinstallieren und neu installieren** (Berechtigungsänderungen werden bei einem reinen Rebuild nicht immer neu abgefragt). Danach unter Konfiguration zusätzlich `ha_token` auf denselben Long-Lived-Access-Token wie beim NetDaemon-Add-on setzen (Schritt 4).

Anschließend deine bestehenden YAML-Dateien einmalig in [`homeassistant/`](homeassistant) kopieren (siehe dortige README), committen und nach `main` pushen. Der Workflow [deploy-ha-config.yml](.github/workflows/deploy-ha-config.yml) kopiert die Dateien dann automatisch in den echten `/config`-Ordner, validiert die Config über die Home-Assistant-API und lädt sie neu – bei einer ungültigen Config wird automatisch der vorherige Stand wiederhergestellt.

⚠️ Sicherheitshinweise:
- Der Deploy-Schritt löscht nie Dateien auf der Instanz, die im Repo fehlen (kein `--delete`) – `secrets.yaml`, `.storage/`, die Datenbank etc. bleiben also unangetastet, solange sie nicht versehentlich selbst ins Repo gelangen.
- Die Reload-Services (`automation.reload`, `script.reload`, `scene.reload`, `homeassistant.reload_core_config`) decken die meisten YAML-Änderungen ab, aber **nicht alles** – neue Integrationen in `configuration.yaml` erfordern oft einen vollständigen Neustart, den dieser Workflow bewusst nicht automatisch macht.
- Der genaue Mount-Pfad für `homeassistant_config` (`/homeassistant` vs. `/config`) konnte ich nicht gegen eure Instanz testen – der Workflow probiert beide und bricht mit einer klaren Fehlermeldung ab, falls keiner passt.

## Laufende Entwicklung

Neue Automatisierungen kommen als eigene `.cs`-Dateien unter `netdaemon/apps/` (siehe die mitgelieferten Beispiele `HelloWorld`, `LightOnMovement`, `Scheduling`). Push nach `main` deployt automatisch.

YAML-Config-Änderungen kommen als Dateien unter `homeassistant/` und deployen ebenfalls automatisch nach Push auf `main`.
