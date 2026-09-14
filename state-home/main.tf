# The state homes of the organization: exactly one dedicated Cloud Storage
# bucket per boundary (the foundation plus every trust zone), holding that
# boundary's root states and nothing else. The form is the provider layer of
# the dual fortress state-encryption standard: uniform bucket-level access,
# enforced public access prevention, object versioning (the documented
# backend recommendation and the prerequisite of the key-version destruction
# discipline) and the mandatory bucket CMEK with the second,
# cryptographically separate key. A state bucket never carries a retention
# policy: the state layer is the recovery root, not an archive.
resource "google_storage_bucket" "state_homes" {
  for_each = var.state_homes

  project  = each.value.project_id
  name     = each.value.bucket_name
  location = each.value.location

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = each.value.cmek_key_name
  }

  labels = each.value.labels
}

# The bucket data plane of the engine: exactly the storage object-admin
# role, resource-sharp on each state bucket, for the instance-bound operator
# execution identities of that boundary. No other role is ever granted
# through this area.
resource "google_storage_bucket_iam_member" "operators" {
  for_each = {
    for binding in flatten([
      for identity, home in var.state_homes : [
        for member in home.operator_members : {
          key      = "${identity}/${member}"
          identity = identity
          member   = member
        }
      ]
    ]) : binding.key => binding
  }

  bucket = google_storage_bucket.state_homes[each.value.identity].name
  role   = "roles/storage.objectAdmin"
  member = each.value.member
}
