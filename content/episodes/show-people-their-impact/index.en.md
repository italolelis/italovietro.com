---
title: "Show people their impact"
subtitle: "In 2023, as VP of Engineering at Urban Sports Club, Italo talked to *The Ventellect Podcast* about building an engineering culture. The episode, chapter by chapter, with the lessons pulled out."
date: 2026-10-07T10:00:00+02:00
lastmod: 2026-10-07T10:00:00+02:00
draft: false
author: "Claude"
description: "Building an engineering culture: direction instead of solutions, transparency about impact, room to fail, and why the reward gets slower the higher you go. Highlights of Italo Vietro’s 2023 episode of The Ventellect Podcast, written by Claude from the transcript, every quote linked to the moment it was said."
images: ["cover.jpg"]

episode:
  show: "The Ventellect Podcast"
  number: "Episode 62"
  title: "Building an elite Engineering culture"
  released: 2023-06-21
  duration: 3131
  hosts: ["Alex Bloisi"]
  # Not on YouTube. Spotify takes a start time in seconds as ?t=.
  at: "https://open.spotify.com/episode/2QwC5SWr7UoPCdLXCFzfUQ?t=%d"
  at_label: "Spotify"
  listen:
    - { label: "Episode page", url: "https://building-our-world.zencast.website/episodes/62-building-an-elite-engineering-culture-italo-vietro-vp-of-engineering-urban-sports-club" }
    - { label: "Spotify", url: "https://open.spotify.com/episode/2QwC5SWr7UoPCdLXCFzfUQ" }
    - { label: "Apple Podcasts", url: "https://podcasts.apple.com/podcast/id1530899119" }
  hero:
    src: "seedlings.webp"
    alt: "A watercolour of a potting bench: terracotta pots in a row, each with a seedling at a different stage of growth, from a sprout to a young plant, and a watering can beside them."

chapters:
  - id: "career"
    n: "I"
    t: 170
    title: "From Brazil to Berlin"
    ask:
      type: guess
      question: "When Italo joined HelloFresh around 2015, its tech team was 13 people. How big was it when he left, three and a half years later?"
      scale: log
      min: 13
      max: 1000
      start: 60
      ticks: [13, 100, 1000]
      unit: "%s people"
      answer: 300
      verdict: "About 300. Thirteen to three hundred, in three and a half years."
      t: "04:34"
    summary: "Computer science and a master’s in Brazil, then the Brazilian government, where Italo started as a junior engineer and left as a software architect. An offer that was meant to take him to London took him to HelloFresh in Berlin instead, around 2015. Then N26, where he was the first engineering manager, health tech at Lykon, and Urban Sports Club as VP of Engineering."
    moments:
      - { t: "04:25", text: "The tech team at HelloFresh was only 13 people back then. […] When I left them, three and a half years later, the whole tech organization was around 300 people." }
      - { t: "05:42", text: "In health tech there is a lot of things that I was not expecting. Like the regulation is so heavy on it, even more than fintech." }
    lesson: "**Hypergrowth is a school for scaling teams.** Thirteen engineers to three hundred in three and a half years is where he learned how."

  - id: "talent"
    n: "II"
    t: 393
    title: "The talent shortage"
    summary: "Alex asked why Brazil produces so many good engineers. Good universities, Italo said, in a country that struggles to keep the people it trains. Then Germany, short of skilled workers while tech companies were laying people off. That only looks like a contradiction: money stopped being cheap, and specialists stayed scarce."
    moments:
      - { t: "10:19", text: "No matter how much people there are in the market available, there is always going to be a shortage of specialists in specific areas." }
      - { t: "18:17", text: "I have to say it’s probably the place that I love the most to work and to live in, with my family." }
    lesson: "**A skills shortage and a wave of layoffs can both be true.** The shortage that lasts is of specialists."

  - id: "vp"
    n: "III"
    t: 1117
    title: "What a VP of Engineering does"
    ask:
      type: choice
      question: "His job as VP of Engineering had four parts. Which one took the most effort?"
      options: ["Technical direction", "People and culture", "Stakeholder management", "Innovation"]
      answer: 2
      verdict: "Stakeholder management: budgets, the relationships with the other departments, and making sure everything is understood and translated well to the teams."
      t: "21:25"
    summary: "His job had four parts: technical direction, people and culture, stakeholders, and innovation, which meant reading where the business was going and what technology could do about it. At Urban Sports Club, product and tech started initiatives together with the rest of the business rather than being handed requests to execute, and a relationship like that takes years to build."
    moments:
      - { t: "22:47", text: "One of the main misconceptions in many, many companies [is] that technology, or the technology department, is seen as a cost center." }
      - { t: "25:02", size: "pull", text: "I’m not going to give them the solutions, because I don’t know the solutions. They are way better than I in coming up with solutions. But I know where we should head to." }
      - { t: "25:41", text: "So they saw the numbers, right? In every single [all hands], they saw the numbers." }
    lesson: "**Give your teams the direction, not the solution, and show them the numbers.** Transparency is what lets them find a better answer than you would have."

  - id: "impact"
    n: "IV"
    t: 1594
    title: "Impact, without blame"
    summary: "Engineers want to work on something with impact, and showing them theirs cuts both ways: if the impact is not what they expected, they own it and learn from it, which only works where failing is allowed. That meant no culture of blame, OKRs for guidance (after a few years of struggling with the process, like most companies), and the same framework for a junior engineer as for a principal."
    moments:
      - { t: "28:23", text: "You have freedom, but you also have a guidance, and here you can fail and learn. And we all only learn by failing, to be very honest." }
      - { t: "28:46", size: "pull", text: "No culture of blame in place, no ego culture. That is really good to build an engineering culture in the end." }
    lesson: "**Freedom, guidance, and no blame.** People can only own their impact where they are allowed to miss."

  - id: "engineer"
    n: "V"
    t: 1851
    title: "What makes a great engineer"
    summary: "The million-dollar question, as Alex put it. Italo’s answer had three parts. Communication: explaining a technical problem in simple terms. Fundamentals: algorithms and data structures, whatever the language. And priorities: building what the company needs rather than what is fun to build."
    moments:
      - { t: "33:49", text: "Engineers like to sometimes over-engineer things because it’s cool and fun. And I did this myself multiple times, not necessarily fulfilling what the company needed, but more what I needed." }
      - { t: "36:52", text: "If you really want to succeed in your engineering career, you do have to talk to people." }
    lesson: "**Communication, fundamentals, priorities.** The language you know matters less than whether you can explain the problem, and choose the right one to solve."

  - id: "management"
    n: "VI"
    t: 2274
    title: "Into management"
    ask:
      type: choice
      question: "For an engineer, the reward comes the moment the build compiles. For a VP, how long can it take?"
      options: ["A day or two", "A few weeks", "Months, sometimes years"]
      answer: 2
      verdict: "Months, sometimes years. Which is why the reward has to come from somewhere else as well: the people who grow."
      t: "40:59"
    summary: "Italo went as far as staff level at HelloFresh before moving into management, and he thinks engineering managers should stay connected to code: a proof of concept, a code review, a pairing session where someone else drives. What changes is the reward, which gets slower the higher you go. The principal engineers at Urban Sports Club had one main goal, building other principal engineers."
    moments:
      - { t: "39:17", text: "That’s why there is engineering in the name of the title. A lot of people forget that." }
      - { t: "39:53", size: "pull", text: "Once I actually did that and my mind actually did the switch, then things became really interesting, because the success of my team became my own success." }
      - { t: "43:53", text: "You can only solve problems for your engineers in a culture aspect if you understand their problems, first of all." }
    lesson: "**Stay close enough to the code to understand the pain.** The reward moves from the compile, to the team, to the people who grow."

  - id: "next"
    n: "VII"
    t: 2797
    title: "Try it"
    summary: "What drives him is the next challenge, and learning, at work and well outside it (astronomy, for one). For a senior engineer weighing management, his advice was to try it if they get the chance, and to build the team they wished they had; a good organization lets you go back if it is not for you. Looking ahead, what excited him most was technology that helps people with health problems and disabilities, part of why he was working in health and wellbeing."
    moments:
      - { t: "48:09", text: "If you do have the opportunity, give it a try, because you might be surprised of how fulfilled you’ll be." }
      - { t: "48:30", size: "pull", text: "Think in different things that you can do for your team that, when you were a senior engineer, you wished your team had." }
      - { t: "49:16", text: "Life is short. Try it, try things out." }
    lesson: "**If you get the chance to lead, take it.** Start with what you wished your own team had."
---

In June 2023, when Italo was VP of Engineering at Urban Sports Club, Alex Bloisi had him on *The Ventellect Podcast* to talk about building an engineering culture, and about what it takes to keep the people who make one. The titles in it are of that time.

These are the highlights, chapter by chapter, with a lesson drawn from each. Every quote links to the second it was said.
