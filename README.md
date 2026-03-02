# Serverless Secure Application Deployment with AWS Services

## Project Overview

This project demonstrates the deployment of a secure, fully serverless, event-driven backend architecture on AWS. The primary objective was to design a highly secure, scalable, and production-ready system using AWS managed services.

The architecture leverages Amazon Cognito for authentication, API Gateway for secure routing, AWS Lambda for serverless compute, DynamoDB and S3 for data storage, SNS for event notifications, Secrets Manager for secure configuration handling, and a custom VPC for private networking. All components are configured following least-privilege IAM principles and private service communication via VPC endpoints.

**AWS Services**:  
![Cognito](https://img.shields.io/badge/AWS-Cognito-DD344C?style=for-the-badge&logo=amazon-cognito&logoColor=white)
![API Gateway](https://img.shields.io/badge/AWS-API_Gateway-FF4F00?style=for-the-badge&logo=amazon-api-gateway&logoColor=white)
![Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?style=for-the-badge&logo=aws-lambda&logoColor=white)
![VPC](https://img.shields.io/badge/AWS-VPC-232F3E?style=for-the-badge&logo=amazon-vpc&logoColor=white)
![DynamoDB](https://img.shields.io/badge/AWS-DynamoDB-4053D6?style=for-the-badge&logo=amazon-dynamodb&logoColor=white)
![S3](https://img.shields.io/badge/AWS-S3-569A31?style=for-the-badge&logo=amazon-s3&logoColor=white)
![IAM](https://img.shields.io/badge/AWS-IAM-FF9900?style=for-the-badge&logo=amazon-iam&logoColor=white)
![SNS](https://img.shields.io/badge/AWS-SNS-FF4F00?style=for-the-badge&logo=amazon-sns&logoColor=white)
![Secrets Manager](https://img.shields.io/badge/AWS-Secrets_Manager-DD344C?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Eraser.io](https://img.shields.io/badge/Eraser.io-00A8E8?style=for-the-badge&logo=eraser&logoColor=white)

## AWS Architecture

![Alt Text](https://github.com/Muhammad1umer-tech/serverless-web-architecture/blob/main/assets/architecture.png)

### Key Components:

- **Authentication**:
  - Users authenticate via **Amazon Cognito User Pool**.
  - Cognito issues JWT tokens used to authorize API requests.
  - API Gateway is configured with a Cognito Authorizer to validate tokens before forwarding requests.

- **API Layer**:
  - **API Gateway** (HTTP API) acts as the single entry point.
  - Validates JWT tokens and routes authorized requests to Lambda functions inside the VPC.
  - Backend remains inaccessible from the public internet.

- **Compute (Serverless)**:
  - Two Lambda functions deployed inside **Private Subnets** within a custom VPC:
    - **Query DB Lambda** – Handles read operations from DynamoDB and S3.
    - **Add DB Lambda** – Handles write operations to DynamoDB and S3, and publishes SNS notifications.
  - Lambdas access AWS services privately via VPC Endpoints.

- **Data Storage**:
  - **DynamoDB** – NoSQL database for structured data (on-demand billing).
  - **S3 Bucket** – Object storage for semi-structured/unstructured data.
  - Both accessed privately via Gateway VPC Endpoints.

- **Security**:
  - **IAM Roles & Policies** – Fine-grained permissions for S3, DynamoDB, SNS, and Secrets Manager.
  - **Secrets Manager** – Stores sensitive configuration securely.
  - All Lambda-to-service communication remains inside the AWS private network.

- **Notifications**:
  - **SNS Topic** used to send email notifications to admins and users.
  - Triggered by Add DB Lambda after successful write operations.

---

## Deployment Architecture

### 1. Authentication — Amazon Cognito

Users authenticate against a **Cognito User Pool**. Upon successful login, Cognito issues a JWT token. API Gateway validates this token using a Cognito Authorizer before routing requests to backend Lambda functions.


### 2. API Layer — API Gateway

API Gateway:

- Validates Cognito-issued JWT tokens.
- Routes requests to the appropriate Lambda functions inside the VPC.
- Ensures the backend is never directly exposed to the internet.

![Alt Text](./images/api-gateway.png)

### 3. Custom VPC & Private Subnets

A **Custom VPC** isolates all compute resources in a private network.

- **Private Subnets**:
  - Host both Lambda functions with no direct internet exposure.
- **Gateway VPC Endpoints**:
  - **S3** and **DynamoDB** — enables private communication without routing through NAT Gateway.
- **Interface VPC Endpoint**:
  - **Secrets Manager** — enables secure secret retrieval from within the VPC.

![Alt Text](./images/subnet.png)

### 4. Lambda Functions

Two Lambda functions implement the core business logic:

- **Query DB Lambda**:
  - Triggered by API Gateway for read requests.
  - Reads data from DynamoDB and fetches objects from S3.
  - Communicates privately via Gateway VPC Endpoints.

- **Add DB Lambda**:
  - Triggered by API Gateway for write requests.
  - Inserts records into DynamoDB and uploads files to S3.
  - Publishes notifications to SNS after successful writes.
  - Retrieves secure configuration from Secrets Manager.

Both functions run inside private subnets, use IAM execution roles, follow least-privilege access, and contain no hardcoded credentials.

![Alt Text](./images/lambda.png)

### 5. IAM Roles & Policies

A dedicated IAM execution role is attached to Lambda functions with the following fine-grained policies:

- **S3** – Read/write permissions scoped to a specific bucket.
- **DynamoDB** – Read/write permissions scoped to a specific table.
- **SNS** – Publish permissions scoped to a specific topic.
- **Secrets Manager** – Read permissions scoped to a specific secret.
- **CloudWatch Logs** – For Lambda invocation logging.
- **ENI Management** – Required for Lambda VPC network interface creation.

![Alt Text](./images/iam-policy.png)

### 6. Data Storage

- **DynamoDB**:
  Fully managed NoSQL database with on-demand billing. Accessed privately by Lambda via a Gateway VPC Endpoint.

- **S3 Bucket**:
  Stores unstructured and semi-structured data. Public access is fully blocked. A bucket policy restricts access to only the Lambda execution role ARN.

![Alt Text](./images/dynamodb.png)
![Alt Text](./images/s3.png)

### 7. Secrets Manager

Sensitive configuration (API keys, credentials) is stored in **AWS Secrets Manager**. Lambda retrieves secrets at runtime via an Interface VPC Endpoint — secrets are never hardcoded or exposed in environment variables.

![Alt Text](./images/secrets-manager.png)

### 8. SNS Notifications

An **SNS Topic** is configured with email subscriptions for admins and users. The Add DB Lambda publishes a message to SNS after successful write operations, which then fans out email notifications to all subscribers.

![Alt Text](./images/sns.png)

---

## Request Flow Summary

```
User
 └─► Cognito (Authentication)
      └─► API Gateway (JWT Authorization + Routing)
           └─► Lambda (Private Subnet)
                ├─► DynamoDB (Gateway VPC Endpoint)
                ├─► S3 (Gateway VPC Endpoint)
                ├─► Secrets Manager (Interface VPC Endpoint)
                └─► SNS (Interface VPC Endpoint → Email Notification)
```

---
