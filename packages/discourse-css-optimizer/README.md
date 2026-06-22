# Discourse CSS Optimizer 🎯

> Total Bounty: **$6,000 USD** — Three tasks, one integrated pipeline.

## Overview

A comprehensive CSS optimization toolkit for the [Discourse](https://www.discourse.org/) forum platform. Integrates cssnano, PurgeCSS, and Rollup.js into a single, efficient pipeline.

## Tasks

### ✅ Task 1: Basic CSS Optimization Framework ($2,000)
- **cssnano** integration for CSS minification
- Incremental compilation with caching
- Rollup.js build system compatibility
- **Target: ≥30% compression rate**

### ✅ Task 2: Advanced CSS Optimization ($2,500)
- **PurgeCSS** integration for removing unused styles
- Selector optimization and duplicate rule merging
- Theme system optimization (CSS custom properties)
- **Target: ≥40% volume reduction**

### ✅ Task 3: Developer Tools ($1,500)
- **CLI tool** with optimize/analyze/watch/build/init commands
- **Dev server** integration with hot-reload
- **CI/CD** integration scripts
- Complete documentation and usage examples

## Installation

```bash
cd path/to/your/discourse-theme
npm install discourse-css-optimizer
```

## Usage

### CLI

```bash
# Analyze a CSS file
discourse-css-optimizer analyze stylesheet.css

# Optimize a CSS file
discourse-css-optimizer optimize stylesheet.css --output dist/optimized.css

# Production build with PurgeCSS
discourse-css-optimizer build stylesheet.css --content "./**/*.html.erb"

# Watch mode (incremental builds on file change)
discourse-css-optimizer watch stylesheet.css

# Initialize a Discourse theme config
discourse-css-optimizer init
```

### Programmatic API

```javascript
const DiscourseCSSOptimizer = require('discourse-css-optimizer');
const optimizer = new DiscourseCSSOptimizer();

// Basic optimization
const result = await optimizer.optimize(css);
console.log(`Compression: ${result.stats.compressionRatio}`);

// Advanced optimization with PurgeCSS
const result = await optimizer.advancedOptimize(css, ['./**/*.html.erb']);
console.log(`Total savings: ${result.stats.totalSavings} bytes`);

// Analyze
const analysis = optimizer.analyze(css);
console.log(`Rules: ${analysis.ruleCount}, Selectors: ${analysis.selectorCount}`);

// Generate Rollup config
const rollupConfig = optimizer.rollupConfig();
```

### Rollup.js Integration

```javascript
// rollup.config.js
import optimizer from 'discourse-css-optimizer';

export default {
  input: 'src/index.js',
  output: { dir: 'dist', format: 'esm' },
  plugins: [
    {
      name: 'discourse-css-optimizer',
      transform(code, id) {
        if (id.endsWith('.css')) {
          return optimizer.optimize(code).then(r => ({
            code: `export default ${JSON.stringify(r.css)};`,
            map: null
          }));
        }
      }
    }
  ]
};
```

## CI/CD Integration

### GitHub Actions

```yaml
name: CSS Optimization
on: [push]
jobs:
  optimize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm install discourse-css-optimizer
      - run: discourse-css-optimizer build stylesheet.css --content "./**/*.erb"
      - uses: actions/upload-artifact@v4
        with:
          name: optimized-css
          path: dist/*.css
```

## Project Structure

```
packages/discourse-css-optimizer/
├── cli.js                    # CLI tool (Task 3)
├── package.json              # Package manifest
├── src/
│   └── index.js              # Core optimizer (Tasks 1 & 2)
└── test/
    └── index.test.js         # Unit tests
```

## Verification

```bash
npm test
```

## License

MIT
