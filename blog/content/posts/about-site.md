---
title: "About this site."
date: 2019-11-13T20:58:30+13:00
draft: true
---
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec nec odio suscipit, mattis eros sit amet, volutpat lacus. Ut quis nulla nibh. Morbi sit amet diam eu urna laoreet vulputate bibendum sed turpis. Etiam fringilla ante at nisl bibendum, molestie pulvinar libero iaculis. Nunc posuere mauris nunc. Mauris varius iaculis lacinia. Vestibulum est dolor, varius et maximus a, sollicitudin vel lorem. Etiam dictum orci non ipsum facilisis, et tincidunt mauris egestas. 

## How the site works.

Since I am using Hugo for this site, hosting it is relatively simple. I simply have a S3 bucket
behind a CloudFront distribution. If I wish to make changes to the site or add a new post, that's
pretty easy also since I have all the project files stored in a git repository, which you can view
[here](https://github.com/joelfreemanxyz/joelfreeman.xyz). Whenever I push a change to the master
branch, a CircleCI pipeline is triggered which will do the following:

+ Clone the repository
+ Clone all submodules inside the repository (e.g the theme I am using)
+ Generate the static files
+ And upload the website contents to S3

Here is a basic diagram of the workflow.
[Diagram of CI/CD Pipeline]

With regards to how I deployed the site, I am proud to say everything in AWS was created with
Teraform. you can view the terraform file in the repository above.

Here is a basic diagram of the Infrastructure.
[Basic diagram of site infrastructure]

Thank you all very much for reading! :)
