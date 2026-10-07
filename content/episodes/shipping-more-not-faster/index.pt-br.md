---
title: "Entregando mais, não mais rápido"
subtitle: "Agentes escreviam 95% do código da Parloa, e o cycle time não se mexeu. O episódio do Italo no *Beyond Vibe Coding*, capítulo por capítulo, com as lições destacadas."
date: 2026-10-07T09:00:00+02:00
lastmod: 2026-10-07T09:00:00+02:00
draft: false
author: "Claude"
description: "Como a Parloa, uma empresa que constrói agentes de IA, constrói software com eles. Destaques do episódio de Italo Vietro no Beyond Vibe Coding, escritos pelo Claude a partir da transcrição, com cada citação ligada ao momento em que foi dita."
images: ["cover.jpg"]

episode:
  show: "Beyond Vibe Coding"
  number: "Temporada 2, Episódio 5"
  title: "Inside Parloa’s AI Kitchen"
  released: 2026-07-09
  duration: 3814
  hosts: ["Sebastian Heide-Meyer zu Erpen", "André Neubauer"]
  # A moment in the recording: %d is the second. Every quote links through it.
  at: "https://www.youtube.com/watch?v=JTGg7Dx4OTU&t=%ds"
  at_label: "YouTube"
  listen:
    - { label: "Página do episódio", url: "https://bvc.fm/2026/07/09/005.html" }
    - { label: "YouTube", url: "https://www.youtube.com/watch?v=JTGg7Dx4OTU" }
    - { label: "Spotify", url: "https://open.spotify.com/show/5wgcluRAVV7zEa9Zo4po5B" }
    - { label: "Apple Podcasts", url: "https://podcasts.apple.com/de/podcast/hmze/id1869935041" }
  hero:
    src: "kitchen.webp"
    alt: "Uma aquarela do passe de uma cozinha de restaurante: comandas presas num trilho, duas luminárias acesas sobre pratos montados, uma tigela fumegante e uma campainha de serviço de latão."

chapters:
  - id: "platform"
    n: "I"
    t: 77
    title: "Plataforma como produto"
    summary: "O Italo passou a maior parte da carreira em times de plataforma: HelloFresh, N26, Urban Sports Club, Babbel e agora a Parloa. Uma ideia atravessa todas elas. Plataforma é produto, não centro de custo."
    moments:
      - { t: "03:24", size: "pull", text: "Quando você vira a moeda e passa a pensar nelas como potenciais geradoras de receita, você também muda a forma como pensa a organização e como monta os times em volta." }
    lesson: "**Trate confiabilidade, segurança e infraestrutura como alavanca**, e não como coisas que uma empresa precisa ter. Isso muda como você pensa a organização e os times que monta."

  - id: "workflow"
    n: "II"
    t: 261
    title: "Escreva você mesmo"
    summary: "Escrever é a única coisa que o Italo não entrega à IA; ele a usa como um pato de borracha que discorda dele. Construir segue o mesmo ciclo em casa e no trabalho: especificar, pesquisar, implementar, validar, publicar. Na gestão, skills cuidam da parte administrativa (avaliações de desempenho, preparação de entrevistas, as prioridades da manhã) e param antes das decisões."
    plate: { src: "notebook.webp", size: "spot", alt: "Uma aquarela de um caderno de papel aberto, com linhas manuscritas e uma caneta deitada sobre ele.", caption: "Ele ainda anda com um caderno de papel." }
    moments:
      - { t: "06:35", text: "Escrever me ajuda a pensar melhor. Então eu ainda escrevo eu mesmo." }
      - { t: "12:38", text: "Não gosto de delegar à IA a decisão de contratar." }
    lesson: "**Automatize a burocracia, guarde o julgamento.** A IA pode preparar a entrevista. Quem contrata é uma pessoa."

  - id: "kitchen"
    n: "III"
    t: 960
    title: "A cozinha"
    summary: "Um engenheiro juntou skills num repositório e o chamou de cozinha. Quase ninguém usava, até que um time reescreveu um serviço problemático numa única Accelerator Week, sem tocar no código, passou pelas verificações da Parloa no SonarQube e o colocou em produção para uma fatia dos clientes. Depois, o *Show me how you cook* tornou a coisa social. Logo, 95% do código da Parloa saía da cozinha."
    plate: { src: "toque.webp", size: "spot", alt: "Uma aquarela de um chapéu de chef branco sobre uma prateleira de madeira e um avental âmbar pendurado num gancho logo abaixo.", caption: "Um chapéu de chef para quem mostra algo. O avental de master chef para impacto real em clientes." }
    moments:
      - { t: "18:55", size: "pull", text: "A cozinha não é nada além de um monte de skills juntas. [Ela] é o harness." }
    lesson: "**Prove o harness em algo real e depois torne a adoção social.** Um repositório bonito que meia dúzia de pessoas conhece não é um sistema."

  - id: "faster"
    n: "IV"
    t: 1408
    title: "Mais, não mais rápido"
    ask:
      type: guess
      kicker: "Antes, a sua intuição"
      question: "Agentes escreviam 95% do código da Parloa. Quão mais rápido você esperaria que ela entregasse?"
      scale: log
      min: 1
      max: 10
      start: 3
      ticks: [1, 2, 5, 10]
      unit: "%s× mais rápido"
      zero: "nada mais rápido"
      answer: 1
      you: "Você esperava"
      verdict: "O cycle time não se mexeu. A Parloa estava entregando mais, não mais rápido."
      t: "24:51"
    figures:
      - type: model
        kicker: "Por quê, num modelo de brinquedo"
        title: "Uma mudança, da ideia à produção. Acelere uma etapa e veja o total."
        unit: "%s dias"
        note: "Os dias são inventados. Só a aritmética é real: acelerar uma etapa reduz o total, no máximo, o quanto essa etapa pesava nele."
        stages:
          - { label: "Especificar", value: 2.0 }
          - { label: "Programar", value: 1.5, cut: 10, toggle: "Agentes escrevem o código", accent: true }
          - { label: "Revisar", value: 3.0, cut: 5, toggle: "PRs pequenos, agentes revisores, um juiz" }
          - { label: "Validar", value: 2.0, cut: 4, toggle: "Validação determinística" }
          - { label: "Publicar", value: 1.5 }
      - type: flow
        kicker: "Como um pull request chega aos clientes"
        title: "Escolha um tipo de mudança e acompanhe o caminho."
        controls: "Tipo de mudança"
        paths:
          - { key: "low", label: "Uma mudança rotineira" }
          - { key: "high", label: "Uma mudança arriscada" }
        steps:
          - { name: "Um pull request pequeno", note: "Pequeno o bastante para uma pessoa ler, o que o torna perfeito para um agente." }
          - name: "Um painel de agentes revisores"
            items:
              - { name: "SRE.", note: "SLOs e SLIs, circuit breakers, bulkheads." }
              - { name: "Segurança.", note: "Existe modelagem de ameaças? Se não, comenta e bloqueia." }
              - { name: "E outros.", note: "Cada um com uma preocupação não determinística." }
          - { name: "Um juiz, também um LLM", note: "Espera o painel, verifica se há consenso e classifica o risco." }
          - fork:
              - { path: "high", name: "Uma pessoa revisa", note: "Mudanças arriscadas vão para um humano." }
              - { path: "low", name: "O merge é automático", note: "Onde o time optou pelo merge automático." }
          - { name: "Um rollout com raio de impacto pequeno", note: "Canary releases, feature flags, escalonado. Com ou sem IA." }
          - { name: "Taxa de falha de mudanças, acompanhada", note: "Quando ela dá um pico, rollback e reavaliação." }
    summary: "A faca de dois gumes. Escrever código nunca foi a parte lenta, então acelerar essa parte não mexeu no cycle time. A Parloa automatizou o resto do ciclo: pull requests menores, um painel de agentes revisores com um juiz (também um LLM) que manda as mudanças arriscadas para uma pessoa, e rollouts com raio de impacto pequeno, acompanhados pela taxa de falha de mudanças."
    plate: { src: "bottle.webp", alt: "Uma aquarela de uma garrafa de vidro verde abarrotada de comandas de papel, com uma única comanda espremida saindo pelo gargalo estreito.", caption: "O gargalo nunca foi o código." }
    moments:
      - { t: "23:51", size: "pull", text: "Essa nunca foi a parte realmente difícil de resolver. Tudo em volta era muito mais difícil." }
      - { t: "24:51", text: "Estamos entregando mais, mas não mais rápido." }
      - { t: "29:02", text: "A IA é boa em amplificar as coisas boas e as ruins dos seus processos." }
    lesson: "**Meça cycle time, não volume.** Programar mais rápido só compensa quando revisão, validação e publicação acompanham."

  - id: "knives"
    n: "V"
    t: 1765
    title: "Cada um com a sua faca"
    ask:
      type: choice
      question: "Qual agente de programação a Parloa obrigava os engenheiros a usar?"
      options: ["Claude Code", "Codex", "Cursor", "Nenhum deles"]
      answer: 3
      verdict: "Nenhum. Os engenheiros usavam Claude Code, Codex, Copilot e Cursor; o que a Parloa exigia era o resultado."
      t: "30:33"
    summary: "A Parloa debateu tornar a cozinha obrigatória, e padronizar um único agente de programação, e não fez nenhuma das duas coisas. Os engenheiros usavam Claude Code, Codex, Copilot e Cursor. O que se exigia era o resultado, com verificações determinísticas contra um modelo de maturidade. E quando o Claude Code tinha um dia ruim, um proxy que recorre ao Codex manteve todo mundo trabalhando."
    plate: { src: "knives.webp", alt: "Uma aquarela de cinco facas de cozinha diferentes numa barra magnética: uma faca de chef, um cutelo, uma faca de pão, uma faca de legumes e uma santoku.", caption: "A faca é escolha de cada engenheiro. O que se confere é o prato." }
    moments:
      - { t: "31:41", text: "Não te obrigamos a usar, mas você deveria sentir que, usando, fica mais rápido." }
      - { t: "33:33", text: "Todo mundo esqueceu como programar." }
    lesson: "**Exija o resultado, não a ferramenta.** Faça o caminho pavimentado ser mais rápido que qualquer alternativa, e se prepare para o dia ruim do seu fornecedor."

  - id: "dark"
    n: "VI"
    t: 2508
    title: "A cozinha às escuras"
    summary: "A visão: um PRD entregue na sexta-feira, construído, revisado e publicado por agentes até segunda. A tecnologia está perto. A pergunta é quanto risco correr, e em julho o Italo disse que alguns times chegariam lá em setembro. Se as luzes se apagarem, o investimento vai para o design e para contratar arquitetos com mentalidade de produto. Qualidade, confiabilidade e segurança ficam a cargo de um programa e de error budgets acordados com produto, não de um time central."
    plate: { src: "factory.webp", alt: "Uma aquarela de uma fábrica com telhado em dente de serra ao entardecer, todas as janelas apagadas menos uma, onde uma pessoa trabalha sozinha numa mesa sob luz quente.", caption: "Luzes apagadas. Menos onde alguém ainda precisa entender o que está acontecendo." }
    moments:
      - { t: "42:38", size: "pull", text: "Eu chego na sexta-feira como desenvolvedor e digo: tenho este PRD aqui e preciso levar este PRD para produção até segunda." }
      - { t: "43:31", text: "Dá para chegar lá com a tecnologia de hoje com bastante facilidade. Mas quanto risco queremos correr com isso?" }
      - { t: "48:15", text: "Impor regras não gera responsabilidade." }
    lesson: "**A dark kitchen é uma questão de apetite por risco, não de tecnologia.** Deixe que error budgets acordados com produto decidam quando um time para de publicar."

  - id: "people"
    n: "VII"
    t: 3137
    title: "O que não se automatiza"
    summary: "O choque de realidade. A IA coloca bobagem em produção quando ninguém está prestando atenção, e democratiza trabalho difícil, como a stack de VoIP da Parloa, só até algo quebrar e alguém precisar de um especialista. Ser AI native acabou não sendo o que diferencia uma empresa."
    moments:
      - { t: "52:58", text: "Se ninguém está realmente entendendo ou se importando com o que ela produz, ela pode colocar muita coisa errada em produção." }
      - { t: "53:37", text: "Quando você começa a colocar coisas em produção e elas quebram, é nesse momento que você vai perceber: não faço a menor ideia do que isso realmente faz, e preciso de um especialista." }
      - { t: "55:40", size: "pull", text: "Contrate as pessoas certas… Cultive uma boa cultura de engenharia e depois esqueça a tecnologia, porque elas vão se adaptar à tecnologia." }
    lesson: "**Ser AI native não é um fosso competitivo.** As pessoas que você contrata são."

  - id: "hosts"
    n: "VIII"
    t: 3370
    title: "O balanço dos apresentadores"
    summary: "Sebastian e André guardaram o caminho de uma cozinha opcional até um harness sólido, o painel de revisão com um humano no circuito para mudanças arriscadas, o proxy e o time de AI Transformation. Um deles não estava convencido de quanta liberdade os times têm antes da revisão, e disse isso. Marcaram setembro para uma continuação."
---

Em julho de 2026, Sebastian Heide-Meyer zu Erpen e André Neubauer receberam o Italo no *Beyond Vibe Coding* para falar de como a Parloa, uma empresa que constrói agentes de IA, constrói software com eles. Quando gravaram, agentes escreviam 95% do código da Parloa, e o cycle time não tinha se mexido.

Estes são os destaques, capítulo por capítulo, com uma lição tirada de cada um. As citações foram ditas em inglês e traduzidas aqui, e cada uma leva ao segundo em que foi dita.
