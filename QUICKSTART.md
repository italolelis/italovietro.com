# Quick Start Guide

This guide will help you get the italovietro.com project running locally on your machine.

## Prerequisites

- **macOS, Linux, or Windows** with WSL
- **Git** installed
- **Homebrew** (macOS/Linux) or **Chocolatey** (Windows)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone --recurse-submodules https://github.com/italolelis/italovietro.com.git
cd italovietro.com
```

If you already cloned without submodules, initialize them:

```bash
git submodule update --init --recursive
```

### 2. Install Hugo Extended

**macOS (Homebrew):**
```bash
brew install hugo
```

**Linux (Snap):**
```bash
snap install hugo --channel=extended
```

**Windows (Chocolatey):**
```bash
choco install hugo-extended
```

**Verify Installation:**
```bash
hugo version
```

You should see output like: `hugo v0.153.2+extended...`

### 3. Run the Development Server

```bash
hugo server -D
```

The `-D` flag includes draft posts in the build.

### 4. View the Site

Open your browser and navigate to:
```
http://localhost:1313
```

The site will auto-reload when you make changes to files.

## Common Commands

### Start Development Server
```bash
hugo server -D
```

### Build for Production
```bash
hugo --minify
```

### Create a New Blog Post
```bash
mkdir -p content/posts/my-new-post
touch content/posts/my-new-post/index.en.md
touch content/posts/my-new-post/index.pt-br.md
```

### Update Theme
```bash
git submodule update --remote themes/LoveIt
```

### Clean Generated Resources
```bash
rm -rf resources/_gen/
```

## Project Structure

```
italovietro.com/
├── content/          # Markdown content files
│   ├── posts/       # Blog posts (bilingual)
│   ├── consulting/  # Consulting page
│   ├── talks/       # Talks page
│   └── my-reading-list/  # Reading list
├── layouts/         # Custom layout overrides
├── assets/          # CSS, images, music
├── static/          # Static files (favicons, etc.)
├── themes/LoveIt/   # Theme (git submodule)
└── config.toml      # Main configuration
```

## Important Notes

### Bilingual Content
All blog posts must have both English and Portuguese versions:
- `index.en.md` - English
- `index.pt-br.md` - Portuguese

### Theme Modifications
**Never modify files in `themes/LoveIt/` directly.** Instead:
- Override layouts in `layouts/`
- Override CSS in `assets/css/_custom.scss`

### Generated Files
**Do not commit these directories:**
- `public/` - Build output
- `resources/_gen/` - Generated SCSS

## Troubleshooting

### Theme Not Loading
```bash
git submodule update --init --recursive
```

### CSS Changes Not Appearing
```bash
rm -rf resources/_gen/
hugo server -D
```

### Port 1313 Already in Use
```bash
hugo server -D -p 1314
```

### Build Errors
Check Hugo version:
```bash
hugo version
```
Ensure you have Hugo Extended (v0.100.0+)

## Development Workflow

1. **Create a new branch** for your changes
2. **Make your changes** to content or layouts
3. **Test locally** with `hugo server -D`
4. **Commit your changes** with a descriptive message
5. **Push to GitHub** - deployment happens automatically on `master` branch

## Need Help?

- Hugo Documentation: https://gohugo.io/documentation/
- LoveIt Theme Docs: https://hugoloveit.com/
- Project AGENTS.md: See `AGENTS.md` for detailed information

## License

MIT License - See `LICENSE` file for details.
