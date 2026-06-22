#!/usr/bin/env node
/**
 * Discourse CSS Optimizer - CLI Tool
 * Task 3: Developer tools integration ($1,500)
 */

const fs = require('fs');
const path = require('path');
const DiscourseCSSOptimizer = require('./src/index');

const optimizer = new DiscourseCSSOptimizer();

function showHelp() {
  console.log(`
  Discourse CSS Optimizer v1.0.0
  
  Usage:
    discourse-css-optimizer <command> [options]

  Commands:
    optimize <file>        Optimize a CSS file
    analyze <file>         Analyze CSS for optimization potential
    watch <file>           Watch mode with incremental builds
    init                   Initialize config for a Discourse theme
    build                  Full production build

  Options:
    --output, -o           Output file path
    --purge                Enable PurgeCSS (requires --content)
    --content, -c          Content paths for PurgeCSS (glob patterns)
    --no-minify            Skip minification
    --verbose, -v          Verbose output
    --help, -h             Show help
    --version              Show version
  `);
}

async function cmdOptimize(file, options) {
  if (!fs.existsSync(file)) {
    console.error(`❌ File not found: ${file}`);
    process.exit(1);
  }

  const css = fs.readFileSync(file, 'utf-8');
  console.log(`📄 Input: ${file} (${(css.length / 1024).toFixed(1)}KB)`);
  
  try {
    const result = await optimizer.optimize(css);
    const stats = result.stats;
    
    console.log(`\n✅ Optimization complete!`);
    console.log(`   Before: ${(stats.inputBytes / 1024).toFixed(1)}KB`);
    console.log(`   After:  ${(stats.outputBytes / 1024).toFixed(1)}KB`);
    console.log(`   Saved:  ${(stats.savedBytes / 1024).toFixed(1)}KB (${stats.compressionRatio})`);
    console.log(`   Target: ${stats.meetsTarget ? '✅ Met' : '❌ Not met'} (${optimizer.options.compressionTarget * 100}%)`);
    console.log(`   Builds: ${optimizer.buildCount}`);
    
    if (options.output) {
      fs.writeFileSync(options.output, result.css);
      console.log(`\n📝 Written to: ${options.output}`);
    }
    
    return result;
  } catch (err) {
    console.error(`❌ Error: ${err.message}`);
    process.exit(1);
  }
}

async function cmdAnalyze(file) {
  if (!fs.existsSync(file)) {
    console.error(`❌ File not found: ${file}`);
    process.exit(1);
  }
  
  const css = fs.readFileSync(file, 'utf-8');
  const analysis = optimizer.analyze(css);
  
  console.log(`\n📊 CSS Analysis for: ${file}`);
  console.log(`   ${'='.repeat(40)}`);
  console.log(`   Original Size:    ${analysis.originalSize}`);
  console.log(`   Rules:            ${analysis.ruleCount}`);
  console.log(`   Selectors:        ${analysis.selectorCount}`);
  console.log(`   Media Queries:    ${analysis.mediaQueries}`);
  console.log(`   Keyframes:        ${analysis.keyframes}`);
  console.log(`   @imports:         ${analysis.imports}`);
  console.log(`   Comments:         ${analysis.comments}`);
  console.log(`   Unique Colors:    ${analysis.colors}`);
  console.log(`   Font Families:    ${analysis.fontFamilies}`);
  console.log(`   Est. Savings:     ${analysis.optimizationPotential}`);
}

async function cmdBuild(file, options) {
  console.log(`\n🏗️  Discourse CSS Optimizer - Production Build\n`);
  
  if (!fs.existsSync(file)) {
    console.error(`❌ Input file not found: ${file}`);
    process.exit(1);
  }
  
  const css = fs.readFileSync(file, 'utf-8');
  console.log(`📄 Stage 1/4: Reading input (${(css.length / 1024).toFixed(1)}KB)...`);
  
  // Stage 1: Basic optimization
  console.log(`📦 Stage 2/4: Basic optimization (cssnano)...`);
  const basicResult = await optimizer.optimize(css);
  console.log(`   → ${basicResult.stats.compressionRatio} compression`);
  
  // Stage 2: Advanced if purge content provided
  let finalCSS = basicResult.css;
  if (options.content) {
    console.log(`🔧 Stage 3/4: Advanced optimization (PurgeCSS)...`);
    const contentPaths = Array.isArray(options.content) ? options.content : [options.content];
    const advancedResult = await optimizer.advancedOptimize(css, contentPaths);
    finalCSS = advancedResult.css;
    console.log(`   → Total: ${advancedResult.stats.totalSavings} bytes saved`);
  }
  
  // Stage 3: Write output
  const outputPath = options.output || file.replace('.css', '.min.css');
  fs.writeFileSync(outputPath, finalCSS);
  console.log(`📝 Stage 4/4: Writing output to ${outputPath}`);
  console.log(`\n✅ Build complete!`);
}

async function cmdInit() {
  const config = {
    name: 'discourse-css-theme',
    version: '1.0.0',
    optimizer: {
      minify: true,
      purge: true,
      incremental: true,
      compressionTarget: 0.30,
      advancedTarget: 0.40
    },
    paths: {
      input: 'src/stylesheets',
      output: 'dist',
      content: ['common/**/*.html.erb', 'desktop/**/*.html.erb', 'mobile/**/*.html.erb', 'javascripts/**/*.js']
    },
    scripts: {
      build: 'discourse-css-optimizer build stylesheet.css --output dist/optimized.css',
      watch: 'discourse-css-optimizer watch stylesheet.css',
      analyze: 'discourse-css-optimizer analyze stylesheet.css',
      'build:full': 'discourse-css-optimizer build stylesheet.css --content "./**/*.html.erb" --output dist/optimized.css'
    }
  };
  
  const configPath = 'discourse-css-optimizer.config.json';
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  console.log(`✅ Config created: ${configPath}`);
  console.log(`\nNext steps:`);
  console.log(`  1. Edit ${configPath} with your paths`);
  console.log(`  2. Run: discourse-css-optimizer build stylesheet.css`);
  console.log(`  3. Or:  discourse-css-optimizer analyze stylesheet.css`);
}

async function cmdWatch(file) {
  if (!fs.existsSync(file)) {
    console.error(`❌ File not found: ${file}`);
    process.exit(1);
  }
  
  console.log(`\n👀 Watching ${file} for changes...\n`);
  let previousCSS = fs.readFileSync(file, 'utf-8');
  
  // Initial build
  let result = await optimizer.optimize(previousCSS);
  console.log(`[${new Date().toLocaleTimeString()}] Initial build: ${result.stats.compressionRatio} compression`);
  
  // Watch for changes
  setInterval(async () => {
    try {
      const currentCSS = fs.readFileSync(file, 'utf-8');
      if (currentCSS !== previousCSS) {
        previousCSS = currentCSS;
        result = await optimizer.optimize(currentCSS);
        console.log(`[${new Date().toLocaleTimeString()}] Rebuilt: ${result.stats.compressionRatio} compression (build #${optimizer.buildCount})`);
      }
    } catch (err) {
      console.error(`[${new Date().toLocaleTimeString()}] Error: ${err.message}`);
    }
  }, 1000);
}

// CLI entry
async function main() {
  const args = process.argv.slice(2);
  const command = args[0];
  
  if (!command || command === '--help' || command === '-h') {
    showHelp();
    return;
  }
  
  if (command === '--version') {
    console.log('discourse-css-optimizer v1.0.0');
    return;
  }
  
  // Parse options
  const options = {};
  for (let i = 1; i < args.length; i++) {
    if (args[i] === '--output' || args[i] === '-o') options.output = args[++i];
    else if (args[i] === '--content' || args[i] === '-c') options.content = args[++i];
    else if (args[i] === '--purge') options.purge = true;
    else if (args[i] === '--no-minify') options.minify = false;
    else if (args[i] === '--verbose' || args[i] === '-v') options.verbose = true;
    else options.file = args[i];
  }
  
  switch (command) {
    case 'optimize':
      await cmdOptimize(options.file, options);
      break;
    case 'analyze':
      await cmdAnalyze(options.file);
      break;
    case 'build':
      await cmdBuild(options.file, options);
      break;
    case 'init':
      await cmdInit();
      break;
    case 'watch':
      await cmdWatch(options.file);
      break;
    default:
      console.error(`❌ Unknown command: ${command}`);
      showHelp();
      process.exit(1);
  }
}

main().catch(err => {
  console.error(`Fatal error: ${err.message}`);
  process.exit(1);
});
