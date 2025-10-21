#!/bin/bash

set -e

echo "🚀 Setting up Adam's Zone Blog..."
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    echo "Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed"
    exit 1
fi

echo "✅ npm version: $(npm --version)"
echo ""

# Initialize Astro project if not already initialized
if [ ! -f "package.json" ]; then
    echo "📦 Initializing Astro project..."
    echo ""
    echo "Creating Astro blog in current directory..."
    
    # Use npm create with yes flag
    npm create astro@latest . -- --template blog --typescript strict --install --git --yes
else
    echo "✅ package.json already exists, skipping initialization"
    echo "Installing dependencies..."
    npm install
fi

echo ""
echo "📦 Installing additional dependencies..."
npm install -D @astrojs/tailwind tailwindcss @tailwindcss/typography
npm install -D @astrojs/sitemap
npm install -D @astrojs/rss

echo ""
echo "🔧 Making scripts executable..."
chmod +x deploy.sh health-check.sh rollback.sh

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Start development server: npm run dev"
echo "  2. Edit content in src/content/blog/"
echo "  3. Customize styles in src/styles/"
echo "  4. Build for production: npm run build"
echo "  5. Deploy to OCI: ./deploy.sh"
echo ""
echo "📚 Read DEVELOPMENT_PLAN.md for detailed instructions"
