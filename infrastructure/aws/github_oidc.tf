# Define OIDC identity provider (used in GitHub Actions).
module "github-oidc" {
  source        = "github.com/bananalab/terraform-modules//modules/aws-github-oidc?ref=v0.3.0"
  create_secret = false
  organization  = "bananalab"
  policy_arns   = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  repo          = "lightfeather-devops-code-challenge"
}
