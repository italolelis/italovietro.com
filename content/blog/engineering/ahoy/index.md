---
title: "Navigating the rough seas of environment scaling with Ahoy!"
author: Italo Vietro
date: 2018-02-07T13:45:05+01:00
draft: false
comments: true
type: post
tags: 
  - scalability
  - distributed-system
  - testing
  - hellofresh
---

### How did we manage to scale our environments @ HelloFresh?

In the past couple of years, our engineering team experienced a huge growth spurt. Within 2 years our team grew from 35 engineers to well over 150. One of the biggest challenges we faced was how to allow over 20 teams to test their code in a stable environment, independently of other teams.

{{< figure src="team-growth.png" title="HelloTech Team Growth" >}}

I’m going to tell you about how we solved scaling our staging and local environments using phoenix environments.

## The Problem

{{< figure src="ship.jpg" title="Photo by Abraham Wiebe on Unsplash" >}}

When we were smaller we had only 2 environments, what we called staging and production. This setup was great for simple applications and small teams. Once we moved to a [microservice](https://martinfowler.com/articles/microservices.html) architecture with 90+ services it quickly became apparent that it was not a scalable solution.

With more teams blocking staging for their testing, the environment quickly became unusable. The solution seemed simple, create an environment for each team called team staging.

## Team Staging: Not the solution

We hoped that by creating a staging environment (which is a subset of all services from the main staging) for each team, it would enable them to test whatever they wanted in isolation. Or so we thought; in reality, it was much more complicated than that.

The mains problems that we observed with this setup were:

* Teams would spend a considerable amount of time setting up environments. Even with the use of Ansible scripts for this, some code had to be written for each new staging.
* Data sharing was still a problem. The environments weren’t completely isolated as they shared the same RDS instances.
* Costs on our AWS account increased drastically, because we had more than 20 team stagings and counting.
* Hard to debug problems: We use consul as our service discovery tool. Consul was responsible for making the services visible between staging and team stagings. This made debugging a very hard task.
* Any change/problem that happened in the main staging would affect all teams since their environments were not completely isolated

Our environments were getting out of control. Teams were not as productive as they could be, they had to deal with all these new problems, and even with jumping through these hoops they still didn’t have a reliable environment.

That was when we realised we had to rethink our environments completely, from a blank slate.

## The Solution

{{< figure src="ship2.jpg" title="Photo by Ian Simmonds on Unsplash" >}}

We started to think about a solution that would be _scalable_ and at the same time _simple to use_. Right away we thought about [Phoenix environments](https://www.thoughtworks.com/de/radar/techniques/phoenix-environments) which would give us the most flexibility.

To build an Phoenix environment we chose [Kubernetes](https://kubernetes.io/) as our container orchestration tool. Kube is already backed by a large community, and we already had in-house experience with it.

### What is an environment @ HelloFresh?

It was important that we defined what an environment looks like for us to help us keep the scope of the project achievable. This is what we came up with:

* A cluster of Entry Machines: We use Nginx to expose our frontend microservices
* A cluster of API Gateways: We use Janus as our API Gateway to expose and manage our microservices
* Service Discovery Tool: Consul wouldn’t work with Kubernetes anymore. We had to make sure namespaces were aware of updates that happen on consul services.

This is all! Everything else you can add to it later but is not required to spin up a new environment.

### Ahoy! to the rescue

In a nutshell: Ahoy! is a set of tools to assist in spinning up a new environment containing one or more specified services, falling back to staging for any remaining services.

Ahoy! encapsulates two tools, [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/) and [helm](https://github.com/kubernetes/helm), into a single binary tailored to our needs. Running `ahoy up` and providing a config file quickly spins up a new environment — technically, a Kubernetes namespace on an existing cluster — whether that’s running on an EC2 machine or locally, via [minikube](https://kubernetes.io/docs/getting-started-guides/minikube/).

Let’s take a look at what Ahoy! is actually doing:

1. Creates a Kubernetes namespace with a random name.
2. Creates entry machine and API gateway clusters for a namespace. This makes sure that each namespace has their own gateway configurations
3. Imports consul services from staging. This imports all declared consul services into a namespace. You can check an example scenario below:

{{< figure src="architecture.png" title="Consul2Kube example" >}}

Now that we know what Ahoy! is doing under the hood let’s take a look at how a configuration file looks like.

```go
[[Charts]]   
Name = "my-service"                    # Service name (from Consul)   
Repo = "hellofresh/my-service"         # Repository name  [Charts.ValueOverrides]                
version_my_service = "v2.0.4"          # Overrides your values.yml file
[[Charts]]   
Name = "my-fragment"   
Repo = "hellofresh/my-fragment"   
Branch = "feature/make-everything-purple"        # Use the Helm charts from a certain branch, other than master.
```

With this configuration file, you can have a list of services that you want to spin up in your namespace, and you can declare a branch or a specific docker image tag that you want to test. Everything else that is not here will fall back to _staging_ (thanks to consul2kube).

The only thing left to do is to run the `up` command:

```sh
$ ahoy up
• Creating namespace...
• Namespace created         namespace=deadly-stoat
• Spinning up requested services...
• Installing charts for my-service... 
• Finished installing charts for my-service
• Installing charts for my-fragment...
• Finished installing charts for my-fragment
• Installing entry charts...
• Finished entry charts...
• Installing consul chart...
• Finished consul chart...
• Ahoy! New environment sighted at https://www-deadly-stoat.mycluster.io (not https if in minikube)
• (You may need to wait a few minutes for the DNS to propagate)
```

In less than 5 minutes, you have a new environment that acts exactly like staging. These namespaces run for 8 hours, after which they are automatically killed. You can bring down an environment manually by running:

```sh
$ ahoy down deadly-stoat
• Killing deadly-stoat
• Done!
```

### Benefits

Ahoy! brought us great benefits and many new possibilities. Here is a few of them:

* Spinning up a new environment takes less than 10 minutes
* Great AWS cost reduction, since the environments don’t live for too long and are containers
* On-boarding new joiners into the teams is way faster. They can set up a local environment using Ahoy! +Minikube in minutes

## The future

Ahoy! is a very powerful tool on top of Kubernetes. The goal was to make it as simple as possible to a point where you don’t need to know Kube to use it. So far, Ahoy! is being tested by a pilot group of 4 squads at HelloFresh and we plan to roll it out across the organisation in the coming weeks.

In the future we plan to use Kubernetes in our staging and production environments. Even though Ahoy! wasn’t created for this, implementing Ahoy! support across our microservices will make this transition a lot easier in the future.

### Open Source

We definitely plan to open source this tool. We are working out a solution that will enable us to open it to the community and start accepting contributions.

I hope you have enjoyed reading this article. Please leave your comments and feedback below. See you soon!
