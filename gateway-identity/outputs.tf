// Outputs of the gateway-identity area: the declared binding surfaces this
// root projects, keyed by the lane identity. The credential host project is
// carried as an output so the instance verifier can cross-bind the lane
// contract against the declared environment surface without re-deriving it.

output "pool_name" {
  description = "Resource name of the estate's workload identity pool — the trust boundary every lane provider federates into."
  value       = google_iam_workload_identity_pool.gateway.name
}

output "provider_names" {
  description = "Workload identity provider resource names of the declared lanes, keyed by lane identity — the value the lane's workflow resolves as its federation target."
  value       = { for lane_key, provider in google_iam_workload_identity_pool_provider.gateway : lane_key => provider.name }
}

output "service_account_emails" {
  description = "Service-account emails of the declared lanes, keyed by lane identity — the federated workload identity each lane assumes, never a key-bearing identity."
  value       = { for lane_key, account in google_service_account.gateway_lane : lane_key => account.email }
}

output "secret_ids" {
  description = "Tenant-scoped secret identifiers of the declared lanes, keyed by lane identity — the one secret each lane may read. The secret payload is never part of this surface."
  value       = { for lane_key, secret in google_secret_manager_secret.gateway_lane : lane_key => secret.secret_id }
}

output "environments" {
  description = "Protected environment names of the declared lanes, keyed by lane identity — the hosting-platform side of the same binding contract."
  value       = { for lane_key, environment in github_repository_environment.gateway_lane : lane_key => environment.environment }
}
