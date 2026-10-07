---
title: "Shipping more, not faster"
subtitle: "Agents were writing 95% of Parloa’s code, and cycle time didn’t move. Italo’s episode of *Beyond Vibe Coding*, chapter by chapter, with the lessons pulled out."
date: 2026-10-07T09:00:00+02:00
lastmod: 2026-10-07T09:00:00+02:00
draft: false
author: "Claude"
description: "How Parloa, a company that builds AI agents, builds with them. Highlights of Italo Vietro’s Beyond Vibe Coding episode, written by Claude from the transcript, every quote linked to the moment it was said."
images: ["cover.jpg"]

episode:
  show: "Beyond Vibe Coding"
  number: "Season 2, Episode 5"
  title: "Inside Parloa’s AI Kitchen"
  released: 2026-07-09
  duration: 3814
  hosts: ["Sebastian Heide-Meyer zu Erpen", "André Neubauer"]
  # A moment in the recording: %d is the second. Every quote links through it.
  at: "https://www.youtube.com/watch?v=JTGg7Dx4OTU&t=%ds"
  at_label: "YouTube"
  listen:
    - { label: "Episode page", url: "https://bvc.fm/2026/07/09/005.html" }
    - { label: "YouTube", url: "https://www.youtube.com/watch?v=JTGg7Dx4OTU" }
    - { label: "Spotify", url: "https://open.spotify.com/show/5wgcluRAVV7zEa9Zo4po5B" }
    - { label: "Apple Podcasts", url: "https://podcasts.apple.com/de/podcast/hmze/id1869935041" }
  hero:
    src: "kitchen.webp"
    alt: "A watercolour of a restaurant kitchen pass: order tickets clipped along a rail, two lamps glowing over plated dishes, a steaming bowl and a brass service bell."

chapters:
  - id: "platform"
    n: "I"
    t: 77
    title: "Platform as a product"
    summary: "Most of Italo’s career has been in platform teams: HelloFresh, N26, Urban Sports Club, Babbel, and now Parloa. One idea runs through all of them. A platform is a product, not a cost center."
    moments:
      - { t: "03:24", size: "pull", text: "Once you flip the coin and think about them as potentially revenue generators, you also change how you think organically in the organization and how you build the teams around." }
    lesson: "**Treat reliability, security and infrastructure as leverage**, not as things a company has to have. It changes how you think about the organization, and the teams you build."

  - id: "workflow"
    n: "II"
    t: 261
    title: "Write it yourself"
    summary: "Writing is the one thing Italo doesn’t hand to AI; he uses it as a rubber duck that argues back. Building follows the same loop at home and at work: spec it out, research, implement, validate, deploy. In management, skills take the administrative load (performance reviews, interview preparation, the morning priorities) and stop short of the decisions."
    plate: { src: "notebook.webp", size: "spot", alt: "A watercolour of an open paper notebook with handwritten lines, a pen resting across it.", caption: "He still carries a paper notebook." }
    moments:
      - { t: "06:35", text: "Writing helps me think better. So I still do the writing myself." }
      - { t: "12:38", text: "I don’t like to offload the decision of hiring for AI." }
    lesson: "**Automate the admin, keep the judgement.** AI can prepare the interview. A person makes the hire."

  - id: "kitchen"
    n: "III"
    t: 960
    title: "The kitchen"
    summary: "One engineer collected skills in a repository and called it the kitchen. Hardly anyone used it until a team rewrote a struggling service in one Accelerator Week without touching the code, passed Parloa’s checks in SonarQube and shipped it to a slice of customers. Then *Show me how you cook* made it social. Soon 95% of Parloa’s code was coming out of the kitchen."
    plate: { src: "toque.webp", size: "spot", alt: "A watercolour of a white chef’s toque on a wooden shelf and an amber apron hanging from a peg beneath it.", caption: "A chef’s hat for showing something. The master chef apron for customer impact." }
    moments:
      - { t: "18:55", size: "pull", text: "The kitchen is nothing but a bunch of skills together. [It] is the harness." }
    lesson: "**Prove a harness on something real, then make adoption social.** A nice repository that a few people know about is not a system."

  - id: "faster"
    n: "IV"
    t: 1408
    title: "More, not faster"
    ask:
      type: guess
      kicker: "First, your intuition"
      question: "Agents were writing 95% of Parloa’s code. How much faster would you have expected it to ship?"
      scale: log
      min: 1
      max: 10
      start: 3
      ticks: [1, 2, 5, 10]
      unit: "%s× faster"
      zero: "no faster"
      answer: 1
      you: "You expected"
      verdict: "Cycle time didn’t move. Parloa was shipping more, not faster."
      t: "24:51"
    figures:
      - type: model
        kicker: "Why, in a toy model"
        title: "One change, from idea to production. Speed up a stage and watch the total."
        unit: "%s days"
        note: "The days are invented. Only the arithmetic is real: speeding up one stage moves the total by no more than that stage was ever part of it."
        stages:
          - { label: "Spec", value: 2.0 }
          - { label: "Code", value: 1.5, cut: 10, toggle: "Agents write the code", accent: true }
          - { label: "Review", value: 3.0, cut: 5, toggle: "Small PRs, review agents, a judge" }
          - { label: "Validate", value: 2.0, cut: 4, toggle: "Deterministic validation" }
          - { label: "Roll out", value: 1.5 }
      - type: flow
        kicker: "How a pull request reaches customers"
        title: "Pick a kind of change and follow it through."
        controls: "Kind of change"
        paths:
          - { key: "low", label: "A routine change" }
          - { key: "high", label: "A risky change" }
        steps:
          - { name: "A small pull request", note: "Small enough for a person to read, which makes it perfect for an agent." }
          - name: "A panel of review agents"
            items:
              - { name: "SRE.", note: "SLOs and SLIs, circuit breakers, bulkheads." }
              - { name: "Security.", note: "Is there a threat model? If not, it comments and blocks." }
              - { name: "And others.", note: "One non-deterministic concern each." }
          - { name: "An LLM judge", note: "Waits for the panel, checks that it agrees, and ranks the risk." }
          - fork:
              - { path: "high", name: "A person reviews it", note: "Risky changes go to a human." }
              - { path: "low", name: "It merges itself", note: "Where the team has opted in to auto-merge." }
          - { name: "A low-blast-radius rollout", note: "Canary releases, feature flags, staggered. With or without AI." }
          - { name: "Change failure rate, watched", note: "When it spikes, roll back and reassess." }
    summary: "The double-edged sword. Writing code was never the slow part, so making it faster did not move cycle time. Parloa automated the rest of the cycle instead: smaller pull requests, a panel of review agents with an LLM judge that sends risky changes to a person, and rollouts with a small blast radius, watched through change failure rate."
    plate: { src: "bottle.webp", alt: "A watercolour of a green glass bottle packed with paper order tickets, a single ticket squeezing out through the narrow neck.", caption: "The neck of the bottle was never the code." }
    moments:
      - { t: "23:51", size: "pull", text: "That was never the really difficult part to solve. Everything around it was much more difficult." }
      - { t: "24:51", text: "We’re shipping more, but not faster." }
      - { t: "29:02", text: "AI is good to amplify the good and the bad things on your processes." }
    lesson: "**Measure cycle time, not output.** Faster coding only pays once review, validation and rollout keep up."

  - id: "knives"
    n: "V"
    t: 1765
    title: "No single knife"
    ask:
      type: choice
      question: "Which coding agent did Parloa make its engineers use?"
      options: ["Claude Code", "Codex", "Cursor", "None of them"]
      answer: 3
      verdict: "None. Engineers used Claude Code, Codex, Copilot and Cursor; what Parloa enforced was the outcome."
      t: "30:33"
    summary: "Parloa debated making the kitchen mandatory, and standardizing on one coding agent, and did neither. Its engineers used Claude Code, Codex, Copilot and Cursor. What it enforced was the outcome, through deterministic checks against a maturity model. And when Claude Code had a bad day, a proxy that falls back to Codex kept everyone working."
    plate: { src: "knives.webp", alt: "A watercolour of five different kitchen knives on a magnetic strip: a chef’s knife, a cleaver, a bread knife, a paring knife and a santoku.", caption: "The knife is each engineer’s choice. The plate is what gets checked." }
    moments:
      - { t: "31:41", text: "We don’t force you to use it, but you should feel that by using it, you become faster." }
      - { t: "33:33", text: "Everybody forgot how to code." }
    lesson: "**Mandate the outcome, not the tool.** Make the paved road faster than any alternative, and plan for your vendor’s bad day."

  - id: "dark"
    n: "VI"
    t: 2508
    title: "The dark kitchen"
    summary: "The vision: a PRD handed over on Friday, built, reviewed and deployed by agents by Monday. The technology is close; the question is how much risk to take, and in July Italo said some teams would get there by September. If the lights go off, the investment moves to design, and to hiring product-minded architects. Quality, reliability and security are held by a program and by error budgets agreed with product, not by a central team."
    plate: { src: "factory.webp", alt: "A watercolour of a sawtooth-roofed factory at dusk with every window dark except one, where a single person sits at a desk in warm light.", caption: "Lights off. Except where somebody still has to understand what is going on." }
    moments:
      - { t: "42:38", size: "pull", text: "I go on a Friday as a developer and I say: I have this PRD here, and I need to get this PRD to production by Monday." }
      - { t: "43:31", text: "We can get to that with today’s technology fairly easily. But how much risk do we want to take with that?" }
      - { t: "48:15", text: "Enforcement doesn’t drive accountability." }
    lesson: "**The dark kitchen is a question of risk appetite, not technology.** Let error budgets agreed with product decide when a team stops shipping."

  - id: "people"
    n: "VII"
    t: 3137
    title: "What doesn’t automate"
    summary: "The reality check. AI ships nonsense when nobody is paying attention, and it democratizes hard work, like Parloa’s VoIP stack, only until something breaks and someone needs an expert. Being AI native turned out not to be what sets a company apart."
    moments:
      - { t: "52:58", text: "If nobody’s really understanding or caring about what it’s producing, it can ship so much wrong stuff." }
      - { t: "53:37", text: "Once you start shipping things, if they break, that’s the moment that you’re going to realize: oh, I have no freaking idea what this is actually doing, and I need an expert." }
      - { t: "55:40", size: "pull", text: "Hire the right people… Foster a good engineering culture, then forget about the technology, because they will adapt to the technology." }
    lesson: "**Being AI native is not a moat.** The people you hire are."

  - id: "hosts"
    n: "VIII"
    t: 3370
    title: "What the hosts kept"
    summary: "Sebastian and André kept the path from an optional kitchen to a solid harness, the review panel with a human in the loop for risky changes, the proxy, and the AI Transformation team. One of them was not sold on how much freedom teams get before review, and said so. They booked September for a follow-up."
---

In July 2026, Sebastian Heide-Meyer zu Erpen and André Neubauer had Italo on *Beyond Vibe Coding* to talk about how Parloa, a company that builds AI agents, builds software with them. By the time they recorded, agents were writing 95% of Parloa’s code, and cycle time had not moved.

These are the highlights, chapter by chapter, with a lesson drawn from each. Every quote links to the second it was said.
