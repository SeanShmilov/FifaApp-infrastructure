terraform {
  cloud {
    # Remember to replace this with your actual TFC organization name in Terraform Cloud
    organization = "Shonca"

    workspaces {
      name = "fifaapp-eks"
    }
  }
}
