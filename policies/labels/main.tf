locals {
  values = {
    chore = {
      color       = "000000"
      description = "Routine maintenance"
    }
    doc = {
      color       = "56B4E9"
      description = "Documentation changes"
    }
    fix = {
      color       = "D55E00"
      description = "Bug fixes"
    }
    feat = {
      color       = "009E73"
      description = "New features"
    }
    infra = {
      color       = "0072B2"
      description = "Infrastructure changes"
    }
    refac = {
      color       = "CC79A7"
      description = "Refactoring without behavior changes"
    }
    revert = {
      color       = "E69F00"
      description = "Reverts a previous change"
    }
  }
}

output "values" {
  description = "Authoritative labels derived from the allowed commit prefixes."
  value       = local.values
}
