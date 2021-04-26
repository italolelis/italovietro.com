---
template: page
title: Talks and Podcasts
slug: talks-and-podcasts
socialImage: /media/image-4.jpg
draft: false
---

## Podcast Episodes
* [The critical channel](https://www.listennotes.com/podcasts/the-critical-channel-criticalchannelio-UIiaVfJRxrs/) - I'm a co-host at The Critical Channel. We talk about leadership, culture, engineering, and much more.

## Designing for failure
In recent years, we’ve been talking more and more about failure and resilience in a distributed system architecture. Unfortunately, failure has been neglected for quite some time in our industry. Systems have grown to be much more complex and challenging to deal with, especially in the Kubernetes era. With all this new complexity it comes the question: how can we design systems to be resilient and ready to fail? This is something that mission-critical systems always had to think of first, but many of our services (until today) neglect the importance of this. There are many concepts we can learn and use from other fields like electronics, aviation, or naval industries that will help us be prepared for the unexpected.

In this talk, I would like to talk about how to design a system for failure. What are the pitfalls and gotchas that we have to be prepared in a microservice environment? How can SRE principles help us get there? And most importantly, how do we put this into practice?

[Recording](https://www.youtube.com/watch?v=BOn3R41UrV8&feature=youtu.be) and [slides](https://github.com/italolelis/talks/tree/master/talks/designing-for-failure). Last presented at [Golang Poland Meetup 2020](https://www.meetup.com/Golang-Poland/events/273948416/).

## Discovering the Tech Lead in You
When you transition from a developer role to a tech lead, you realize how lonely it is, predominantly if you work in a smaller company. Your responsibilities and accountability grow, and when you have questions, you don't have many people to look out for when in need of help. What exactly being a tech lead means? What are the problems that you will have to solve in this role? How can you get better at it? In this talk, I'd like to share that experience with you and hopefully shed some light on this new journey you are going through (even if you already are a tech lead).

[Outline](https://github.com/italolelis/talks/tree/master/talks/discovering-the-tech-lead-in-you).

## Revealing the world of service meshes
Software engineering is a constantly changing world. We went from monoliths to SOA to microservices and now lambda. We started simple, 5 services, then 10 services, a 100 and now we see companies with 2000+ services. Service mesh technologies have gained a lot of interest over the past years. High-traffic companies started to add a service mesh to their production applications. But what is a service mesh, exactly? And why is it relevant to you?

In this talk, I want to explore the ups and downs of using a service mesh. My goal is to make sure you are well informed to make a smart decision if you want/need to use a service mesh.

[Slides](https://github.com/italolelis/talks/tree/master/talks/revealing-the-world-of-service-meshes).

## Building hexagonal architecture Go applications
Have you ever find yourself thinking about how you should structure your code? And what kind of architecture should you follow? If you come from object-oriented languages normally you will choose some classic models like MVC or Layered. In Go, we normally use a flat-file architecture and try to structure in a logical way, following the idiomatic Go. What if there is something that will encourage you to replicate your company's domain, gain more maintainability and it's easier to test? I'd like to bring you the hexagonal architecture in Go, showing how we can make projects more maintainable, testable, and easy to understand.

[Slides](https://github.com/italolelis/talks/tree/master/talks/hexagonal-architecture).
