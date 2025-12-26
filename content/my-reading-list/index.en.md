---
title: My Reading & Listening List
slug: my-reading-list
socialImage: /media/image-2.jpg
draft: false
---

<style>
.content {
    max-width: 800px;
    margin: 0 auto;
}

.content h2 {
    font-size: 2rem;
    margin-top: 3rem;
    margin-bottom: 1.5rem;
    padding-bottom: 0.75rem;
    border-bottom: 3px solid var(--global-border-color);
    color: var(--header-title-color);
}

.content h3 {
    font-size: 1.5rem;
    margin-top: 2.5rem;
    margin-bottom: 1.25rem;
    color: var(--header-title-color);
}

.content > ul {
    padding-left: 0;
    list-style: none;
}

.content > ul > li {
    margin-bottom: 2rem;
    padding: 1.5rem;
    background: var(--global-background-color);
    border: 1px solid var(--global-border-color);
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    transition: all 0.3s ease;
}

.content > ul > li:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
    border-color: var(--single-link-color);
}

.content > ul > li strong {
    font-size: 1.2rem;
    color: var(--header-title-color);
    display: block;
    margin-bottom: 0.5rem;
}

.content > ul > li a {
    color: var(--single-link-color);
    text-decoration: none;
    font-weight: 600;
    border-bottom: 2px solid transparent;
    transition: border-color 0.2s ease;
}

.content > ul > li a:hover {
    border-bottom-color: var(--single-link-color);
}

.content p + ul {
    margin-top: 1rem;
}

.content > p:first-of-type {
    font-size: 1.1rem;
    line-height: 1.8;
    margin-bottom: 2rem;
}

.content > hr {
    margin: 2.5rem 0;
    border: none;
    border-top: 1px solid var(--global-border-color);
}

.content > ul:first-of-type {
    display: flex;
    flex-wrap: wrap;
    gap: 1rem;
    margin: 2rem 0;
    padding: 1.5rem;
    background: var(--global-background-color);
    border: 1px solid var(--global-border-color);
    border-radius: 12px;
}

.content > ul:first-of-type li {
    margin: 0;
    padding: 0;
}

.content > ul:first-of-type li a {
    display: inline-block;
    padding: 0.5rem 1rem;
    background: var(--single-link-color);
    color: white;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.2s ease;
}

.content > ul:first-of-type li a:hover {
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    opacity: 0.9;
}

@media (max-width: 768px) {
    .content h2 {
        font-size: 1.6rem;
    }

    .content > ul > li {
        padding: 1.25rem;
    }

    .content > ul:first-of-type {
        flex-direction: column;
    }

    .content > ul:first-of-type li a {
        display: block;
        text-align: center;
    }
}
</style>

I've always believed that **knowledge travels faster than code**. Over 17+ years, these books, newsletters, and podcasts have shaped how I think about building systems, leading teams, and growing as an engineering leader.

This isn't a complete list—just the ones that stuck. The ones I return to. The ones I push into people's hands when they ask, "what should I read?"

---

* [Engineering Books](#engineering-books)
* [Management Books](#management-books)
* [Newsletters](#newsletters)
* [Podcasts](#podcasts)

## Engineering Books

Books that changed how I write code and think about systems.

**Essential**

* [Clean Code](https://amzn.to/3f4tfO8) - Read this five years into my career. Changed everything about how I approached readability, testing, and maintenance. Stop writing code for compilers; write it for humans.

* [Domain-Driven Design](https://amzn.to/32NQx63) - The book that taught me to speak business language in code. Ubiquitous language and bounded contexts aren't buzzwords—they're how you survive complex domains without losing your mind.

* [Grokking Algorithms](https://amzn.to/3pvir0o) - The algorithms book that doesn't feel like homework. Clear examples, digestible chunks. Perfect refresher before interviews or when you need to remember why hash tables exist.

**Highly Recommended**

* [Refactoring](https://amzn.to/3lDbNmG) - Martin Fowler's catalog of "how to improve code without breaking it." I still reference specific patterns from this book when reviewing PRs.

* [Clean Architecture](https://amzn.to/3f4tfO8) - Uncle Bob's follow-up to Clean Code. Less about code, more about structure. Helps you avoid the architectural mistakes I made early in my career.

* [Site Reliability Engineering](https://amzn.to/3kzDD1R) - Google's SRE bible. First half will feel familiar if you've done on-call. Remember: what works at Google scale might be overkill for you. But the principles? Solid.

* [Staff Engineer](https://amzn.eu/d/cAtTpf3) - Hit differently when I was navigating the IC vs management fork. Practical roadmap for senior ICs who want impact without the title inflation.

## Management Books

The books that helped me not suck at leading people.

**Essential**

* [The Manager's Path](https://amzn.to/3f0FnzM) - Your roadmap from tech lead to CTO. Camille Fournier nails every stage. I reread different chapters depending on where I am. Currently dog-earing the VP section.

* [An Elegant Puzzle](https://amzn.to/3kHB3Hb) - Will Larson's guide is the most practical engineering management book I've found. Real tactics for hiring, team dynamics, and scaling orgs. The appendix alone is worth the price—a goldmine of paper recommendations.

* [The Phoenix Project](https://amzn.to/3kyPsVU) - DevOps wrapped in a novel. Sounds cheesy, but it works. Read this when you're struggling to explain why "just ship faster" isn't a strategy.

**Highly Recommended**

* [The Engineering Executive's Primer](https://amzn.eu/d/2ET5UiD) - Solid foundation for VP+ roles. Strategic thinking, org design, board dynamics. Wish I'd read this before my first CTO gig.

## Newsletters

I've tried dozens. These are the ones I actually read every week.

### Tech Leadership

* [Software Lead Weekly](http://softwareleadweekly.com/) - Oren Ellenbogen curates five sharp articles weekly on tech and leadership. No fluff, just signal.

* [Level Up](http://levelup.patkua.com/) - Pat Kua was Chief Scientist when I was at N26. One of the sharpest minds I've worked with. His weekly 15-20 links on leadership, tech, and org design are gold.

* [The Weekly Hagakure](https://hagakure.substack.com/) - Paulo André and I overlapped at HelloFresh. His newsletter has the perfect mix: three articles, two videos, one book rec. Always thought-provoking.

### Software Engineering

* [Changelog](https://changelog.com/) - Weekly pulse on what's happening in engineering. Good for staying current without drowning in noise.

## Podcasts

What I listen to while brewing coffee or on long flights.

### Tech Leadership

* [The Critical Channel](https://www.listennotes.com/podcasts/the-critical-channel-criticalchannelio-UIiaVfJRxrs/) - My podcast. We talk leadership, culture, and the messy reality of building engineering teams. Real stories, no corporate speak.

### Software Engineering

* [The Ladybug Podcast](https://www.listennotes.com/podcasts/ladybug-podcast-emma-wedekind-kelly-vaughn-swCn6DupJQe/) - Fresh perspectives from three women engineers. Shorter episodes, diverse topics. Refreshing take on the industry.

* [Kubernetes Podcast](https://www.listennotes.com/podcasts/kubernetes-podcast-from-google-adam-glick-0hPZxnL7suS/) - Weekly K8s news and community interviews. Essential if you live in the cloud-native world.

* [Go Time](https://www.listennotes.com/podcasts/go-time/defer-gotime-cC8RWfLohr3/) - Weekly Go discussions. Whether you're deep in Go or just curious, solid conversations about the language and ecosystem.
