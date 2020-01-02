---
title: "Setting up a High availability Hello World web app on AWS Fargate"
date: 2020-01-02T14:48:48+13:00
draft: false
---

After finishing this website, I decided that I wanted to learn more about AWS,
So I decided that I would create a project that allowed me to learn some more.

## AWS Infrastructure

Here's a simple diagram of the AWS infrastructure.
![AWS Infrastructure](/aws_vpc_diagram_aws_ecs_ha_app.png)

There are a few things not shown in this diagram, these being:

- The ECS Service itself

- The App Autoscaling policies to scale the amount of tasks in service up and down

- CloudWatch Alarms to trigger afformentioned policies
- CloudWatch Log Groups
- Application Load Balancer target group

You can view the terraform modules (and all the source code for the project!)
used to deploy this project in the
[github repository for this project](https://github.com/joelfreemanxyz/aws-ecs-ha-app).

## High Availability and Load Balancing

With regards to High Availability, There is a public and private subnet in two availability zones (ap-southeast-2a and ap-southeast-2b). This allows the application to still be up and running if one availability zone goes down.

There is also an Application Load Balancer to evenly distribute traffic to the Service as well as keeping the application online if some of my tasks fail.

To ensure the task is actually online, I have setup a healthcheck for the "/health" route that will occur every thirty seconds.

## Application Autoscaling

For autoscaling it is rather simple; I have two Cloudwatch alarms and two app autoscaling policies.
The first Cloudwatch alarms listens for the average cpu load in the service being 80% or above for 60 seconds,
While the second listens for the average cpu load in the service being 10% or less for 60 seconds.

As far as the app autoscaling policies go,
the first will increase the task count in the service by one,
and the second will decrease it by one.

If the first alarm is triggered,
it will trigger the app autoscaling policy that increases task count in the service by one.
If the second alarm is triggered,
it will trigger the app autoscaling policy that decreases task count in the service by one.

## Automated Deployments with GitLab CI and ecs-deploy

For this project, I really wanted to have a 'proper' CI/CD pipeline to handle deployments.

I chose GitLab CI for this.

A simple diagram of the CI/CD pipeline is below

![CI/CD pipeline diagram](/ci_cd_pipeline_aws_ecs_ha_app.png)

The CI/CD pipeline will do the following:

1. Test the application (using tests)
1. Build the application's docker image
1. Test the application in docker
1. Push the docker image to the [Docker hub repository](https://hub.docker.com/r/joelfreeman/aws-ecs-ha-app)
1. Deploy the application using [ecs-deploy](https://github.com/silinternational/ecs-deploy), which will do the following:

1. Create a new revision of my task definition with a specified image.
1. Update the service to use the newly created task definition.
1. This will create 4 new tasks using the new task definiton.
1. Once these tasks are running and pass healthchecks, the tasks using the old task definition will be killed and the deployment will succeed
1. If the tasks fail, ecs-deploy will edit the service to use the previous task definition and the deployment will fail.

And that's it! if you want some more information about the project, feel free to view the source code for everything [here.](https://github.com/joelfreemanxyz/aws-ecs-ha-app)

Also, please note that this project is only for personal learning purposes.
I have very little experience in the industry
and I recently got my first job working with AWS and Linux,
so the majority of the choices of what technology is used was based on what technology the company uses.

Thanks for reading!
