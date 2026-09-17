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

# The (state home, operator member) binding set of the operator bindings:
# one resource-sharp binding per pair, shared by the object data plane and
# the bucket metadata read surface.
locals {
  operator_bindings = {
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

  # The canonical role id of the purpose-bound minimal role of the
  # state-home operator binding: exactly the bucket metadata read surface
  # every plan and refresh of this root needs. The role is born once per
  # state-home project through the governed window channel (the documented
  # birth act of the state home, the same operational class as the CMEK
  # service-agent authorization) and referenced here by name.
  state_home_bucket_metadata_read_role_id = "stateHomeBucketMetadataRead"
}

# The bucket data plane of the engine: exactly the storage object-admin
# role, resource-sharp on each state bucket, for the instance-bound operator
# execution identities of that boundary.
resource "google_storage_bucket_iam_member" "operators" {
  for_each = local.operator_bindings

  bucket = google_storage_bucket.state_homes[each.value.identity].name
  role   = "roles/storage.objectAdmin"
  member = each.value.member
}

# The bucket metadata read surface of the operator binding: the purpose-bound
# minimal role (exactly storage.buckets.get and storage.buckets.getIamPolicy),
# resource-sharp on each state bucket, so every plan and refresh of this root
# reads the bucket resource and its IAM bindings under the standing binding
# alone. The broad predefined carriers of the two permissions remain
# time-boxed window elevations, never standing rights.
resource "google_storage_bucket_iam_member" "operator_metadata_read" {
  for_each = local.operator_bindings

  bucket = google_storage_bucket.state_homes[each.value.identity].name
  role   = "projects/${var.state_homes[each.value.identity].project_id}/roles/${local.state_home_bucket_metadata_read_role_id}"
  member = each.value.member
}
