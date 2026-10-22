# operation-create-wildcard-terraform-data-passes: resource_policy "terraform_*" operations=[create] on terraform_data: create of input=prod passes at plan and apply (terraform_data only, no AWS resources); L1 N/A: tfpolicy 0.4.0 cannot acquire a schema for the builtin terraform provider (wildcard matches no known types)
# tfp plan: PASS
# tfp apply: PASS
resource "terraform_data" "x" {
  input = "prod"
}
