---
title: "Scaling @ HelloFresh: Distributed Tracing"
author: Italo Vietro
date: 2017-05-08T14:38:02+01:00
draft: false
type: post
tags: 
  - scalability
  - distributed-tracing
  - hellofresh
---

### How distributed tracing helped us to have better visibility of our architecture

Part of our journey towards scaling our architecture at HelloFresh is to make sure we have proper visibility of what is happening in our systems, to enable us to act quickly in case something goes wrong. We have many services and applications across our whole infrastructure. They all talk to each other at some point and keeping track of that can be extremely tricky.

Let’s suppose you’re trying to troubleshoot a latency problem for a specific API endpoint. You have no idea which in the chain of services are causing the slowdown. You have no clear understanding of whether it’s a bug, an integration issue, poor networking performance, or maybe “just” a bad architectural choice.

Solving this problem becomes even more difficult if your services are running as separate processes in a distributed system. Once we have dozens/hundreds/thousands of services it becomes impossible to depend on the traditional approaches that help us diagnose monolithic systems.

One of my favourite quotes about transparency/visibility is this:

{{< blockquote author="Dalai Lama">}}
  A lack of transparency results in distrust and a deep sense of insecurity.
{{< /blockquote >}}

If you think about it, that applies very well to distributed systems. If we don’t have transparent results or visibility of our systems, it’s natural that everybody will have a sense of insecurity and therefore be afraid of changing and improving them. This is one of the things that leads me to think that information is never too much.

That’s when Distributed Tracing comes into play.

## What’s Distributed Tracing?
Distributed tracing is the concept of tracking one user request throughout a distributed system. Capturing such traces allows us to build a view of the entire chain of calls behind the user interaction. This is a critical tool for debugging and understanding microservices. With it we can:

* Instrument and profile application latency in a complex architecture.
* Track all calls (RPCs and async) within the lifecycle of a user request and see integration issues that are only visible in production.
* Identify bottlenecks very easily and make improvements based on real data.

---

Of course, using the distributed tracing concept requires various libraries (very likely for different languages, depending on the composition of your services) to help gather the tracing data. This also means that these libraries have to follow some sort of standard, otherwise the data across different applications might not match.

That’s where [OpenTracing](http://opentracing.io/) can help us. OpenTracing is a set of consistent, expressive, vendor-neutral APIs for popular platforms. This makes it very easy for the developers to implement all concepts in the same way in whatever language/platform they choose. OpenTracing also offers a lingua franca for OSS instrumentation and platform-specific tracing helper libraries. Some of the available libraries are:

* [OpenTracing for Go](https://github.com/opentracing/opentracing-go)
* [OpenTracing for Javascript](https://github.com/opentracing/opentracing-javascript)
* [OpenTracing for Java](https://github.com/opentracing/opentracing-java)
* [OpenTracing for Python](https://github.com/opentracing/opentracing-python)
* [OpenTracing for PHP](https://github.com/hellofresh/opentracing-php) (Not official, it’s built by us!)

Please check the [OpenTracing website](http://opentracing.io/) for more supported libraries.

## The Tracer
After understanding how OpenTracing works we had to pick one application to be our Proof of Concept to try this out. We chose one of our services that has a good amount of traffic (to generate a lot of data).

With our [API Gateway]({{< ref "gateway/index.md" >}}), we had a central place where we could generate the parent tracing information to stream down to the microservices. Each service can then add to the trace to get a contiguous view of a request flowing through our systems. We implemented a simple middleware in the Gateway which creates this parent span and injects it into the proxy request.

{{< figure src="tracing.png" title="An example of how distributed tracing works within our architecture" >}}

After implementing OpenTracing, we had to ship those metrics somewhere. This is where a Tracer comes in.
There are a lot of tracer implementations out there, some good ones are:

* [Zipkin](http://zipkin.io/)
* [Stackdriver Trace](https://cloud.google.com/trace/) (Google Cloud Platform)
* [X-Ray](https://aws.amazon.com/xray/) (Amazon)
* [Jaeger](https://uber.github.io/jaeger/) (Uber)
* [Appdash](https://github.com/sourcegraph/appdash) (Perfect for local development and testing)

We chose to use **Stackdriver Trace** as our Tracer. We made that decision because we didn’t want to spend some time building and maintaining all the infrastructure required to have a reliable cluster for Zipkin or Jaeger. The [Google Cloud Platform](https://cloud.google.com/) provided us with a tracer that worked out of the box and could handle a huge amount of data. It was incredibly simple to use and integrate, which factored into our decision in a big way.

{{< figure src="tracer.png" title="An example of a tracing request across services — in this case, ending up at our Auth Service" >}}

## What should we do with the tracing data?

It really comes down to what do we want to see as information. Initially we had a beautiful tracer with a lot of data, but we didn’t know what to do with it. Here’s how to nail down what data is important for you:

* Identify what data you’d often visit the dashboard for. Do you want to debug a performance issue? Figure out the complexity of your request chain? Or just have a better visibility of your system?
* If you’ve found a bottleneck, use the tracing data as a guide for making improvements in your system. Many Tracers enable you to create reports/dashboards to see if a new version of your service actually improved or degraded latency compared to the previous version.
* Don’t try to use distributed tracing as your monitoring tool, even though you can setup alerts based on latency problems. A dedicated monitoring tool will always be better for that.

{{< figure src="dashboard.png" title="Dashboard on Stackdriver Trace" >}}

## Results

Implementing such a tool at HelloFresh is helping us to see a bigger picture of how complex our systems can be. It has already helped us identifying and fixing some latency issues that we didn’t even know we had before.

One important note that is worth mentioning: implementing distributed tracing on our monolithic applications is incredibly complicated. We still haven’t managed to do that, but we are working hard to make sure that happens. This way we can know for sure where we should make improvements, and maybe even think about extracting that functionality to its own service.

We still have a long way to go to make sure we make the most out of the data that is now available to us, but at least now we have the right tools to do so.

---

I hope you’ve enjoyed the article and I’m looking forward to the next one! Thank you.
