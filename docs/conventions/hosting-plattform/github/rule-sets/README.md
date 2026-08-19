# Hosting-Plattform: GitHub — Rule-Sets
[INTENT: REFERENZ]

## Kanonische Quelle

Die GitHub-Rule-Sets für die Organisation `t33n-software` werden einmalig und
zentral im Repository
[`git-governance`](https://github.com/t33n-software/git-governance) unter
`rulesets/github/` definiert und verwaltet. Dieses Repository ist die
kanonische Quelle der Wahrheit für die JSON-Definitionen: Es erklärt die
Architektur, setzt die Definitionen und liefert die versionierten,
importierbaren Artefakte.

Eine lokale Kopie, Neudefinition oder Abweichung in diesem Repository ist ein
Anti-Pattern und verboten (Redundanz- und Drift-Verbot). Erlaubt sind
ausschließlich benannte, auditierbare Repository-Ausnahmen, die restriktiver
als die Organisations-Grundlage sind, niemals schwächer.

## Verwendete Familie

Dieses Projekt (`developer-platform-infrastructure`) verwendet die Familie
**`quality-gates=linux-only`**:

- Die Quality Gates laufen ausschließlich für **Linux**.
- Architektonische Begründung: Dieses Projekt liefert organisations-agnostische
  OpenTofu-Foundation-Areas sowie reine Linux-/CI-/CD-Artefakte; die
  Gate-Binaries der Go-Toolchain werden ausschließlich für Linux/AMD64 gebaut
  und verifiziert. Es existieren keine betriebssystemspezifischen Binaries,
  daher ergeben Windows-/macOS-Gates keinen Kontrollwert.

## Gebundene Rule-Sets

| Rule-Set | Klasse |
|---|---|
| `push-protections: secret artifact boundary` | klassenlos (private/interne Sichtbarkeit) |
| `branch-governance: ticket working branches` | klassenlos (`~ALL`) |
| `branch-governance: develop shared line (quality-gates=linux-only)` | linux-only |
| `branch-governance: main shared line (quality-gates=linux-only)` | linux-only |
| `branch-governance: release shared lines (quality-gates=linux-only)` | linux-only |
| `branch-governance: support shared lines (quality-gates=linux-only)` | linux-only |
| `tag-governance: release version tags` | klassenlos (`~ALL`, Ziel `tag`, `refs/tags/v*`) |
| `tag-governance: tag namespace floor` | klassenlos (`~ALL`, Ziel `tag`, `refs/tags/*` ohne `v*`) |

Die beiden Tag-Rule-Sets sind klassenlos, weil die Tag-Governance
klassenunabhängig ist: Der `v*`-Namespace ist an die Release-Automation-
Identität gebunden (Erstellung, Verschiebung und Löschung nur über den
Bypass-Actor), und der Namespace-Floor verhindert neue ungovernete
Tag-Namespaces flächenweit (Erstellung und Verschiebung nur über die
benannte Break-Glass-Rolle; Löschung bleibt zum Aufräumen möglich).

## Verwaltung

- Verwaltungsebene: die **Organisation** (`t33n-software`), niemals die
  einzelne Repository-Ebene.
- Klassenmitgliedschaft dieses Repositorys: Custom Property
  `quality-gates=linux-only`.
- Änderungen an den Rule-Sets erfolgen ausschließlich im kanonischen
  Repository und werden danach auf Organisationsebene re-importiert
  (Organisation Settings → Repository → Rulesets).
- Die Projektion der gepinnten Rule-Set-Artefakte in die Organisation läuft
  über die reviewte IaC-Lane: Die Instanz pinnt Version und Digest des
  kanonischen Bundles und projiziert die Payloads über die wertefreie
  Foundation-Area `hosting-platforms/github/rulesets/` dieses Cores.
