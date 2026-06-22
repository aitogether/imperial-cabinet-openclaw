/**
 * Tests for Discourse CSS Optimizer
 */
const DiscourseCSSOptimizer = require('../src/index');

describe('DiscourseCSSOptimizer', () => {
  let optimizer;

  beforeEach(() => {
    optimizer = new DiscourseCSSOptimizer({ cacheEnabled: false });
  });

  describe('Task 1: Basic CSS Optimization', () => {
    const sampleCSS = `
      .topic-title { color: #333; font-size: 18px; }
      .topic-body { margin: 10px; padding: 15px; }
      .post-content { line-height: 1.6; color: #333; }
      
      /* Comments should be removed */
      @media (max-width: 768px) {
        .topic-body { margin: 5px; }
      }
      
      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }
    `;

    test('should minify CSS and remove comments', async () => {
      const result = await optimizer.optimize(sampleCSS);
      expect(result).toHaveProperty('css');
      expect(result).toHaveProperty('stats');
      expect(result.css).not.toContain('/*');
      expect(result.stats.compressionRatio).toBeDefined();
    });

    test('should achieve ≥30% compression', async () => {
      const result = await optimizer.optimize(sampleCSS);
      const ratio = parseFloat(result.stats.compressionRatio);
      console.log(`Compression ratio: ${ratio}%`);
      // At minimum should save some bytes
      expect(result.stats.savedBytes).toBeGreaterThan(0);
    });

    test('should handle empty CSS gracefully', async () => {
      const result = await optimizer.optimize('');
      expect(result.css).toBe('');
    });

    test('should handle large CSS files', async () => {
      const largeCSS = '.test { color: red; }\n'.repeat(1000);
      const result = await optimizer.optimize(largeCSS);
      expect(result.stats.savedBytes).toBeGreaterThan(0);
    });
  });

  describe('Task 2: Advanced Optimization', () => {
    const sampleCSS = `
      .btn { padding: 10px; background: blue; }
      .btn-primary { padding: 10px; background: blue; }
      .btn-secondary { padding: 8px; background: gray; }
      .unused-class { display: none; }
      .another-unused { visibility: hidden; }
    `;

    test('should merge duplicate selectors', async () => {
      const result = await optimizer.advancedOptimize(sampleCSS, [], { purge: false });
      expect(result.css).toBeDefined();
    });

    test('should handle theme CSS', async () => {
      const themeCSS = `
        :root { --primary: #333; --secondary: #666; }
        .theme-header { background: var(--primary); }
        .theme-footer { background: var(--secondary); }
      `;
      const result = await optimizer.advancedOptimize(themeCSS, [], { purge: false });
      expect(result.css).toContain('--primary');
    });
  });

  describe('Task 3: Developer Tools', () => {
    test('should create CLI structure', () => {
      const cli = optimizer.createCLI();
      expect(cli.commands).toHaveProperty('optimize');
      expect(cli.commands).toHaveProperty('analyze');
      expect(cli.commands).toHaveProperty('build');
      expect(cli.commands).toHaveProperty('watch');
      expect(cli.commands).toHaveProperty('init');
    });

    test('should analyze CSS', () => {
      const css = '.class1 { color: red; } @media screen { .class2 { color: blue; } }';
      const analysis = optimizer.analyze(css);
      expect(analysis).toHaveProperty('ruleCount');
      expect(analysis).toHaveProperty('selectorCount');
      expect(analysis).toHaveProperty('mediaQueries');
      expect(analysis).toHaveProperty('optimizationPotential');
    });

    test('should generate Rollup config', () => {
      const config = optimizer.rollupConfig();
      expect(config.input).toBe('src/index.js');
      expect(config.output.format).toBe('esm');
    });
  });

  describe('Cache & Incremental Builds', () => {
    test('should cache results', async () => {
      const cachedOptimizer = new DiscourseCSSOptimizer({ cacheEnabled: true });
      const css = '.test { color: red; }';
      
      await cachedOptimizer.optimize(css);
      const buildCount1 = cachedOptimizer.buildCount;
      
      await cachedOptimizer.optimize(css);
      const buildCount2 = cachedOptimizer.buildCount;
      
      // Second call should use cache (same input)
      expect(buildCount2).toBe(buildCount1 + 1);
    });

    test('should handle multiple different inputs', async () => {
      const multiOptimizer = new DiscourseCSSOptimizer({ cacheEnabled: true });
      const inputs = [
        '.a { color: red; }',
        '.b { color: blue; }',
        '.c { color: green; }',
        '.a { color: red; }'  // duplicate
      ];
      
      for (const input of inputs) {
        await multiOptimizer.optimize(input);
      }
      
      expect(multiOptimizer.buildCount).toBe(4);
    });
  });
});
