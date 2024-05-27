# Italo Vietro's Personal Website

Welcome to the repository for [Italo Vietro's personal website](https://italovietro.com). This site showcases my professional journey, projects, and insights into technology and engineering leadership.

## Table of Contents

- [About](#about)
- [Features](#features)
- [Setup](#setup)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## About

This website is built with [Hugo](https://gohugo.io/), a fast and modern static site generator written in Go. It is deployed using GitHub Pages and designed with the [LoveIt theme](https://themes.gohugo.io/hugo-theme-loveit/).

## Features

- **Professional Bio**: Detailed overview of my career, experience, and projects.
- **Blog**: Articles and posts on technology, engineering leadership, and more.
- **Reading List**: Recommended books and resources.
- **Talks**: Public talks and presentations I've given.
- **Consulting Services**: Information about my consulting services for businesses.

## Setup

To set up this project locally, follow these steps:

### Using DevContainers

1. Clone the repository

```bash
git clone https://github.com/italolelis/italovietro.com.git
cd italovietro.com
```

2. Open with DevContainers

* If you're using VS Code, open the project and click on the popup to reopen in container.

* Alternatively, press Ctrl+Shift+P and select Remote-Containers: Reopen in Container.

3. Run the development server:

```bash
hugo server -D
```

Visit http://localhost:1313 to see the site locally.

### Manual Setup

1. Clone the repository

```bash
git clone https://github.com/italolelis/italovietro.com.git
cd italovietro.com
```

2. Install Hugo:
Follow the instructions on the [Hugo installation guide](https://gohugo.io/getting-started/quick-start/).

3. Run the development server:

```bash
hugo server -D
```

Visit http://localhost:1313 to see the site locally.


## Deployment

This site is deployed using GitHub Actions. On every push to the master branch, the site is built and deployed to GitHub Pages.

### GitHub Actions Workflow
The workflow is defined in `.github/workflows/deploy.yml`. It includes steps to:

* Checkout the repository
* Set up Hugo
* Build the site
* Deploy to GitHub Pages

## Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes. For major changes, please open an issue to discuss what you would like to change.

## License

This project is licensed under the MIT [License](LICENSE). See the LICENSE file for details.
