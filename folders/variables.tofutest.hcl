# The behavioral proof of the folders area variable contract: every custom
# condition of the root is proven with concrete values — rejection paths
# through expect_failures, the acceptance path through assertions. No run
# creates infrastructure: every run is a plan with refresh disabled.
#
# The engine key reference is never committed: the encryption block resolves
# it at initialization, so the execution supplies it through the
# instance-bound variable channel (a gitignored *.tfvars in the governed
# execution window). Every value in this file is synthetic test data.

variables {
  # The shared valid folder-plane set every run starts from; a rejection
  # run overrides exactly the value under test.
  folders = {
    dependency-authority = {
      display_name = "dependency-authority"
      parent       = "organizations/123456789012"
    }
  }
  folder_iam_members = {
    organization_plane_interim_carrier = {
      folder = "dependency-authority"
      role   = "roles/resourcemanager.folderAdmin"
      member = "user:ops@example.com"
    }
  }
  projects = {
    zone_control = {
      project_id      = "example-dep-control"
      name            = "example-dep-control"
      parent          = "folders/123456789012"
      billing_account = "00AA11-BB22CC-33DD44"
      labels = {
        boundary = "dependency-authority"
        zone     = "control"
      }
    }
    org_anchor = {
      project_id      = "example-org-anchor"
      name            = "example-org-anchor"
      parent          = "organizations/123456789012"
      billing_account = "00AA11-BB22CC-33DD44"
      labels = {
        boundary = "organization-anchor"
      }
    }
  }
}

run "accepts_the_valid_folder_plane_set" {
  command = plan

  plan_options {
    refresh = false
  }

  assert {
    condition     = google_folder.hierarchy["dependency-authority"].display_name == "dependency-authority"
    error_message = "The folder must carry the declared display name."
  }

  assert {
    condition     = google_folder.hierarchy["dependency-authority"].parent == "organizations/123456789012"
    error_message = "The folder must carry the declared parent."
  }

  assert {
    condition     = google_folder_iam_member.plane["organization_plane_interim_carrier"].role == "roles/resourcemanager.folderAdmin"
    error_message = "The folder IAM member binding must carry the declared role."
  }

  assert {
    condition     = google_folder_iam_member.plane["organization_plane_interim_carrier"].member == "user:ops@example.com"
    error_message = "The folder IAM member binding must carry the declared member."
  }

  assert {
    condition     = google_project.placed["zone_control"].folder_id == "123456789012"
    error_message = "The folder-parented project must bind the numeric folder identifier derived from the declared parent."
  }

  assert {
    condition     = google_project.placed["org_anchor"].org_id == "123456789012"
    error_message = "The organization-parented project must bind the numeric organization identifier derived from the declared parent."
  }
}

run "rejects_an_empty_folder_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    folders = {}
  }

  expect_failures = [var.folders]
}

run "rejects_a_malformed_folder_display_name" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    folders = {
      dependency-authority = {
        display_name = "-bad name!"
        parent       = "organizations/123456789012"
      }
    }
  }

  expect_failures = [var.folders]
}

run "rejects_a_malformed_folder_parent" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    folders = {
      dependency-authority = {
        display_name = "dependency-authority"
        parent       = "organizations/not-numeric"
      }
    }
  }

  expect_failures = [var.folders]
}

run "rejects_an_empty_folder_iam_member_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    folder_iam_members = {}
  }

  expect_failures = [var.folder_iam_members]
}

run "rejects_a_malformed_folder_reference" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    folder_iam_members = {
      organization_plane_interim_carrier = {
        folder = "Dependency Authority"
        role   = "roles/resourcemanager.folderAdmin"
        member = "user:ops@example.com"
      }
    }
  }

  expect_failures = [var.folder_iam_members]
}

run "rejects_a_malformed_folder_iam_role" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    folder_iam_members = {
      organization_plane_interim_carrier = {
        folder = "dependency-authority"
        role   = "folderAdmin"
        member = "user:ops@example.com"
      }
    }
  }

  expect_failures = [var.folder_iam_members]
}

run "rejects_a_malformed_folder_iam_member_string" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    folder_iam_members = {
      organization_plane_interim_carrier = {
        folder = "dependency-authority"
        role   = "roles/resourcemanager.folderAdmin"
        member = "ops@example.com"
      }
    }
  }

  expect_failures = [var.folder_iam_members]
}

run "rejects_an_empty_project_map" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    projects = {}
  }

  expect_failures = [var.projects]
}

run "rejects_a_malformed_project_id" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    projects = {
      zone_control = {
        project_id      = "1xample-dep-control"
        name            = "example-dep-control"
        parent          = "folders/123456789012"
        billing_account = "00AA11-BB22CC-33DD44"
        labels          = {}
      }
    }
  }

  expect_failures = [var.projects]
}

run "rejects_a_malformed_project_parent" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    projects = {
      zone_control = {
        project_id      = "example-dep-control"
        name            = "example-dep-control"
        parent          = "folders/not-numeric"
        billing_account = "00AA11-BB22CC-33DD44"
        labels          = {}
      }
    }
  }

  expect_failures = [var.projects]
}

run "rejects_a_malformed_billing_account" {
  command = plan

  plan_options {
    refresh = false
  }

  variables {
    projects = {
      zone_control = {
        project_id      = "example-dep-control"
        name            = "example-dep-control"
        parent          = "folders/123456789012"
        billing_account = "not-a-billing-id"
        labels          = {}
      }
    }
  }

  expect_failures = [var.projects]
}