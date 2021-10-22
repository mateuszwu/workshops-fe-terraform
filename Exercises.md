# Setting up front-end application on AWS using Terraform

## Goals

* Create infrastructure to serve FE application on Cloudfront
* Define secure IAM policies
* Learn basics about some AWS services
* Learn some terraform best practices

## Rules
* Tag resources
* Run TF destroy at the end of workshops
* Feel free to make a repo
* Watch out for what you commit
* Ask questions
* Try to do the tasks yourself
* Make notes, so we can later reuse them

## Architecture

![Architecture](/architecture.png)

## S3

### Summary

### Key points
* high durability, availability in a region
* bucket name, ownership can’t be changed
* unique name across AWS
* by default private and accessible only by owner
* data encryption, versioning, cross-region replication,, logging, object locking

### Useful tf notes

### Tasks
1. Create s3 private bucket that will be used to store static files
2. Create s3 bucket policy that allows only s3:GetObject action on all objects under app s3 path for AWS principal
3. Upload the production build of ember or react app to the correct folder:
```
aws s3 sync ./dist s3://BUCKET_NAME_HERE/APP_FOLDER_NAME/ --delete
```

### TF Resources
* [s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
* [s3_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)
* [iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)

### Solution
<details>
  <summary>Check if you have trouble finishing the tasks.</summary>

  https://github.com/LukeP91/workshops-fe-terraform/blob/ex-1/main.tf
</details>

## CloudFront

### Summary

### Key points
* Origin Access Identity (OAI)
* Lambda@Edge customizations
* Price Class

### Useful tf notes
* origin
* aliases
* lambda_function_association
* viewer_certificate
* ssl_support_method = "sni-only"
* custom_error_response

### Tasks
1. Create CloudFront distribution that has the previously created s3 as origin
2. Create CloudFront origin access identity
3. Create output for Cloudfront domain name
4. Create output for CloudFront distribution id
5. Verify that the site is working

### TF Resources
* [cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)
* [cloudfront_origin_access_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity)


### Solution
<details>
  <summary>Check if you have trouble finishing the tasks.</summary>

 https://github.com/LukeP91/workshops-fe-terraform/blob/ex-2/main.tf

 https://github.com/LukeP91/workshops-fe-terraform/blob/ex-2/outputs.tf

</details>

## Route53

### Summary

### Key points
* Multiple routing policies
* A/AAAA record can be used to route to some AWS resources (alias record)
* 'Alias' record lets you map your zone apex (example.com) DNS name to the DNS name for your ELB load balancer

### Useful tf notes

### Tasks
1. Create data resource for the route53 zone (use workshops.selleo.app domain)
2. Create route53 record for the app


### TF Resources
* [route53_zone data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)
* [route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)


### Solution
<details>
  <summary>Check if you have trouble finishing the tasks.</summary>

  https://github.com/LukeP91/workshops-fe-terraform/blob/ex-3/main.tf

</details>

## Certificate Manager

### Summary

### Key points
* Needs to be created in us-east-1 for CF
* You have 72 hours to validate certificate
* If domains don’t change you can recreate the certificate and the same entries will be created for validation
* You need to create certificate validation entry in your DNS

### Useful tf notes
* It requires global provider (us-east-1) for Cloudfront
* Feel free to use aws module for acm in the future.

### Tasks
1. Create global provider (us-east-1)
2. Create certificate for the app route53 record
3. Create certificate validation route53 record
4. Attach certificate to the CloudFront distribution
5. Add alias to the cloudfront

### TF Resources
* [route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)
* [acm_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate)


### Solution
<details>
  <summary>Check if you have trouble finishing the tasks.</summary>

  https://github.com/LukeP91/workshops-fe-terraform/blob/ex-4/versions.tf

  https://github.com/LukeP91/workshops-fe-terraform/blob/ex-4/main.tf

</details>

## IAM

### Summary

### Key points
* actions are denied by default
* start with general policy gradually restrict it
* strive to make policies as limited as possible

### Useful tf notes
* remember that access key and secret access are plain text in state
* use data aws_iam_policy_document for policies

### Tasks
1. Create IAM user that will be used by CI
2. The IAM user should have minimal policy attached that will allow him to put and delete objects in a bucket
3. Create policy that will allow cloudfront invalidation
4. Attach policy to the user above
5. Define outputs for the access key id and secret access key
6. Check if you can upload file with that user and invalidate cf distribution. Make some change in the FE app.
```
export AWS_ACCESS_KEY_ID=aws_iam_access_key.id
export AWS_SECRET_ACCESS_KEY=aws_iam_access_key.secret
export CF_DISTRO_ID=aws_cloudfront_distribution.id
aws s3 sync ./dist s3://BUCKET_NAME_HERE/APP_FOLDER_NAME/ --delete
aws cloudfront create-invalidation --distribution-id $CF_DISTRO_ID --paths '/*'
```
7. Restrict access to the app content in s3 only to the selected cloudfront distribution

### TF Resources
* [iam_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)
* [iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)
* [iam_user_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment)
* [iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)
* [iam_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key)

### Solution
<details>
  <summary>Check if you have trouble finishing the tasks.</summary>

  https://github.com/LukeP91/workshops-fe-terraform/blob/ex-5/main.tf
</details>
