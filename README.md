# Provision Shared-VPC Bridge Network on GCP

This terraform module provides the preferred path for connecting a CloudWright Deployment Zone to a GCP Shared VPC network.  This terraform module:

- creates a new GCP project
- creates a bridge VPC network
- sets up peering between the bridge network and the existing Shared VPC network
- creates a Serverless VPC Access Connector which connects to the bridge network

The provisioned GCP project can be used as the GCP Deployment Zone target project when [creating a GCP Deployment Zone](https://docs.cloudwright.io/deployment_zones.html#customer-managed), and the provisioned Serverless VPC Access Connector can be used as the optional [VPC attachment device](https://docs.cloudwright.io/vpc_connections.html#gcp-network-access) during that process.

For more details about the provisioned network architecture, see the [CloudWright docs](https://docs.cloudwright.io/vpc_connections.html#gcp-network-access)

### Inputs

- `provision_project_id`: the project ID to create
- `billing_account`: a billing account ID to associate with the created project 
- `target_network`: the name of the existing Shared VPC network to attach to
- `target_network_project`: the project in which the target Shared VPC network lives
- `connector_cidr_block`: a free CIDR block (must be a /28) used to provision the Serverless Access Connector
- `connector_region`: the region in which to provision the Serverless Access Connector

### Outputs

- `access_connector_id`: the ID of the provisioned access connector, to be provided during Deployment Zone creation
 
### Example Usage

Invoked standalone from this project:

```bash
$ terraform apply -var 'provision_project_id=my-new-project' -var 'target_network=existing-shared-vpc' -var 'target_network_project=existing-host-project' -var 'connector_cidr_block=10.125.10.0/28' -var 'connector_region=us-central1' -var 'billing_account=BILLING-ACCOUNT-ID'
```

Invoked as a module in a terraform script:

```hcl
module "cloudwright-deployment-zone" {
  source  = "CloudWright/cloudwright-vpc-peering/google"
  version = "0.1.0"
  provision_project_id = "my-new-project"
  target_network = "existing-shared-vpc"
  target_network_project = "existing-host-project"
  connector_cidr_block = "10.125.10.0/28"
  connector_region = "us-central1"
  billing_account = "BILLING-ACCOUNT-ID"
}
```
