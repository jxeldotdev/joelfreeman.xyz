---
title: "About this site."
date: 2019-11-13T20:58:30+13:00
draft: true
---

This is a personal blog that documents my personal projects.
I started this project mainly as a way for me to learn a bit of AWS and Terraform.
The technologies used are:
- AWS (CloudFront, S3, Lambda@Edge, Route53, ACM)
- CircleCI
- Node.JS (the Lambda function is written in node)
- Hugo
- Terraform
- Git

# CI/CD Pipeline

Since I am using Hugo, the entire site is static files.
This allows me to have the entire site in a Git repository
and to make use of CI/CD for easy deployment and upates.
A brief explination of what the  is as such:
- I will make a change to the repository, and make a pull request to the master branch.
- My CircleCI pipeline will be triggered and do the following:
- Clone the repository and submodules
- Lint the markdown files
- If the linting did not fail, it will:
- Generate the static files
- Install and configure AWS CLI with environment variables
- And sync the Local files in the '/blog/' directory with the s3 bucket.

You can see a diagram of this below.

![CI/CD Diagram](cicddiagram.png)
## How the site works.

Here is a basic diagram of the infrastructure of the site.
![Infrastructure Diagram](infradiagram.png)

A user will go to 'joelfreeman.xyz', and route53 will redirect them to the CloudFront Distribution.
The CloudFront distribution will call the Lambda@Edge function which will change the URI.
If the URI does not end in "/" or ".html" or ".css" a "/index.html" will be appended to the URI.
This is because CloudFront does not support default indexes in subdirectories.
The file that the user is trying to access in the s3 bucket
will then be loaded through the CloudFront Distribution to the user.
If the file does not exist, it will load a 404 page.

## Deployment

I deployed my via terraform. you can view the module in the 
terraform directory of the repository for this site on my GitHub.

Thanks for Reading! :)
