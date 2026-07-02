# Home Assistant Config

Versionierte Kopie der YAML-Dateien aus dem `/config`-Ordner deiner Home-Assistant-Instanz
(`configuration.yaml`, `automations.yaml`, `scripts.yaml`, `scenes.yaml`, ...).

Push nach `main` kopiert diese Dateien automatisch auf die Instanz und lädt sie neu
(siehe [.github/workflows/deploy-ha-config.yml](../.github/workflows/deploy-ha-config.yml)).

## Was absichtlich NICHT hier reingehört

- `secrets.yaml` - enthält Zugangsdaten, das Repo ist öffentlich.
- `.storage/` - über die UI verwaltete Helper/Integrationen/Tokens, kein YAML.
- `custom_components/`, `www/`, `blueprints/`, die Datenbank sowie alles andere,
  was nicht explizit hier abgelegt wird - der Deploy-Schritt kopiert nur, was in
  diesem Ordner liegt, und löscht nichts auf der Instanz, das hier fehlt.

## Erstbefüllung

Dieser Ordner ist aktuell leer. Kopiere deine bestehenden YAML-Dateien einmalig hier rein
(z.B. über die "Studio Code Server"/"File editor"-App oder Samba), committe sie, und push
nach `main`.
