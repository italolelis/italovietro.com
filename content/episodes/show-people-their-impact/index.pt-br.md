---
title: "Mostre às pessoas o impacto delas"
subtitle: "Em 2023, como VP of Engineering da Urban Sports Club, o Italo conversou com o *The Ventellect Podcast* sobre construir uma cultura de engenharia. O episódio, capítulo por capítulo, com as lições destacadas."
date: 2026-10-07T10:00:00+02:00
lastmod: 2026-10-07T10:00:00+02:00
draft: false
author: "Claude"
description: "Construir uma cultura de engenharia: direção em vez de soluções, transparência sobre o impacto, espaço para errar e por que a recompensa fica mais lenta quanto mais alto você sobe. Destaques do episódio de Italo Vietro no The Ventellect Podcast, de 2023, escritos pelo Claude a partir da transcrição, com cada citação ligada ao momento em que foi dita."
images: ["cover.jpg"]

episode:
  show: "The Ventellect Podcast"
  number: "Episódio 62"
  title: "Building an elite Engineering culture"
  released: 2023-06-21
  duration: 3131
  hosts: ["Alex Bloisi"]
  # Não está no YouTube. O Spotify aceita o início em segundos como ?t=.
  at: "https://open.spotify.com/episode/2QwC5SWr7UoPCdLXCFzfUQ?t=%d"
  at_label: "Spotify"
  listen:
    - { label: "Página do episódio", url: "https://building-our-world.zencast.website/episodes/62-building-an-elite-engineering-culture-italo-vietro-vp-of-engineering-urban-sports-club" }
    - { label: "Spotify", url: "https://open.spotify.com/episode/2QwC5SWr7UoPCdLXCFzfUQ" }
    - { label: "Apple Podcasts", url: "https://podcasts.apple.com/podcast/id1530899119" }
  hero:
    src: "seedlings.webp"
    alt: "Uma aquarela de uma bancada de jardinagem: vasos de terracota enfileirados, cada um com uma muda num estágio diferente de crescimento, de um broto a uma planta jovem, e um regador ao lado."

chapters:
  - id: "career"
    n: "I"
    t: 170
    title: "Do Brasil a Berlim"
    ask:
      type: guess
      question: "Quando o Italo entrou na HelloFresh, por volta de 2015, o time de tecnologia tinha 13 pessoas. Qual era o tamanho dele quando ele saiu, três anos e meio depois?"
      scale: log
      min: 13
      max: 1000
      start: 60
      ticks: [13, 100, 1000]
      unit: "%s pessoas"
      answer: 300
      verdict: "Umas 300. De treze para trezentas, em três anos e meio."
      t: "04:34"
    summary: "Ciência da computação e mestrado no Brasil, depois o governo brasileiro, onde o Italo começou como engenheiro júnior e saiu como arquiteto de software. Uma proposta que era para levá-lo a Londres acabou levando-o à HelloFresh, em Berlim, por volta de 2015. Depois a N26, onde foi o primeiro engineering manager, health tech na Lykon e a Urban Sports Club como VP of Engineering."
    moments:
      - { t: "04:25", text: "O time de tecnologia da HelloFresh tinha só 13 pessoas naquela época. […] Quando eu saí, três anos e meio depois, a organização de tecnologia inteira tinha umas 300 pessoas." }
      - { t: "05:42", text: "Em health tech há muita coisa que eu não esperava. Tipo, a regulação é muito pesada, ainda mais do que em fintech." }
    lesson: "**Hipercrescimento é uma escola de como escalar times.** Treze engenheiros para trezentos em três anos e meio foi onde ele aprendeu."

  - id: "talent"
    n: "II"
    t: 393
    title: "A falta de talentos"
    summary: "Alex perguntou por que o Brasil forma tantos bons engenheiros. Boas universidades, disse o Italo, num país que tem dificuldade de manter as pessoas que forma. Depois, a Alemanha: falta de profissionais qualificados enquanto empresas de tecnologia demitiam. Só parece contradição: o dinheiro deixou de ser barato, e especialistas continuaram raros."
    moments:
      - { t: "10:19", text: "Não importa quantas pessoas estejam disponíveis no mercado, sempre vai faltar especialista em áreas específicas." }
      - { t: "18:17", text: "Tenho que dizer que é provavelmente o lugar onde eu mais gosto de trabalhar e de viver, com a minha família." }
    lesson: "**Falta de talentos e uma onda de demissões podem ser verdade ao mesmo tempo.** A falta que dura é de especialistas."

  - id: "vp"
    n: "III"
    t: 1117
    title: "O que faz um VP of Engineering"
    ask:
      type: choice
      question: "O trabalho dele como VP of Engineering tinha quatro partes. Qual dava mais trabalho?"
      options: ["Direção técnica", "Pessoas e cultura", "Gestão de stakeholders", "Inovação"]
      answer: 2
      verdict: "Gestão de stakeholders: orçamento, a relação com os outros departamentos e garantir que tudo seja bem entendido e bem traduzido para os times."
      t: "21:25"
    summary: "O trabalho dele tinha quatro partes: direção técnica, pessoas e cultura, stakeholders e inovação, ou seja, entender para onde o negócio ia e o que a tecnologia podia fazer a respeito. Na Urban Sports Club, produto e tecnologia começavam as iniciativas junto com o resto da empresa, em vez de receber pedidos para executar, e uma relação assim leva anos para construir."
    moments:
      - { t: "22:47", text: "Um dos principais equívocos em muitas, muitas empresas [é] que a tecnologia, ou o departamento de tecnologia, é visto como centro de custo." }
      - { t: "25:02", size: "pull", text: "Eu não vou dar as soluções para eles, porque eu não sei as soluções. Eles são muito melhores do que eu em encontrar soluções. Mas eu sei para onde a gente deveria ir." }
      - { t: "25:41", text: "Então eles viram os números, certo? Em cada [all hands], eles viram os números." }
    lesson: "**Dê aos seus times a direção, não a solução, e mostre os números.** É a transparência que permite que eles encontrem uma resposta melhor do que a sua."

  - id: "impact"
    n: "IV"
    t: 1594
    title: "Impacto, sem culpados"
    summary: "Engenheiros querem trabalhar em algo com impacto, e mostrar a eles o impacto que têm é uma faca de dois gumes: se o impacto não é o esperado, eles assumem e aprendem com isso, o que só funciona onde errar é permitido. Isso significava nenhuma cultura de culpa, OKRs para dar direção (depois de alguns anos apanhando do processo, como a maioria das empresas) e o mesmo framework para um engenheiro júnior e para um principal."
    moments:
      - { t: "28:23", text: "Você tem liberdade, mas também tem orientação, e aqui você pode errar e aprender. E todos nós só aprendemos errando, para ser bem honesto." }
      - { t: "28:46", size: "pull", text: "Nenhuma cultura de culpa, nenhuma cultura de ego. Isso é muito bom para construir uma cultura de engenharia, no fim das contas." }
    lesson: "**Liberdade, orientação e nenhum culpado.** As pessoas só conseguem assumir o próprio impacto onde podem errar."

  - id: "engineer"
    n: "V"
    t: 1851
    title: "O que faz um grande engenheiro"
    summary: "A pergunta de um milhão de dólares, como Alex disse. A resposta do Italo tinha três partes. Comunicação: explicar um problema técnico em termos simples. Fundamentos: algoritmos e estruturas de dados, seja qual for a linguagem. E prioridades: construir o que a empresa precisa, e não o que é divertido de construir."
    moments:
      - { t: "33:49", text: "Engenheiros às vezes gostam de complicar demais as coisas porque é legal e divertido. E eu mesmo fiz isso várias vezes, não necessariamente entregando o que a empresa precisava, mas mais o que eu precisava." }
      - { t: "36:52", text: "Se você quer mesmo ter sucesso na sua carreira de engenharia, você precisa conversar com pessoas." }
    lesson: "**Comunicação, fundamentos, prioridades.** A linguagem que você sabe importa menos do que conseguir explicar o problema e escolher o problema certo para resolver."

  - id: "management"
    n: "VI"
    t: 2274
    title: "A ida para a gestão"
    ask:
      type: choice
      question: "Para um engenheiro, a recompensa vem no instante em que o build compila. Para um VP, quanto tempo ela pode levar?"
      options: ["Um ou dois dias", "Algumas semanas", "Meses, às vezes anos"]
      answer: 2
      verdict: "Meses, às vezes anos. Por isso a recompensa também precisa vir de outro lugar: das pessoas que crescem."
      t: "40:59"
    summary: "O Italo chegou ao nível de staff na HelloFresh antes de ir para a gestão, e acha que engineering managers devem se manter conectados ao código: uma prova de conceito, um code review, uma sessão de pair programming em que outra pessoa dirige. O que muda é a recompensa, que fica mais lenta quanto mais alto se sobe. Os principal engineers da Urban Sports Club tinham um objetivo principal: formar outros principal engineers."
    moments:
      - { t: "39:17", text: "É por isso que tem engenharia no nome do cargo. Muita gente esquece disso." }
      - { t: "39:53", size: "pull", text: "Quando eu realmente fiz isso e a minha cabeça virou a chave, as coisas ficaram muito interessantes, porque o sucesso do meu time virou o meu próprio sucesso." }
      - { t: "43:53", text: "Você só consegue resolver os problemas culturais dos seus engenheiros se entender os problemas deles, antes de tudo." }
    lesson: "**Fique perto o bastante do código para entender a dor.** A recompensa passa da compilação para o time, e do time para as pessoas que crescem."

  - id: "next"
    n: "VII"
    t: 2797
    title: "Experimente"
    summary: "O que move o Italo é o próximo desafio, e aprender, no trabalho e bem longe dele (astronomia, por exemplo). Para um engenheiro sênior em dúvida sobre a gestão, o conselho dele foi experimentar, se tiver a chance, e construir o time que gostaria de ter tido; uma boa organização deixa você voltar se não for para você. Olhando para frente, o que mais o empolgava era tecnologia que ajuda pessoas com problemas de saúde e deficiências, parte do motivo de ele trabalhar com saúde e bem-estar."
    moments:
      - { t: "48:09", text: "Se você tiver a oportunidade, experimente, porque você pode se surpreender com o quanto vai se sentir realizado." }
      - { t: "48:30", size: "pull", text: "Pense em coisas que você pode fazer pelo seu time e que, quando você era engenheiro sênior, gostaria que o seu time tivesse." }
      - { t: "49:16", text: "A vida é curta. Experimente, teste as coisas." }
    lesson: "**Se tiver a chance de liderar, aproveite.** Comece pelo que você gostaria que o seu próprio time tivesse."
---

Em junho de 2023, quando o Italo era VP of Engineering da Urban Sports Club, Alex Bloisi o recebeu no *The Ventellect Podcast* para falar sobre construir uma cultura de engenharia, e sobre o que é preciso para manter as pessoas que fazem essa cultura. Os cargos mencionados são os daquela época.

Estes são os destaques, capítulo por capítulo, com uma lição tirada de cada um. As citações foram ditas em inglês e traduzidas aqui, e cada uma leva ao segundo em que foi dita.
