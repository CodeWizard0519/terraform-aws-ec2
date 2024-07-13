### Initialize Terraform

Initialize a Terraform working directory containing Terraform configuration files:

```sh
terraform init
```

This command initializes various local settings and data that Terraform will use to execute commands and manage your infrastructure.

### Create an Execution Plan (Optional but recommended)

Generate and show an execution plan without making any changes to infrastructure. This step is useful to preview what Terraform will do before actually applying the changes:

```sh
terraform plan
```

### Apply Changes

Apply the changes required to reach the desired state of the configuration, as defined by the `.tf` files in the directory:

```sh
terraform apply
```

This command will prompt for confirmation (`yes` to proceed). Terraform will then apply the changes, provisioning or modifying resources as necessary.

### Destroy Infrastructure

Destroy Terraform-managed infrastructure. This command is used to delete all resources defined in your Terraform configuration:

```sh
terraform destroy
```

This command will prompt for confirmation (`yes` to proceed). Terraform will then proceed to destroy all resources defined in your configuration.

### Notes:

- **State Management**: Terraform maintains the state of your infrastructure in a `terraform.tfstate` file. This file is crucial for managing and tracking changes to your infrastructure. Ensure it's managed properly to avoid accidental deletion or corruption.

- **Backend Configuration**: Depending on your setup, Terraform might use a backend to store state files remotely. Make sure your backend configuration (`backend.tf`) is correctly set up if you're using remote state management.

These commands provide a foundational workflow for managing infrastructure with Terraform. Always review the Terraform output carefully during `plan` and `apply` stages to verify expected changes and avoid unintended modifications.

----

To get the `kubeconfig` for the EKS cluster that you've created using Terraform, you can follow these steps. The `kubeconfig` file allows you to connect to your EKS cluster from your local machine or any other environment.

### Using AWS CLI

If you have the AWS CLI installed and configured with the necessary IAM credentials that have access to your EKS cluster, you can retrieve the `kubeconfig` as follows:

1. **Install AWS CLI**: If you haven't already installed the AWS CLI, you can do so by following the instructions [here](https://aws.amazon.com/cli/).

2. **Update AWS CLI**: Ensure your AWS CLI is up-to-date:

   ```sh
   aws --version
   ```

3. **Configure AWS CLI**: Make sure your AWS CLI is configured with credentials that have permissions to access your EKS cluster:

   ```sh
   aws configure
   ```

4. **Get kubeconfig**: Use the `aws eks update-kubeconfig` command to update your `kubeconfig` with credentials from the specified EKS cluster:

   ```sh
   aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
   ```

   Replace `<your-region>` with the AWS region where your EKS cluster is deployed (e.g., `us-west-2`), and `<your-cluster-name>` with the name of your EKS cluster (e.g., `aimlops-demo`).

5. **Verify kubeconfig**: Verify that the `kubeconfig` has been updated correctly:

   ```sh
   kubectl config view --minify
   ```

   This command should display the `kubeconfig` context for your EKS cluster, including the server endpoint, certificate authority data, and authentication details.

### Manual Configuration

If you prefer to manually configure your `kubeconfig` file:

1. **Retrieve Cluster Endpoint and Certificate Authority Data**:
   You can retrieve these details from the AWS Management Console or by using the AWS CLI:

   ```sh
   aws eks describe-cluster --name <your-cluster-name> --query "cluster.{endpoint: endpoint, certificateAuthority: certificateAuthority.data}" --region <your-region>
   ```

   Ensure to replace `<your-cluster-name>` and `<your-region>` with your cluster's actual name and AWS region.

2. **Update kubeconfig File**:
   Update your local `kubeconfig` file manually using the retrieved endpoint and certificate authority data:

   ```sh
   apiVersion: v1
   clusters:
   - cluster:
       server: https://<cluster-endpoint>
       certificate-authority-data: <base64-encoded-certificate-authority-data>
     name: <cluster-name>
   contexts:
   - context:
       cluster: <cluster-name>
       user: aws
     name: aws
   current-context: aws
   kind: Config
   preferences: {}
   users:
   - name: aws
     user:
       exec:
         apiVersion: client.authentication.k8s.io/v1alpha1
         args:
         - eks
         - get-token
         - --cluster-name
         - <cluster-name>
         - --region
         - <your-region>
         command: aws
         env: null
   ```

   - Replace `<cluster-endpoint>` with the endpoint of your EKS cluster.
   - Replace `<base64-encoded-certificate-authority-data>` with the base64-encoded certificate authority data from the previous step.
   - Replace `<cluster-name>` with your EKS cluster name.
   - Replace `<your-region>` with your AWS region.

3. **Verify kubeconfig**:
   After updating the `kubeconfig` file, verify that you can access your EKS cluster:

   ```sh
   kubectl config view --minify
   ```

   This command should display the updated `kubeconfig` context for your EKS cluster.

By following these steps, you can obtain and configure the `kubeconfig` file to connect to your AWS EKS cluster, whether through AWS CLI or manually updating the configuration file.

