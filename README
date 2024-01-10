# Cinema Stats

## 1. Ingest Raw Data to S3
- **S3 Bucket Setup**: [Create an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/creating-bucket.html) to store raw data.
- **Data Upload**: Configure data sources to upload raw data directly to this [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html).

## 2. Data Pipeline with Dagster
- **Dagster Setup**: Implement a data pipeline using [Dagster](https://docs.dagster.io/overview) to manage the workflow.
- **Data Cleaning and Transformation**: Use Dagster's assets to clean and transform the raw data.
- **Upload to S3 as Parquet**: After processing, upload the cleaned data to S3 as Parquet files for efficient querying.

## 3. Query Data with AWS Athena
- **AWS Athena Setup**: Configure [AWS Athena](https://docs.aws.amazon.com/athena/latest/ug/getting-started.html) to query the Parquet files stored in S3.
- **Integration with R Shiny**: Ensure the R Shiny app can execute Athena queries to retrieve and visualize the data.

## 4. Deploy R Shiny App on AWS ECS
- **R Shiny App Development**: Develop an [R Shiny application](https://shiny.rstudio.com/) for data visualization.
- **Containerization**: Dockerize the R Shiny app and push the Docker image to [Amazon ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).
- **ECS Configuration**: Set up an ECS service with a task definition for the R Shiny app.
- **Scalability**: Configure the ECS service to [scale to 0](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html) when not in use to save costs.
- **Cold Start Enhancement**: Time permitting, use [AWS CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html) to display a custom error message during cold starts, improving user experience.

## 5. Security and Compliance
- **Data Encryption**: Implement encryption for data at rest in S3 and during transit.
- **AWS Security Practices**: Follow AWS best practices for security, including IAM roles, security groups, and network ACLs.

## 6. Testing and Validation
- **End-to-End Testing**: Conduct comprehensive testing for each component of the pipeline.
- **Performance Testing**: Assess the performance and load handling capability of the data pipeline and R Shiny app.

## 7. Maintenance and Monitoring
- **Routine Updates**: Regularly update the pipeline components and R Shiny app.
- **Continuous Monitoring**: Utilize AWS CloudWatch and other tools for ongoing monitoring of the system.

## 8. CI/CD Pipeline with GitHub Actions and Terraform

- **GitHub Actions for Continuous Integration and Deployment**:
  - **Docker Image Build and Push**:
    - Set up a [GitHub Actions workflow](https://docs.github.com/en/actions) to automate the building of the Docker image for the R Shiny app.
    - Configure the workflow to push the built image to [Amazon ECR](https://aws.amazon.com/ecr/).
    - Trigger this workflow on specific events, such as a push to the `main` branch or when a pull request is merged.

- **Terraform for Infrastructure as Code**:
  - Utilize [Terraform](https://www.terraform.io/) to define and manage the AWS infrastructure required for the R Shiny app.
  - Automate infrastructure updates using GitHub Actions to apply Terraform configurations.
  - Store Terraform state files securely, for instance, in an encrypted S3 bucket.
  - **Infrastructure Update Workflow**:
    - Implement a GitHub Actions workflow that triggers Terraform commands (`terraform apply`) on changes to Terraform files or on specific events.
- **Migration to Terraform Open-Source Modules**:
  - If time permits, consider migrating Terraform configuration to use open-source modules from the [Terraform Registry](https://registry.terraform.io/).
  - Open-source modules can streamline the setup and maintenance of infrastructure and ensure best practices.
  - Plan and test thoroughly when migrating to these modules to ensure compatibility with existing setup.

### Key Considerations:
- **Secrets Management**: Store AWS credentials and other sensitive information as [encrypted secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) in GitHub Actions.
