output "state_home_buckets" {
  description = "The declared state-home buckets, keyed by state-home identity: name, resource ID, self link and gs:// URL."
  value = {
    for identity, bucket in google_storage_bucket.state_homes : identity => {
      name      = bucket.name
      id        = bucket.id
      self_link = bucket.self_link
      url       = bucket.url
    }
  }
}

output "state_home_operator_iam_member_ids" {
  description = "Resource IDs of the operator object-admin bindings on the state-home buckets, keyed by state-home identity and member."
  value       = { for key, binding in google_storage_bucket_iam_member.operators : key => binding.id }
}
