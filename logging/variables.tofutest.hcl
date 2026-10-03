# The behavioral proof of the logging area variable contract: every custom
# condition of the root is proven with concrete values — rejection paths
# through expect_failures, the acceptance path through assertions. No run
# creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference and the state bucket name are never committed:
# the encryption block resolves the key at initialization, so the execution
# supplies both through the instance-bound variable channel (a gitignored
# *.tfvars in the governed execution window). Every value in this file is
# synthetic test data.

variables {
  # The shared valid anchor set every run starts from; a rejection run
  # overrides exactly the value under test.
  organization_id = "123456789012"
  organization_audit_export_anchors = {
    org_plane_audit_anchor = {
      destination = "storage.googleapis.com/example-org-evidence-archive"
      filter      = "resource.type = audited_resource"
      description = "The organization-plane audit export anchor of the example organization."
      exclusions = [
        {
          name        = "example-exclusion"
          filter      = "severity < NOTICE"
          description = "The example exclusion of the behavioral proof."
          disabled    = false
        }
      ]
    }
  }
}

run "accepts_the_valid_anchor_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_logging_organization_sink.organization_audit_export_anchors["org_plane_audit_anchor"].name == "org_plane_audit_anchor"
    error_message = "The anchor must carry its declared name."
  }

  assert {
    condition     = google_logging_organization_sink.organization_audit_export_anchors["org_plane_audit_anchor"].org_id == "123456789012"
    error_message = "The anchor must carry the declared numeric organization identifier."
  }

  assert {
    condition     = google_logging_organization_sink.organization_audit_export_anchors["org_plane_audit_anchor"].destination == "storage.googleapis.com/example-org-evidence-archive"
    error_message = "The anchor must carry the declared archive destination."
  }

  assert {
    condition     = google_logging_organization_sink.organization_audit_export_anchors["org_plane_audit_anchor"].filter == "resource.type = audited_resource"
    error_message = "The anchor must carry the declared export filter."
  }

  assert {
    condition     = google_logging_organization_sink.organization_audit_export_anchors["org_plane_audit_anchor"].include_children == false
    error_message = "The anchor must scope the export to the organization level: the child inclusion stays disabled, so the anchor never duplicates the zone audit exports."
  }

  assert {
    condition     = google_logging_organization_sink.organization_audit_export_anchors["org_plane_audit_anchor"].deletion_policy == "PREVENT"
    error_message = "Every anchor must pin the provider-native deletion policy to the prevent form."
  }

  assert {
    condition     = google_logging_organization_sink.organization_audit_export_anchors["org_plane_audit_anchor"].exclusions[0].name == "example-exclusion"
    error_message = "The anchor must carry its declared exclusion surface."
  }
}

run "rejects_an_empty_anchor_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_audit_export_anchors = {}
  }

  expect_failures = [var.organization_audit_export_anchors]
}

run "rejects_a_malformed_anchor_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_audit_export_anchors = {
      "-bad-anchor" = {
        destination = "storage.googleapis.com/example-org-evidence-archive"
        filter      = "resource.type = audited_resource"
        description = "The organization-plane audit export anchor of the example organization."
      }
    }
  }

  expect_failures = [var.organization_audit_export_anchors]
}

run "rejects_a_destination_outside_the_storage_archive_form" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_audit_export_anchors = {
      org_plane_audit_anchor = {
        destination = "bigquery.googleapis.com/projects/example-project/datasets/example-dataset"
        filter      = "resource.type = audited_resource"
        description = "The organization-plane audit export anchor of the example organization."
      }
    }
  }

  expect_failures = [var.organization_audit_export_anchors]
}

run "rejects_an_empty_filter" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_audit_export_anchors = {
      org_plane_audit_anchor = {
        destination = "storage.googleapis.com/example-org-evidence-archive"
        filter      = ""
        description = "The organization-plane audit export anchor of the example organization."
      }
    }
  }

  expect_failures = [var.organization_audit_export_anchors]
}

run "rejects_an_empty_description" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_audit_export_anchors = {
      org_plane_audit_anchor = {
        destination = "storage.googleapis.com/example-org-evidence-archive"
        filter      = "resource.type = audited_resource"
        description = ""
      }
    }
  }

  expect_failures = [var.organization_audit_export_anchors]
}

run "rejects_an_oversized_description" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_audit_export_anchors = {
      org_plane_audit_anchor = {
        destination = "storage.googleapis.com/example-org-evidence-archive"
        filter      = "resource.type = audited_resource"
        description = "a${join("", [for i in range(4000) : "aa"])}"
      }
    }
  }

  expect_failures = [var.organization_audit_export_anchors]
}

run "rejects_a_malformed_organization_id" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_id = "example-org"
  }

  expect_failures = [var.organization_id]
}

run "rejects_a_malformed_exclusion_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    organization_audit_export_anchors = {
      org_plane_audit_anchor = {
        destination = "storage.googleapis.com/example-org-evidence-archive"
        filter      = "resource.type = audited_resource"
        description = "The organization-plane audit export anchor of the example organization."
        exclusions = [
          {
            name        = "-bad-exclusion"
            filter      = "severity < NOTICE"
            description = "The example exclusion of the behavioral proof."
            disabled    = false
          }
        ]
      }
    }
  }

  expect_failures = [var.organization_audit_export_anchors]
}
