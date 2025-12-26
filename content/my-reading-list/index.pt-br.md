---
title: Minha Lista de Leitura e Audição
slug: minha-lista-de-leitura
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

Sempre acreditei que **o conhecimento viaja mais rápido que o código**. Ao longo de mais de 17 anos, esses livros, newsletters e podcasts moldaram como penso sobre construir sistemas, liderar times e crescer como líder de engenharia.

Esta não é uma lista completa—apenas aqueles que ficaram. Os que eu revisito. Os que eu coloco nas mãos das pessoas quando perguntam "o que devo ler?"

---

* [Livros de Engenharia](#livros-de-engenharia)
* [Livros de Gestão](#livros-de-gestao)
* [Newsletters](#newsletters)
* [Podcasts](#podcasts)

## Livros de Engenharia

Livros que mudaram como escrevo código e penso sobre sistemas.

**Essenciais**

* [Clean Code](https://amzn.to/3f4tfO8) - Li isso cinco anos depois de começar minha carreira. Mudou tudo sobre como eu abordo legibilidade, testes e manutenção. Pare de escrever código para compiladores; escreva para humanos.

* [Domain-Driven Design](https://amzn.to/32NQx63) - O livro que me ensinou a falar a linguagem do negócio em código. Linguagem ubíqua e contextos delimitados não são buzzwords—são como você sobrevive a domínios complexos sem perder a sanidade.

* [Grokking Algorithms](https://amzn.to/3pvir0o) - O livro de algoritmos que não parece lição de casa. Exemplos claros, pedaços digestíveis. Perfeito para refrescar antes de entrevistas ou quando você precisa lembrar por que hash tables existem.

**Altamente Recomendados**

* [Refactoring](https://amzn.to/3lDbNmG) - Catálogo do Martin Fowler de "como melhorar código sem quebrar". Ainda referencio padrões específicos deste livro ao revisar PRs.

* [Clean Architecture](https://amzn.to/3f4tfO8) - Continuação do Uncle Bob ao Clean Code. Menos sobre código, mais sobre estrutura. Ajuda você a evitar os erros arquiteturais que eu cometi no início da carreira.

* [Site Reliability Engineering](https://amzn.to/3kzDD1R) - A bíblia de SRE do Google. Primeira metade vai parecer familiar se você já fez on-call. Lembre-se: o que funciona na escala do Google pode ser exagero para você. Mas os princípios? Sólidos.

* [Staff Engineer](https://amzn.eu/d/cAtTpf3) - Bateu diferente quando estava navegando entre IC vs gestão. Roteiro prático para ICs seniores que querem impacto sem inflação de título.

## Livros de Gestão

Os livros que me ajudaram a não ser ruim liderando pessoas.

**Essenciais**

* [The Manager's Path](https://amzn.to/3f0FnzM) - Seu roteiro de tech lead a CTO. Camille Fournier acerta em cada estágio. Releio capítulos diferentes dependendo de onde estou. Atualmente marcando a seção de VP.

* [An Elegant Puzzle](https://amzn.to/3kHB3Hb) - O guia do Will Larson é o livro mais prático de gestão de engenharia que encontrei. Táticas reais para contratação, dinâmica de time e escalar organizações. Só o apêndice vale o preço—uma mina de ouro de recomendações de papers.

* [The Phoenix Project](https://amzn.to/3kyPsVU) - DevOps embrulhado em romance. Parece cafona, mas funciona. Leia isso quando estiver lutando para explicar por que "só entregue mais rápido" não é estratégia.

**Altamente Recomendados**

* [The Engineering Executive's Primer](https://amzn.eu/d/2ET5UiD) - Base sólida para papéis VP+. Pensamento estratégico, design organizacional, dinâmica de conselho. Queria ter lido isso antes do meu primeiro papel de CTO.

## Newsletters

Tentei dezenas. Essas são as que eu realmente leio toda semana.

### Liderança Técnica

* [Software Lead Weekly](http://softwareleadweekly.com/) - Oren Ellenbogen curada cinco artigos afiados semanalmente sobre tech e liderança. Sem enrolação, só sinal.

* [Level Up](http://levelup.patkua.com/) - Pat Kua era Chief Scientist quando eu estava na N26. Uma das mentes mais afiadas com quem trabalhei. Seus 15-20 links semanais sobre liderança, tech e design organizacional são ouro.

* [The Weekly Hagakure](https://hagakure.substack.com/) - Paulo André e eu nos cruzamos na HelloFresh. Sua newsletter tem o mix perfeito: três artigos, dois vídeos, uma recomendação de livro. Sempre provocante.

### Engenharia de Software

* [Changelog](https://changelog.com/) - Pulso semanal sobre o que está acontecendo em engenharia. Bom para ficar atualizado sem se afogar em ruído.

## Podcasts

O que ouço enquanto faço café ou em voos longos.

### Liderança Técnica

* [The Critical Channel](https://www.listennotes.com/podcasts/the-critical-channel-criticalchannelio-UIiaVfJRxrs/) - Meu podcast. Falamos sobre liderança, cultura e a realidade bagunçada de construir times de engenharia. Histórias reais, sem papo corporativo.

### Engenharia de Software

* [The Ladybug Podcast](https://www.listennotes.com/podcasts/ladybug-podcast-emma-wedekind-kelly-vaughn-swCn6DupJQe/) - Perspectivas frescas de três mulheres engenheiras. Episódios mais curtos, tópicos diversos. Visão refrescante da indústria.

* [Kubernetes Podcast](https://www.listennotes.com/podcasts/kubernetes-podcast-from-google-adam-glick-0hPZxnL7suS/) - Notícias semanais de K8s e entrevistas da comunidade. Essencial se você vive no mundo cloud-native.

* [Go Time](https://www.listennotes.com/podcasts/go-time/defer-gotime-cC8RWfLohr3/) - Discussões semanais sobre Go. Seja você profundo em Go ou apenas curioso, conversas sólidas sobre a linguagem e ecossistema.
