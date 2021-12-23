---
title: "How do we manage our GitHub Organization at Lykon"
date: 2021-03-20T10:34:51.360Z
lastmod: 2021-03-20T10:34:51.360Z
draft: false
author: "Italo Vietro"
authorLink: "https://italovietro.com"
description: "GitHub is probably the most used code-sharing platform in the world today. Many companies are using it, and all of them have to manage users, repositories, branch rules, and much more. Standardizing all of this is quite challenging and involves creating things like CLI tools, scripts, and  [other ways](https://backstage.io/docs/features/software-templates/software-templates-index) to try to automate how people deal with GitHub."
resources:
- name: "featured-image"
  src: "featured-image.jpg"

tags:
  - terraform
  - code
  - infrastructure
  - organization
  - github

categories: ["Infrastructure"]

lightgallery: true
---

GitHub is probably the most used code-sharing platform in the world today. Many companies are using it, and all of them have to manage users, repositories, branch rules, and much more. Standardizing all of this is quite challenging and involves creating things like CLI tools, scripts, and  [other ways](https://backstage.io/docs/features/software-templates/software-templates-index)  to try to automate how people deal with GitHub.

Here at [Lykon](https://lykon.de), we decided to use [Terraform](https://www.terraform.io/) to manage and standardize all of the repository and user management, and today I want to share with you how we are doing this!

### Team and user management

> Any organization that designs a system (defined broadly) will produce a design whose structure is a copy of the organization's communication structure. 
— Melvin E. Conway

The statement above is also known as the [Conway's law](thoughtworks.com/insights/articles/demystifying-conways-law). I like to think that this same principle applies to how you organize your teams, which essentially defines how they interact with each other.

Managing the teams, and people that are in them to collaborate and avoid knowledge silos can be considered one of the most challenging things to do as you scale an organization.

If you are using GitHub enterprise, you most probably will use Single Sign-on (SSO). This does the job but isn’t great. Take Google Workspace, for instance, you can set up SSO, but you can’t sync groups with specific permissions as only Azure Active Directory is supported by the time I'm writing this article. But even without using Azure AD, you can have user management sorted out.
As you can see this is a tricky topic to come up with a cost-efficient solution. In our case, we decided to use [Terraform's GitHub provider](https://github.com/integrations/terraform-provider-github) to automate most of this work.

Firstly, we created the teams that reflect our department structure:

```terraform
# Creates a parent team
resource "github_team" "developers" {
  name        = "developers"
  description = "This is a parent team"
  privacy     = "closed"
}

# Creates a sub team of developers
resource "github_team" "backenders" {
  name           = "backenders"
  description    = "This is a sub team "
  parent_team_id = github_team.developers.id
  privacy        = "closed"
}

# ...
```

Every time we have someone new join, anyone at Lykon can open a PR and invite them to the team.

```terraform
# Invites a user to the organization
resource "github_membership" "foo" {
  username = "foo"
  role     = "member"
}

# Adds the user to a team
resource "github_team_membership" "developers-foo" {
  username = github_membership.foo.username
  team_id  = github_team.developers.id
  role     = "maintainer"
}
```

This will run in a GitHub Actions workflow, and the user will receive an invite to join our organization. This will also trigger other onboarding flows in different tools that happen after the user accepts the invitations.

## Repository creation

This is probably the main reason why we decided to use Terraform for managing GitHub. Creating standardized repositories brings many benefits, like onboarding and easy transition between projects. Engineers normally jump through many repositories per week. This can create a chaotic situation if the way they open issues, PRs, and search for information is different in every repository. To avoid this we decided to create most of our repositories in the same way.

A few things were very important to us that every repository had to have. Let's go through the mains ones.

### Release notes

We wanted to provide a way for developers to be able to easily create release notes, even for internal projects, to enhance transparency on what we are delivering. Release notes were a great way to achieve that. We use a tool called  [Release Drafter](https://github.com/release-drafter)  in our workflow.
We needed to configure how labels would be used in every repository, and for that, we standardized all labels across all repositories. We use: `docs`, `dependencies`, `bug`, `feature`, and `maintenance`.

Every time we open a PR, we need to select at least one of these labels to define how this PR is categorized. When a PR is merged, we use the GitHub Action release drafter, which creates a draft release with the commits from the PR into one of those categories. This helps us to create release notes for all of our services and libs!

This is how the release notes would look like:

![Release Drafter](https://github.com/release-drafter/release-drafter/blob/master/design/screenshot-2.png?raw=true)

Every time someone creates a new repo, the release drafter comes pre-configured and you can start enjoying good release notes without any effort.

### Tracebility

We all, as developers, want to create repositories for PoCs, new services, new libraries, and many other reasons. That's all fine, as long as it servers a purpose. We need to know which team owns that repository and is ultimately responsible for keeping it up to date, updating its security requirements. This serves both for better accountability, but also for our legal requirements.

### Branch protection

Setting up rules for when you can merge a branch is very important for code quality, and in our case for legal reasons (at Lykon, we deal with health data, so all changes must go through strict code quality checks). GitHub gives the possibility for you to configure branch protection rules to solve that.

We wanted to define the same set of basic branch protection for all repositories. this was easily solved with our terraform module.

### Terraform module

To achieve all of this, we created a [Terraform module](https://github.com/italolelis/terraform-github-modules) that manages repositories, and secrets. Here is an example on how we use the module:

```terraform
module "my-private-repo" {
  source  = "terraform-github-modules//modules/repo"
  version = "~> 1.0"

  name                   = "my-private-repo"
  description            = "A cool repository description"
  visibility             = "private"
  delete_branch_on_merge = true
  vulnerability_alerts   = true
  topics                 = ["any", "cool", "topic"]
  teams                  = { (data.github_team.developers.id) = "push" }
  collaborators          = { (data.github_user.bar.username) = "push" }

  labels = {
    "bug"          = "d73a4a"
    "docs"         = "0f727f"
    "feature"      = "a2eeef"
    "maintenance"  = "a5f7da"
    "dependencies" = "0366d6"
  }

  branch_protection = {
    master = {
      enforce_admins    = true
      push_restrictions = []
      required_status_checks = {
        strict   = true
        contexts = []
      }
      required_pull_request_reviews = {
        dismiss_stale_reviews      = true
        require_code_owner_reviews = true
        dismissal_restrictions     = []
      }
    }
  }
}
```

## GitHub Actions

GitHub Actions is our CI tool of choice. We use it to run the terraform scripts you've seen above. There is one workflow that runs on every PR:

```yaml
name: Pull Request
on:
  - pull_request

jobs:
  terraform:
    name: Terraform
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Lint Code Base
        uses: docker://github/super-linter:v3.14.4
        env:
          VALIDATE_ALL_CODEBASE: true
          VALIDATE_MD: true
          VALIDATE_TERRAFORM: true

      - uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 0.14.3

      - name: Terraform Format
        id: fmt
        run: terraform fmt -check

      - name: Terraform Init
        id: init
        run: terraform init
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Validate
        id: validate
        run: terraform validate -no-color

      - name: Terraform Plan
        id: plan
        run: terraform plan -no-color
        continue-on-error: true
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_github_token: ${{ secrets.GITHUB_TOKEN_PRIVATE }}

      - uses: actions/github-script@v3
        env:
          PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Format and Style 🖌 \`${{ steps.fmt.outcome }}\`
            #### Terraform Initialization ⚙️ \`${{ steps.init.outcome }}\`
            #### Terraform Validation 🤖 ${{ steps.validate.outputs.stdout }}
            #### Terraform Plan 📖 \`${{ steps.plan.outcome }}\`
            
            <details><summary>Show Plan</summary>
            
            \`\`\`${process.env.PLAN}\`\`\`
            
            </details>
            
            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`, Working Directory: \`${{ env.tf_actions_working_dir }}\`, Workflow: \`${{ github.workflow }}\`*`;
              
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
      - name: Terraform Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1
```

On a merge, we run the following workflow:

```yaml
name: Master
on:
  push:
    branches:
      - main

jobs:
  terraform:
    name: Apply
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 0.14.3

      - name: Terraform Init
        id: init
        run: terraform init
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Terraform Apply
        id: apply
        run: terraform apply -auto-approve -input=false
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          TF_VAR_github_token: ${{ secrets.GITHUB_TOKEN_PRIVATE }}
```

## Closing thoughts

Using Terraform to manage GitHub organizations can be quite interesting and help your developer teams to onboard quickly. It’s important to notice that this option is not optimal if you have too many developers or repositories, especially because the Terraform GitHub provider is not a very fast one due to GitHub API rate limits. Nevertheless, it’s a great tool for small and medium-sized tech organizations that want to step up their GitHub management.

Hopefully, in a not so distant future, manage cross-cutting repository rules, can be done directly from GitHub, which will cut the need for many fragmented ways to manage its resources.

I hope I could help you learn something new today, and share how we do things here at Lykon.

See you in the next post! 👋
