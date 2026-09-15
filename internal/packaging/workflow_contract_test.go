package packaging

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"sort"
	"strings"
	"testing"
)

var foundationAreas = []string{
	"organization",
	"folders",
	"identity-baseline",
	"kms",
	"logging",
	"network",
	"policy",
	"state-home",
	"hosting-platforms/github/custom-properties",
	"hosting-platforms/github/rulesets",
}

var foundationAreaProviderPins = map[string][]string{
	"organization":      {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"folders":           {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"identity-baseline": {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"kms":               {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"logging":           {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"network":           {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"policy":            {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"state-home":        {`source = "hashicorp/google"`, `version = "= 7.44.0"`},
	"hosting-platforms/github/custom-properties": {`source = "integrations/github"`, `version = "= 6.13.0"`},
	"hosting-platforms/github/rulesets":          {`source = "integrations/github"`, `version = "= 6.13.0"`},
}

// bindingManifest mirrors the tenant binding manifest (repo-bindings/v1) for
// the self-consistency proofs of the canonical adoption. The home-side proof
// against the canonical masters is owned by the verify-canonical tool; these
// tests bind the tenant files to the manifest.
type bindingManifest struct {
	Home struct {
		Repository string `json:"repository"`
		SHA        string `json:"sha"`
	} `json:"home"`
	Callers []struct {
		File   string `json:"file"`
		Master string `json:"master"`
		SHA256 string `json:"sha256"`
	} `json:"callers"`
	Files struct {
		Lefthook      fileBinding `json:"lefthook"`
		Gitattributes fileBinding `json:"gitattributes"`
		Gitignore     fileBinding `json:"gitignore"`
		Dependabot    fileBinding `json:"dependabot"`
	} `json:"files"`
	Codeowners struct {
		Path         string `json:"path"`
		DefaultOwner string `json:"defaultOwner"`
	} `json:"codeowners"`
}

type fileBinding struct {
	Path   string `json:"path"`
	SHA256 string `json:"sha256"`
}

func readBindingManifest(t *testing.T) bindingManifest {
	t.Helper()
	var manifest bindingManifest
	if err := json.Unmarshal([]byte(readRepositoryFile(t, "repo-bindings.json")), &manifest); err != nil {
		t.Fatalf("repo-bindings.json is not valid JSON: %v", err)
	}
	if manifest.Home.Repository != "t33n-software/repository-governance" {
		t.Fatalf("the manifest binds home %q", manifest.Home.Repository)
	}
	return manifest
}

// hashRepositoryFile hashes the LF-normalized repository file; the canonical
// .gitattributes makes the checkout LF, and the normalization keeps the
// derivation tolerant as the second line of defense.
func hashRepositoryFile(t *testing.T, path string) string {
	t.Helper()
	normalized := strings.ReplaceAll(readRepositoryFile(t, path), "\r\n", "\n")
	sum := sha256.Sum256([]byte(normalized))
	return hex.EncodeToString(sum[:])
}

func TestCanonicalCallersMatchTheBindingManifest(t *testing.T) {
	manifest := readBindingManifest(t)
	want := map[string]string{
		".github/workflows/ci.yml":                    "hosting-platforms/github/workflows/callers/go/ci.yml",
		".github/workflows/codeql.yml":                "hosting-platforms/github/workflows/callers/go/codeql.yml",
		".github/workflows/dependency-review.yml":     "hosting-platforms/github/workflows/callers/go/dependency-review.yml",
		".github/workflows/canonical-conformance.yml": "hosting-platforms/github/workflows/callers/go/canonical-conformance.yml",
	}
	if len(manifest.Callers) != len(want) {
		t.Fatalf("the manifest carries %d callers, want %d", len(manifest.Callers), len(want))
	}
	for _, caller := range manifest.Callers {
		master, found := want[caller.File]
		if !found {
			t.Fatalf("the manifest carries an unexpected caller %q", caller.File)
		}
		if caller.Master != master {
			t.Fatalf("caller %q binds master %q, want %q", caller.File, caller.Master, master)
		}
		if hash := hashRepositoryFile(t, caller.File); hash != caller.SHA256 {
			t.Fatalf("the tenant caller %s hashes to %s, want the bound %s", caller.File, hash, caller.SHA256)
		}
		content := readRepositoryFile(t, caller.File)
		if !strings.Contains(content, "uses: "+manifest.Home.Repository+"/.github/workflows/reusable-") {
			t.Fatalf("the tenant caller %s does not reference a home payload", caller.File)
		}
		if !strings.Contains(content, "@"+manifest.Home.SHA) {
			t.Fatalf("the tenant caller %s does not pin the bound home SHA", caller.File)
		}
		if !strings.Contains(content, `branches: [main, develop, "release/**", "support/**"]`) {
			t.Fatalf("the tenant caller %s does not cover every shared line", caller.File)
		}
	}
}

func TestCanonicalFileFamilyMatchesTheBindingManifest(t *testing.T) {
	manifest := readBindingManifest(t)
	for _, topic := range []fileBinding{
		manifest.Files.Lefthook,
		manifest.Files.Gitattributes,
		manifest.Files.Dependabot,
	} {
		if hash := hashRepositoryFile(t, topic.Path); hash != topic.SHA256 {
			t.Fatalf("the canonical file %s hashes to %s, want the bound %s", topic.Path, hash, topic.SHA256)
		}
	}
	// The gitignore topic is prefix-mode in the home verifier: the canonical
	// core is a verbatim prefix and project additions live below the mark.
	gitignore := readRepositoryFile(t, manifest.Files.Gitignore.Path)
	canonicalCore := "# Local build and test outputs.\n/.build/\n/dist/\n/coverage/\n/.cache/\n*.coverprofile\n*.test\n*.out\n*.cov\n\n# -- project additions below this line --\n"
	if !strings.HasPrefix(gitignore, canonicalCore) {
		t.Fatal("the gitignore does not carry the canonical core as a verbatim prefix with the project-block mark")
	}
	for _, preserved := range []string{
		"**/.terraform/",
		"*.tfstate",
		"*.tfvars",
		"*/.terraform.lock.hcl",
		"hosting-platforms/**/.terraform.lock.hcl",
	} {
		if !strings.Contains(gitignore, preserved) {
			t.Fatalf("the gitignore does not preserve the project pattern %q below the mark", preserved)
		}
	}

	codeowners := readRepositoryFile(t, manifest.Codeowners.Path)
	if !strings.Contains(codeowners, "* "+manifest.Codeowners.DefaultOwner) {
		t.Fatalf("the ownership file does not bind the default owner %q", manifest.Codeowners.DefaultOwner)
	}
}

func TestConformanceWorkflowBindsTheVerifier(t *testing.T) {
	manifest := readBindingManifest(t)
	content := readRepositoryFile(t, ".github/workflows/canonical-conformance.yml")
	for _, required := range []string{
		"permissions: {}",
		"name: Canonical conformance",
		"uses: " + manifest.Home.Repository + "/.github/workflows/reusable-canonical-conformance.yml@" + manifest.Home.SHA,
		`branches: [main, develop, "release/**", "support/**"]`,
	} {
		if !strings.Contains(content, required) {
			t.Fatalf("the canonical conformance workflow does not contain %q", required)
		}
	}
}

func TestCapabilityPackDeclarationBindsTheOpenTofuGates(t *testing.T) {
	quality := readRepositoryFile(t, "git-governance.quality.json")
	for _, required := range []string{
		`"schemaVersion": 4`,
		`"extends"`,
		`"opentofu@1"`,
	} {
		if !strings.Contains(quality, required) {
			t.Fatalf("git-governance.quality.json does not contain %q", required)
		}
	}

	// The pack contract in the shared-kernel registry is the single OpenTofu
	// contract; the duplicated repository-local convention document is removed.
	if _, err := os.Stat(repositoryPath("docs", "conventions", "infrastructure-as-code", "OPENTOFU-ENGINE-CONVENTION.md")); !os.IsNotExist(err) {
		t.Fatal("the duplicated OpenTofu convention document must not exist; the pack contract is the single contract")
	}

	// The canonical CI caller carries no repository-local OpenTofu setup: the
	// pack provisions the engine through its digest- and signature-bound
	// recipe in the constant provisioning seam of the payload.
	ci := readRepositoryFile(t, ".github/workflows/ci.yml")
	for _, forbidden := range []string{"setup-opentofu", "tofu_version", "OPENTOFU_ENFORCE_GPG_VALIDATION"} {
		if strings.Contains(ci, forbidden) {
			t.Fatalf("the canonical CI caller carries the repository-local OpenTofu setup %q; provisioning is pack-owned", forbidden)
		}
	}

	// The OpenTofu gates are pack-owned and run in the canonical quality lane;
	// no repo-local gate chain copy exists that could carry them.
	for _, chainCopy := range []string{"cmd/build", "cmd/check-coverage"} {
		if _, err := os.Stat(repositoryPath(filepath.FromSlash(chainCopy))); !os.IsNotExist(err) {
			t.Fatalf("the repo-local gate chain copy %s must not exist; the gates are pack-owned or canonical", chainCopy)
		}
	}
}

func TestOrganizationRulesetAdoptionHasNoLocalLegacyDefinitions(t *testing.T) {
	if _, err := os.Stat(repositoryPath("docs", "hosting-platforms")); !os.IsNotExist(err) {
		t.Fatalf("legacy ruleset location must not exist")
	}

	conventions := readRepositoryFile(t, filepath.Join("docs", "conventions", "hosting-plattform", "github", "rule-sets", "README.md"))
	for _, required := range []string{
		"git-governance",
		"quality-gates=linux-only",
		"~ALL",
	} {
		if !strings.Contains(conventions, required) {
			t.Fatalf("rule-set conventions README does not contain %q", required)
		}
	}
}

func TestGovernanceDocumentationPreservesCoreInstanceAndTenantBoundaries(t *testing.T) {
	for _, path := range []string{
		"README.md",
		"docs/architecture/ADR-0001-DEVELOPER-PLATFORM-INFRASTRUCTURE.md",
		"docs/development/VERIFICATION.md",
	} {
		content := strings.ToLower(readRepositoryFile(t, path))
		for _, required := range []string{"core", "instance", "tenant"} {
			if !strings.Contains(content, required) {
				t.Fatalf("%s does not document %q boundary", path, required)
			}
		}
	}

	adr := readRepositoryFile(t, "docs/architecture/ADR-0001-DEVELOPER-PLATFORM-INFRASTRUCTURE.md")
	for _, required := range []string{
		"never contains concrete organization",
		"never contains tenant",
		"organization",
		"folders",
		"identity-baseline",
		"kms",
		"logging",
		"network",
		"policy",
	} {
		if !strings.Contains(adr, required) {
			t.Fatalf("ADR does not contain %q", required)
		}
	}
}

func TestOrganizationNodeCoverageIsDocumented(t *testing.T) {
	documents := map[string]string{
		"ADR":                    readRepositoryFile(t, "docs/architecture/ADR-0001-DEVELOPER-PLATFORM-INFRASTRUCTURE.md"),
		"organization/README.md": readRepositoryFile(t, filepath.Join("organization", "README.md")),
	}
	for name, content := range documents {
		normalized := normalizeWhitespace(content)
		for _, required := range []string{
			"canonical standard",
			"drop out",
			"optionally possible",
			"migrated",
			"retrofitted",
		} {
			if !strings.Contains(normalized, required) {
				t.Fatalf("%s does not document the organization node contract token %q", name, required)
			}
		}
	}
}

func TestFoundationAreaLayoutIsComplete(t *testing.T) {
	areaFiles := []string{"main.tf", "variables.tf", "outputs.tf", "versions.tf", "README.md"}
	for _, area := range foundationAreas {
		for _, file := range areaFiles {
			path := repositoryPath(area, file)
			if _, err := os.Stat(path); err != nil {
				t.Fatalf("missing foundation area file %q: %v", path, err)
			}
		}
		readme := readRepositoryFile(t, filepath.Join(area, "README.md"))
		if !strings.Contains(readme, "## Boundary") {
			t.Fatalf("%s/README.md does not document its boundary", area)
		}
	}
}

func TestCoreContainsNoConcreteBindings(t *testing.T) {
	forbiddenContent := []string{
		"cybert33n",
		"t33n-software",
		"git-governance",
		"europe-west3",
		"937088974261",
		"1065293691137",
		"1007556997805",
		"346339887743",
		"01c36d",
	}
	// The governed adoption surface is exempt from the organization-coordinate
	// scan: the canonical callers and the conformance lane reference the home
	// coordinate, the binding manifest records the home pin, lefthook.yml names
	// the governed Git toolchain binary, the rule-sets conventions README names
	// the canonical organization source of truth for the GitHub rule-sets,
	// TRACEABILITY.md records this repository's own governed decisions, and the
	// license-hub onboarding values name this repository's own canonical source
	// coordinate under the digest-locked, byte-verified render contract — source
	// and tool references, not organization or tenant bindings of this core.
	governedReferenceExempt := []string{
		".github/workflows/ci.yml",
		".github/workflows/codeql.yml",
		".github/workflows/dependency-review.yml",
		".github/workflows/canonical-conformance.yml",
		"repo-bindings.json",
		"docs/conventions/hosting-plattform/github/rule-sets/README.md",
		"docs/TRACEABILITY.md",
		"lefthook.yml",
		"license.values.json",
	}
	for _, path := range repositoryFiles(t, []string{".tf", ".yml", ".yaml", ".json", ".md"}) {
		slashed := filepath.ToSlash(path)
		exempt := false
		for _, exemptPath := range governedReferenceExempt {
			if strings.HasSuffix(slashed, exemptPath) {
				exempt = true
				break
			}
		}
		if exempt {
			continue
		}
		content, err := os.ReadFile(path)
		if err != nil {
			t.Fatalf("ReadFile(%q) error = %v", path, err)
		}
		lowered := strings.ToLower(string(content))
		for _, forbidden := range forbiddenContent {
			if strings.Contains(lowered, forbidden) {
				t.Fatalf("%s contains concrete binding %q; the core never carries organization or tenant values", path, forbidden)
			}
		}
	}

	for _, path := range repositoryFiles(t, []string{".tf"}) {
		content, err := os.ReadFile(path)
		if err != nil {
			t.Fatalf("ReadFile(%q) error = %v", path, err)
		}
		for _, forbidden := range []string{"?ref=main", "?ref=develop", "latest"} {
			if strings.Contains(string(content), forbidden) {
				t.Fatalf("%s contains mutable reference %q", path, forbidden)
			}
		}
	}
}

func TestOpenTofuPinsAreExactAndConsistent(t *testing.T) {
	for _, area := range foundationAreas {
		versions := normalizeWhitespace(readRepositoryFile(t, filepath.Join(area, "versions.tf")))
		providerPins, ok := foundationAreaProviderPins[area]
		if !ok {
			t.Fatalf("no provider pin contract registered for foundation area %q", area)
		}
		for _, required := range append([]string{`required_version = "= 1.12.5"`}, providerPins...) {
			if !strings.Contains(versions, required) {
				t.Fatalf("%s/versions.tf does not contain exact pin %q", area, required)
			}
		}
		for _, forbidden := range []string{"~>", ">="} {
			if strings.Contains(versions, forbidden) {
				t.Fatalf("%s/versions.tf contains non-exact constraint %q", area, forbidden)
			}
		}
	}
}

func TestStateHomeAreaBindsTheDualFortressBirthForm(t *testing.T) {
	area := "state-home"

	versions := normalizeWhitespace(readRepositoryFile(t, filepath.Join(area, "versions.tf")))
	for _, required := range []string{
		`key_provider "gcp_kms" "main"`,
		`kms_encryption_key = var.state_encryption_key`,
		`key_length = 32`,
		`encrypted_metadata_alias = "state-encryption"`,
		`method "aes_gcm" "main"`,
		`keys = key_provider.gcp_kms.main`,
		`state { method = method.aes_gcm.main enforced = true`,
		`plan { method = method.aes_gcm.main enforced = true`,
		`remote_state_data_sources { default { method = method.aes_gcm.main`,
	} {
		if !strings.Contains(versions, required) {
			t.Fatalf("%s/versions.tf does not bind the dual fortress engine-layer form %q", area, required)
		}
	}
	// The birth form: the root carries the encryption block but no backend
	// block; the backend joins after the foundation bucket birth as a
	// reviewed change, followed by the state migration.
	if strings.Contains(versions, `backend "gcs"`) {
		t.Fatalf("%s/versions.tf carries a backend block before the foundation bucket birth; the birth form carries none", area)
	}

	main := normalizeWhitespace(readRepositoryFile(t, filepath.Join(area, "main.tf")))
	for _, required := range []string{
		`resource "google_storage_bucket" "state_homes"`,
		`for_each = var.state_homes`,
		`uniform_bucket_level_access = true`,
		`public_access_prevention = "enforced"`,
		`versioning { enabled = true }`,
		`encryption { default_kms_key_name = each.value.cmek_key_name }`,
		`resource "google_storage_bucket_iam_member" "operators"`,
		`role = "roles/storage.objectAdmin"`,
	} {
		if !strings.Contains(main, required) {
			t.Fatalf("%s/main.tf does not bind the state-home form %q", area, required)
		}
	}
	for _, forbidden := range []string{`lifecycle_rule`, `retention_policy`, `roles/storage.admin`} {
		if strings.Contains(main, forbidden) {
			t.Fatalf("%s/main.tf carries the forbidden form %q; a state bucket is the recovery root, never an archive, and the area grants exactly the object-admin role", area, forbidden)
		}
	}

	variables := normalizeWhitespace(readRepositoryFile(t, filepath.Join(area, "variables.tf")))
	for _, required := range []string{
		`variable "state_encryption_key"`,
		`variable "state_homes"`,
		`^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$`,
		`home.cmek_key_name != var.state_encryption_key`,
		`element(split("/", home.cmek_key_name), 3) == home.location`,
		`length(var.state_homes) > 0`,
		`length(distinct(`,
		`length(home.operator_members) > 0`,
	} {
		if !strings.Contains(variables, required) {
			t.Fatalf("%s/variables.tf does not bind the instance-binding form %q", area, required)
		}
	}
	// The organization instance supplies every concrete value; the core
	// never presets one.
	if strings.Contains(variables, "default") {
		t.Fatalf("%s/variables.tf carries a preset value; the organization instance supplies every concrete value", area)
	}

	readme := readRepositoryFile(t, filepath.Join(area, "README.md"))
	for _, required := range []string{"## Boundary", "dual fortress", "## Birth form", "migrate-state", "foundation"} {
		if !strings.Contains(readme, required) {
			t.Fatalf("%s/README.md does not document %q", area, required)
		}
	}
}

func TestCustomPropertiesProjectionAreaIsValueFree(t *testing.T) {
	area := filepath.Join("hosting-platforms", "github", "custom-properties")

	main := readRepositoryFile(t, filepath.Join(area, "main.tf"))
	for _, required := range []string{
		"github_organization_custom_properties",
		"github_repository_custom_property",
		"for_each = var.definitions",
		"values_editable_by",
		"depends_on",
	} {
		if !strings.Contains(main, required) {
			t.Fatalf("%s/main.tf does not contain %q", area, required)
		}
	}
	for _, forbidden := range []string{"quality-gates", "linux-only", `"full"`, "pending"} {
		if strings.Contains(main, forbidden) {
			t.Fatalf("%s/main.tf carries the concrete governance value %q; the projection module is value-free", area, forbidden)
		}
	}

	variables := readRepositoryFile(t, filepath.Join(area, "variables.tf"))
	for _, required := range []string{`variable "definitions"`, `variable "assignments"`} {
		if !strings.Contains(variables, required) {
			t.Fatalf("%s/variables.tf does not declare %q", area, required)
		}
	}

	readme := readRepositoryFile(t, filepath.Join(area, "README.md"))
	for _, required := range []string{"## Boundary", "values_editable_by", "org_actors"} {
		if !strings.Contains(readme, required) {
			t.Fatalf("%s/README.md does not document %q", area, required)
		}
	}
}

func TestRulesetsProjectionAreaIsValueFree(t *testing.T) {
	area := filepath.Join("hosting-platforms", "github", "rulesets")

	main := readRepositoryFile(t, filepath.Join(area, "main.tf"))
	for _, required := range []string{
		"github_organization_ruleset",
		"for_each = var.rulesets",
		"bypass_actors",
		"conditions",
		"ref_name",
	} {
		if !strings.Contains(main, required) {
			t.Fatalf("%s/main.tf does not contain %q", area, required)
		}
	}
	for _, forbidden := range []string{"quality-gates", "linux-only", `"full"`, "pending", "refs/tags/", "refs/heads/"} {
		if strings.Contains(main, forbidden) {
			t.Fatalf("%s/main.tf carries the concrete governance value %q; the projection module is value-free", area, forbidden)
		}
	}

	variables := readRepositoryFile(t, filepath.Join(area, "variables.tf"))
	for _, required := range []string{`variable "rulesets"`} {
		if !strings.Contains(variables, required) {
			t.Fatalf("%s/variables.tf does not declare %q", area, required)
		}
	}

	readme := readRepositoryFile(t, filepath.Join(area, "README.md"))
	for _, required := range []string{"## Boundary", "bypass", "evaluate"} {
		if !strings.Contains(readme, required) {
			t.Fatalf("%s/README.md does not document %q", area, required)
		}
	}
}

func TestModuleIdentityAndQualityContract(t *testing.T) {
	goMod := readRepositoryFile(t, "go.mod")
	for _, required := range []string{
		"module github.com/t33n-software/developer-platform-infrastructure",
		"go 1.26",
		"toolchain go1.26.6",
	} {
		if !strings.Contains(goMod, required) {
			t.Fatalf("go.mod does not contain %q", required)
		}
	}

	quality := readRepositoryFile(t, "git-governance.quality.json")
	for _, required := range []string{
		`"schemaVersion": 4`,
		`"language": "go"`,
		`"version": "1.26.6"`,
		`"extends": ["opentofu@1"]`,
		"developer-platform-infrastructure-source-quality",
	} {
		if !strings.Contains(quality, required) {
			t.Fatalf("git-governance.quality.json does not contain %q", required)
		}
	}

	var qualityConfig struct {
		Gates []struct {
			Name    string   `json:"name"`
			Command string   `json:"command"`
			Args    []string `json:"args"`
		} `json:"gates"`
	}
	if err := json.Unmarshal([]byte(quality), &qualityConfig); err != nil {
		t.Fatalf("git-governance.quality.json is not valid JSON: %v", err)
	}
	if len(qualityConfig.Gates) != 1 {
		t.Fatalf("git-governance.quality.json carries %d gates, want exactly the canonical gate chain", len(qualityConfig.Gates))
	}
	if qualityConfig.Gates[0].Name != "developer-platform-infrastructure-source-quality" ||
		qualityConfig.Gates[0].Command != "go" ||
		!slices.Equal(qualityConfig.Gates[0].Args, []string{"tool", "-modfile", "tools/go.mod", "quality-gate"}) {
		t.Fatal("the gate does not invoke the canonical gate chain through the tooling module pin")
	}
	for _, forbidden := range []string{`"./cmd/build"`, `"./cmd/check-coverage"`, `"defaults"`, `"project"`} {
		if strings.Contains(quality, forbidden) {
			t.Fatalf("git-governance.quality.json still contains %s", forbidden)
		}
	}
	for _, chainCopy := range []string{"cmd/build", "cmd/check-coverage"} {
		if _, err := os.Stat(repositoryPath(filepath.FromSlash(chainCopy))); !os.IsNotExist(err) {
			t.Fatalf("the repo-local gate chain copy %s must not exist", chainCopy)
		}
	}

	lefthook := readRepositoryFile(t, "lefthook.yml")
	if !strings.Contains(lefthook, "git-governance --interactive never validate pre-push --remote") {
		t.Fatal("lefthook.yml does not bind the canonical pre-push validation")
	}
}

func TestGoToolchainAndBuildToolingContract(t *testing.T) {
	toolsMod := readRepositoryFile(t, filepath.Join("tools", "go.mod"))
	for _, required := range []string{
		"module github.com/t33n-software/developer-platform-infrastructure/tools",
		"toolchain go1.26.6",
		"github.com/evilmartians/lefthook/v2",
		"golang.org/x/vuln/cmd/govulncheck",
		"honnef.co/go/tools/cmd/staticcheck",
		"github.com/t33n-software/go-quality-authority/cmd/quality-gate",
		"github.com/t33n-software/go-quality-authority/cmd/check-coverage",
		"github.com/t33n-software/repository-governance/cmd/verify-canonical",
		"github.com/t33n-software/supply-chain-governance",
	} {
		if !strings.Contains(toolsMod, required) {
			t.Fatalf("tools/go.mod does not contain %q", required)
		}
	}
	if _, err := os.Stat(repositoryPath("tools", "go.sum")); err != nil {
		t.Fatalf("tools/go.sum is missing: %v", err)
	}

	manifest := readBindingManifest(t)
	for _, caller := range []string{"ci.yml", "codeql.yml"} {
		content := readRepositoryFile(t, ".github/workflows/"+caller)
		if !strings.Contains(content, "uses: "+manifest.Home.Repository+"/.github/workflows/reusable-") {
			t.Fatalf("the caller %s does not reference a home payload", caller)
		}
	}

	lefthook := readRepositoryFile(t, "lefthook.yml")
	for _, required := range []string{
		"commit-msg:",
		`git-governance --interactive never commit validate --message-file "{1}"`,
		"pre-push:",
		`git-governance --interactive never validate pre-push --remote "{1}"`,
	} {
		if !strings.Contains(lefthook, required) {
			t.Fatalf("lefthook.yml does not contain %q", required)
		}
	}

	traceability := readRepositoryFile(t, filepath.Join("docs", "TRACEABILITY.md"))
	if !strings.Contains(traceability, "DPI-7") {
		t.Fatal("TRACEABILITY.md does not contain DPI-7")
	}
}

// TestCustomConditionsBindContainsToCollectionArguments is the static
// evaluation-safety guard of the proven defect class: a contains call whose
// first argument is a string errors only when a value is evaluated and passes
// format, initialization and validation silently. The guard binds the class
// fail-closed: every contains call in every HCL surface of the core must
// resolve its first argument to a collection type (list, set or tuple) — a
// string, a map, an unresolvable reference or an unknown form is a violation.
func TestCustomConditionsBindContainsToCollectionArguments(t *testing.T) {
	for _, path := range repositoryFiles(t, []string{".tf"}) {
		raw, err := os.ReadFile(path)
		if err != nil {
			t.Fatalf("ReadFile(%q) error = %v", path, err)
		}
		content := string(raw)
		code := hclCodeMask(content)
		env := bindHCLEvaluationTypes(t, path, content, code)
		for _, site := range containsCallSites(content, code) {
			firstArgument := firstCallArgument(content, site)
			if err := proveCollectionFirstArgument(firstArgument, env); err != nil {
				t.Fatalf("%s: the contains call with first argument %q is not evaluation-safe: %v", path, firstArgument, err)
			}
		}
	}
}

// hclEvaluationEnv carries the deterministic type evidence of one HCL root:
// the declared variable types of the root directory and the for-binding
// element types of the single file under analysis.
type hclEvaluationEnv struct {
	variables map[string]*hclType
	forValues map[string]*hclType
}

// hclType is the minimal type model the evaluation-safety guard resolves
// against: leaves, collection constructors and object attribute maps.
type hclType struct {
	kind  string
	elem  *hclType
	attrs map[string]*hclType
}

func (t *hclType) isContainsCollection() bool {
	return t != nil && (t.kind == "list" || t.kind == "set" || t.kind == "tuple")
}

// hclCodeMask marks every byte of the content that is real HCL code; comments,
// string interiors and heredoc bodies are masked out so structural scans never
// match prose or literal text.
func hclCodeMask(content string) []bool {
	mask := make([]bool, len(content))
	for i := range mask {
		mask[i] = true
	}
	i := 0
	for i < len(content) {
		switch {
		case strings.HasPrefix(content[i:], "/*"):
			end := strings.Index(content[i+2:], "*/")
			if end < 0 {
				end = len(content) - i - 2
			}
			for j := i; j < i+2+end+2 && j < len(content); j++ {
				mask[j] = false
			}
			i += 2 + end + 2
		case strings.HasPrefix(content[i:], "//") || content[i] == '#':
			end := strings.IndexByte(content[i:], '\n')
			if end < 0 {
				end = len(content) - i
			}
			for j := i; j < i+end; j++ {
				mask[j] = false
			}
			i += end
		case strings.HasPrefix(content[i:], "<<"):
			heredocEnd := hclHeredocEnd(content, i)
			for j := i; j < heredocEnd; j++ {
				mask[j] = false
			}
			i = heredocEnd
		case content[i] == '"':
			end := i + 1
			for end < len(content) {
				if content[end] == '"' && content[end-1] != '\\' {
					break
				}
				end++
			}
			if end >= len(content) {
				end = len(content) - 1
			}
			for j := i + 1; j < end; j++ {
				mask[j] = false
			}
			i = end + 1
		default:
			i++
		}
	}
	return mask
}

// hclHeredocEnd returns the end offset of the heredoc starting at the given
// offset of the opening marker.
func hclHeredocEnd(content string, start int) int {
	lineEnd := strings.IndexByte(content[start:], '\n')
	if lineEnd < 0 {
		return len(content)
	}
	marker := strings.TrimSpace(strings.TrimPrefix(strings.TrimPrefix(content[start:start+lineEnd], "<<"), "-"))
	if marker == "" {
		return start + lineEnd
	}
	rest := content[start+lineEnd:]
	offset := 0
	for offset < len(rest) {
		next := strings.IndexByte(rest[offset:], '\n')
		if next < 0 {
			next = len(rest) - offset
		}
		line := strings.TrimSpace(rest[offset : offset+next])
		offset += next + 1
		if line == marker {
			return start + lineEnd + offset
		}
	}
	return len(content)
}

// bindHCLEvaluationTypes builds the type evidence of the root that owns the
// given file: the declared variable types from every file of the root
// directory plus the for-binding element types of the file itself.
func bindHCLEvaluationTypes(t *testing.T, path string, content string, code []bool) hclEvaluationEnv {
	t.Helper()
	env := hclEvaluationEnv{variables: map[string]*hclType{}, forValues: map[string]*hclType{}}
	root := filepath.Dir(path)
	entries, err := os.ReadDir(root)
	if err != nil {
		t.Fatalf("ReadDir(%q) error = %v", root, err)
	}
	for _, entry := range entries {
		if entry.IsDir() || filepath.Ext(entry.Name()) != ".tf" {
			continue
		}
		sibling, err := os.ReadFile(filepath.Join(root, entry.Name()))
		if err != nil {
			t.Fatalf("ReadFile(%q) error = %v", entry.Name(), err)
		}
		for name, declared := range declaredVariableTypes(t, entry.Name(), string(sibling)) {
			env.variables[name] = declared
		}
	}
	for name, bound := range forBindingTypes(t, path, content, code, env) {
		env.forValues[name] = bound
	}
	return env
}

// declaredVariableTypes extracts the declared type of every variable block of
// one file; a variable without a decodable type is a guard failure, never a
// silent pass.
func declaredVariableTypes(t *testing.T, name string, content string) map[string]*hclType {
	t.Helper()
	code := hclCodeMask(content)
	declared := map[string]*hclType{}
	for _, site := range keywordSites(content, code, "variable") {
		label, after := hclLabel(content, site+len("variable"))
		if label == "" {
			t.Fatalf("%s: a variable block without a readable label is not evaluation-safe", name)
		}
		body := blockBody(content, code, after)
		typeExpression := typeExpressionOf(content, code, body)
		if typeExpression == "" {
			t.Fatalf("%s: the variable %q carries no decodable type declaration", name, label)
		}
		declared[label] = parseHCLType(typeExpression)
	}
	return declared
}

// forBindingTypes extracts the element types of every for-binding of one file
// in textual order so inner bindings resolve against outer ones.
func forBindingTypes(t *testing.T, path string, content string, code []bool, env hclEvaluationEnv) map[string]*hclType {
	t.Helper()
	bound := map[string]*hclType{}
	for _, site := range keywordSites(content, code, "for") {
		cursor := skipSpace(content, site+len("for"))
		specEnd := cursor
		for specEnd < len(content) && !strings.HasPrefix(content[specEnd:], " in ") {
			specEnd++
		}
		if specEnd >= len(content) {
			t.Fatalf("%s: a for-binding without an in clause is not evaluation-safe", path)
		}
		variableNames := strings.Split(strings.TrimSpace(content[cursor:specEnd]), ",")
		collectionStart := skipSpace(content, specEnd+len(" in "))
		collectionEnd := collectionStart
		depth := 0
		for collectionEnd < len(content) {
			r := content[collectionEnd]
			switch r {
			case '(', '[', '{':
				depth++
			case ')', ']', '}':
				depth--
			case ':':
				if depth == 0 {
					goto collectionDone
				}
			}
			collectionEnd++
		}
	collectionDone:
		if collectionEnd >= len(content) {
			t.Fatalf("%s: a for-binding without a body separator is not evaluation-safe", path)
		}
		collectionType := resolveHCLExpressionType(strings.TrimSpace(content[collectionStart:collectionEnd]), env, bound)
		var valueType *hclType
		switch {
		case collectionType == nil:
			valueType = nil
		case collectionType.kind == "map" || collectionType.kind == "object":
			valueType = collectionType.elem
		case collectionType.kind == "list" || collectionType.kind == "set" || collectionType.kind == "tuple":
			valueType = collectionType.elem
		default:
			valueType = nil
		}
		bindForValue := func(name, role string) {
			name = strings.TrimSpace(name)
			var roleType *hclType
			if role == "key" {
				roleType = &hclType{kind: "string"}
			} else {
				roleType = valueType
			}
			if existing, exists := bound[name]; exists {
				if !sameHCLType(existing, roleType) {
					t.Fatalf("%s: the for-binding %q is ambiguous within one file", path, name)
				}
				return
			}
			bound[name] = roleType
		}
		if len(variableNames) == 2 {
			bindForValue(variableNames[0], "key")
			bindForValue(variableNames[1], "value")
		} else {
			bindForValue(variableNames[0], "value")
		}
	}
	return bound
}

// sameHCLType reports whether two resolved types are identical in kind,
// element type and attribute set.
func sameHCLType(a, b *hclType) bool {
	if a == nil || b == nil {
		return a == b
	}
	if a.kind != b.kind {
		return false
	}
	if !sameHCLType(a.elem, b.elem) {
		return false
	}
	if a.attrs == nil || b.attrs == nil {
		return a.attrs == nil && b.attrs == nil
	}
	if len(a.attrs) != len(b.attrs) {
		return false
	}
	for name, attr := range a.attrs {
		other, ok := b.attrs[name]
		if !ok || !sameHCLType(attr, other) {
			return false
		}
	}
	return true
}

// containsCallSites returns the offsets of every contains call in code
// position; the identifier must stand alone.
func containsCallSites(content string, code []bool) []int {
	sites := []int{}
	for i := 0; i+len("contains") <= len(content); i++ {
		if !code[i] || !strings.HasPrefix(content[i:], "contains") {
			continue
		}
		if i > 0 && isHCLIdentifierRune(content[i-1]) {
			continue
		}
		after := skipSpace(content, i+len("contains"))
		if after < len(content) && content[after] == '(' {
			sites = append(sites, after)
		}
		i = after
	}
	return sites
}

// firstCallArgument extracts the first top-level argument of the call whose
// opening parenthesis sits at the given offset.
func firstCallArgument(content string, openParen int) string {
	depth := 0
	for i := openParen; i < len(content); i++ {
		switch content[i] {
		case '(':
			depth++
		case ')':
			depth--
			if depth == 0 {
				return strings.TrimSpace(content[openParen+1 : i])
			}
		case ',':
			if depth == 1 {
				return strings.TrimSpace(content[openParen+1 : i])
			}
		}
	}
	return ""
}

// proveCollectionFirstArgument proves that the first argument of a contains
// call resolves to a contains-compatible collection type; every other outcome
// is a violation of the evaluation-safety guard.
func proveCollectionFirstArgument(argument string, env hclEvaluationEnv) error {
	if argument == "" {
		return fmt.Errorf("the call carries no readable first argument")
	}
	if strings.HasPrefix(argument, "\"") {
		return fmt.Errorf("the first argument is a string literal; contains requires a list, tuple or set")
	}
	if name, _, ok := strings.Cut(argument, "("); ok && collectionReturningFunctions[strings.TrimSpace(name)] {
		return nil
	}
	resolved := resolveHCLExpressionType(argument, env, env.forValues)
	if resolved == nil {
		return fmt.Errorf("the first argument type is not resolvable; the guard is fail-closed")
	}
	if !resolved.isContainsCollection() {
		return fmt.Errorf("the first argument resolves to %q; contains requires a list, tuple or set", resolved.kind)
	}
	return nil
}

// collectionReturningFunctions is the closed set of built-in calls whose
// result is a contains-compatible collection.
var collectionReturningFunctions = map[string]bool{
	"compact": true, "concat": true, "distinct": true, "flatten": true,
	"keys": true, "range": true, "reverse": true, "setintersection": true,
	"setsubtract": true, "setunion": true, "slice": true, "sort": true,
	"split": true, "tolist": true, "toset": true, "values": true,
}

// resolveHCLExpressionType resolves a reference expression — a variable
// reference, a for-value reference or an attribute walk over one of them — to
// its declared type; anything else is unresolvable.
func resolveHCLExpressionType(expression string, env hclEvaluationEnv, forValues map[string]*hclType) *hclType {
	segments := strings.Split(expression, ".")
	for _, segment := range segments {
		if segment == "" || !isHCLIdentifier(segment) {
			return nil
		}
	}
	var current *hclType
	if segments[0] == "var" {
		if len(segments) < 2 {
			return nil
		}
		current = env.variables[segments[1]]
		segments = segments[2:]
	} else {
		current = forValues[segments[0]]
		segments = segments[1:]
	}
	for _, segment := range segments {
		if current == nil || current.attrs == nil {
			return nil
		}
		current = current.attrs[segment]
	}
	return current
}

// parseHCLType parses the declared type expression of a variable into the
// guard's minimal type model.
func parseHCLType(expression string) *hclType {
	expression = strings.TrimSpace(expression)
	switch expression {
	case "string", "number", "bool", "any":
		return &hclType{kind: expression}
	}
	for _, constructor := range []string{"list", "set", "map"} {
		if strings.HasPrefix(expression, constructor+"(") && strings.HasSuffix(expression, ")") {
			return &hclType{kind: constructor, elem: parseHCLType(expression[len(constructor)+1 : len(expression)-1])}
		}
	}
	if strings.HasPrefix(expression, "tuple(") {
		return &hclType{kind: "tuple"}
	}
	if strings.HasPrefix(expression, "object(") {
		inner := strings.TrimSuffix(strings.TrimPrefix(expression, "object("), ")")
		inner = strings.TrimSpace(strings.TrimSuffix(strings.TrimPrefix(strings.TrimSpace(inner), "{"), "}"))
		attrs := map[string]*hclType{}
		for _, attribute := range splitTopLevelAttributes(inner) {
			name, value, found := strings.Cut(attribute, "=")
			if !found {
				continue
			}
			attrs[strings.TrimSpace(name)] = parseHCLType(value)
		}
		return &hclType{kind: "object", attrs: attrs}
	}
	if strings.HasPrefix(expression, "optional(") && strings.HasSuffix(expression, ")") {
		inner := expression[len("optional(") : len(expression)-1]
		if comma := topLevelComma(inner); comma >= 0 {
			inner = inner[:comma]
		}
		return parseHCLType(inner)
	}
	return &hclType{kind: "unknown"}
}

// splitTopLevelAttributes splits an object attribute body at top-level
// newlines and commas.
func splitTopLevelAttributes(body string) []string {
	attributes := []string{}
	depth := 0
	start := 0
	for i := 0; i < len(body); i++ {
		switch body[i] {
		case '(', '[', '{':
			depth++
		case ')', ']', '}':
			depth--
		case '\n', ',':
			if depth == 0 {
				if strings.TrimSpace(body[start:i]) != "" {
					attributes = append(attributes, body[start:i])
				}
				start = i + 1
			}
		}
	}
	if strings.TrimSpace(body[start:]) != "" {
		attributes = append(attributes, body[start:])
	}
	return attributes
}

// topLevelComma returns the offset of the first comma outside any bracket.
func topLevelComma(expression string) int {
	depth := 0
	for i := 0; i < len(expression); i++ {
		switch expression[i] {
		case '(', '[', '{':
			depth++
		case ')', ']', '}':
			depth--
		case ',':
			if depth == 0 {
				return i
			}
		}
	}
	return -1
}

// keywordSites returns the offsets of every standalone occurrence of the
// keyword in code position.
func keywordSites(content string, code []bool, keyword string) []int {
	sites := []int{}
	for i := 0; i+len(keyword) <= len(content); i++ {
		if !code[i] || !strings.HasPrefix(content[i:], keyword) {
			continue
		}
		if i > 0 && isHCLIdentifierRune(content[i-1]) {
			continue
		}
		if i+len(keyword) < len(content) && isHCLIdentifierRune(content[i+len(keyword)]) {
			continue
		}
		sites = append(sites, i)
	}
	return sites
}

// hclLabel reads the quoted block label after a block keyword.
func hclLabel(content string, afterKeyword int) (string, int) {
	cursor := skipSpace(content, afterKeyword)
	if cursor >= len(content) || content[cursor] != '"' {
		return "", cursor
	}
	end := cursor + 1
	for end < len(content) && content[end] != '"' {
		end++
	}
	if end >= len(content) {
		return "", cursor
	}
	return content[cursor+1 : end], end + 1
}

// blockBody returns the span of the brace-balanced block body starting at the
// given offset.
func blockBody(content string, code []bool, afterLabel int) [2]int {
	start := -1
	for i := afterLabel; i < len(content); i++ {
		if code[i] && content[i] == '{' {
			start = i
			break
		}
		if code[i] && content[i] == '\n' {
			return [2]int{afterLabel, afterLabel}
		}
	}
	if start < 0 {
		return [2]int{afterLabel, afterLabel}
	}
	depth := 0
	for i := start; i < len(content); i++ {
		if !code[i] {
			continue
		}
		switch content[i] {
		case '{':
			depth++
		case '}':
			depth--
			if depth == 0 {
				return [2]int{start, i + 1}
			}
		}
	}
	return [2]int{start, len(content)}
}

// typeExpressionOf extracts the type expression of a variable block body.
func typeExpressionOf(content string, code []bool, body [2]int) string {
	for _, site := range keywordSites(content[body[0]:body[1]], code[body[0]:body[1]], "type") {
		absolute := body[0] + site
		cursor := skipSpace(content, absolute+len("type"))
		if cursor >= len(content) || content[cursor] != '=' {
			continue
		}
		cursor = skipSpace(content, cursor+1)
		start := cursor
		depth := 0
		for cursor < len(content) {
			r := content[cursor]
			switch r {
			case '(', '[', '{':
				depth++
			case ')', ']', '}':
				if depth == 0 {
					return strings.TrimSpace(content[start:cursor])
				}
				depth--
			case '\n':
				if depth == 0 {
					return strings.TrimSpace(content[start:cursor])
				}
			}
			cursor++
		}
		return strings.TrimSpace(content[start:cursor])
	}
	return ""
}

func skipSpace(content string, from int) int {
	for from < len(content) && (content[from] == ' ' || content[from] == '\t' || content[from] == '\n' || content[from] == '\r') {
		from++
	}
	return from
}

func isHCLIdentifierRune(r byte) bool {
	return r == '_' || r == '-' || (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9')
}

func isHCLIdentifier(value string) bool {
	if value == "" {
		return false
	}
	for i := 0; i < len(value); i++ {
		if !isHCLIdentifierRune(value[i]) || value[i] == '-' {
			return false
		}
	}
	return true
}

func normalizeWhitespace(content string) string {
	return strings.Join(strings.Fields(content), " ")
}

func repositoryFiles(t *testing.T, extensions []string) []string {
	t.Helper()
	root := repositoryPath()
	matches := make([]string, 0)
	err := filepath.WalkDir(root, func(path string, entry os.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if entry.IsDir() {
			switch entry.Name() {
			case ".git", ".build", ".terraform", "coverage", "dist", "vendor":
				return filepath.SkipDir
			default:
				return nil
			}
		}
		for _, extension := range extensions {
			if filepath.Ext(path) == extension {
				matches = append(matches, path)
				break
			}
		}
		return nil
	})
	if err != nil {
		t.Fatalf("WalkDir(%q) error = %v", root, err)
	}
	sort.Strings(matches)
	return matches
}

func readRepositoryFile(t *testing.T, path string) string {
	t.Helper()
	content, err := os.ReadFile(repositoryPath(filepath.FromSlash(path)))
	if err != nil {
		t.Fatalf("ReadFile(%q) error = %v", path, err)
	}
	return string(content)
}

func repositoryPath(parts ...string) string {
	return filepath.Join(append([]string{"..", ".."}, parts...)...)
}
