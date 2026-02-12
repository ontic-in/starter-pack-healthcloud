#!/usr/bin/env node

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import { Octokit } from '@octokit/rest';
import Anthropic from '@anthropic-ai/sdk';
import { program } from 'commander';
import ora from 'ora';
import dotenv from 'dotenv';

dotenv.config();

// LWC CHECKPOINTS constant array with all 5 checkpoints
const CHECKPOINTS = [
  { name: '01-eslint-lwc-static-analysis', priority: 'CRITICAL', order: 1 },
  { name: '02-code-standards', priority: 'CRITICAL', order: 2 },
  { name: '03-css-architecture', priority: 'HIGH', order: 3 },
  { name: '04-testing-standards', priority: 'MEDIUM', order: 4 },
  { name: '05-architecture-patterns', priority: 'HIGH', order: 5 }
];

/**
 * CheckpointOrchestrator - Executes modular checkpoint-based LWC code review
 */
class CheckpointOrchestrator {
  /**
   * Constructor with Anthropic client initialization
   * @param {object} options - CLI options including verbose flag
   */
  constructor(options = {}) {
    this.options = options;

    // Initialize Anthropic client
    if (!process.env.ANTHROPIC_API_KEY) {
      throw new Error('ANTHROPIC_API_KEY environment variable not set');
    }

    this.anthropic = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY
    });

    // Initialize results and shared context
    this.results = [];
    this.sharedContext = {};

    if (options.verbose) {
      console.log('[Orchestrator] Initialized with 5 LWC checkpoints');
    }
  }

  /**
   * Validate dependencies before execution
   * @throws {Error} if required files are missing
   */
  validateDependencies() {
    const requiredFiles = [
      'docs/CSS_ARCHITECTURE_GUIDE.md',
      'docs/personas/LWC_FRONTEND_ENGINEER.md'
    ];

    const missingFiles = [];

    for (const file of requiredFiles) {
      if (!fs.existsSync(file)) {
        missingFiles.push(file);
      }
    }

    if (missingFiles.length > 0) {
      throw new Error(
        `Missing required dependency files:\n${missingFiles.map(f => `  - ${f}`).join('\n')}\n\n` +
        `These files are required for checkpoint cross-references. Please ensure they exist before running the review.`
      );
    }

    if (this.options.verbose) {
      console.log('[Orchestrator] All dependency files validated');
    }
  }

  /**
   * Execute all checkpoints
   * @param {string[]} files - Array of file paths to review
   * @param {string} eslintReport - ESLint JSON report content
   * @returns {Promise<object>} Aggregated results
   */
  async executeAllCheckpoints(files, eslintReport) {
    // Pre-flight validation
    this.validateDependencies();

    // Initialize spinner
    const spinner = ora('Starting checkpoint orchestration...').start();

    try {
      // Checkpoint execution loop
      for (const checkpoint of CHECKPOINTS) {
        spinner.text = `Executing ${checkpoint.name} (${checkpoint.priority})...`;

        try {
          const result = await this.executeCheckpoint(checkpoint, files, eslintReport);
          this.results.push(result);

          if (this.options.verbose) {
            console.log(`\n[Checkpoint] ${checkpoint.name} completed`);
            console.log(`  Status: ${result.status}`);
            console.log(`  Violations: ${result.violations?.length || 0}`);
          }
        } catch (error) {
          // Error handling for failed checkpoints
          console.error(`\n[Checkpoint] ${checkpoint.name} failed: ${error.message}`);

          // Continue on non-critical checkpoint failures
          this.results.push({
            checkpoint_name: checkpoint.name,
            checkpoint_priority: checkpoint.priority,
            status: 'error',
            error: error.message,
            violations: [],
            summary: {
              execution_error: true
            }
          });
        }
      }

      // Aggregate results
      const aggregatedResults = this.aggregateResults();

      // Update spinner based on results
      const criticalCount = aggregatedResults.violations_by_severity.critical.length;
      const hasBlockers = aggregatedResults.overall_assessment.has_production_blockers;

      if (hasBlockers || criticalCount > 0) {
        spinner.fail(`Checkpoints executed - ${criticalCount} CRITICAL issue(s) found`);
      } else {
        spinner.succeed('All checkpoints executed successfully');
      }

      return aggregatedResults;

    } catch (error) {
      spinner.fail(`Checkpoint orchestration failed: ${error.message}`);
      throw error;
    }
  }

  /**
   * Execute single checkpoint
   * @param {object} checkpoint - Checkpoint metadata
   * @param {string[]} files - Array of file paths
   * @param {string} eslintReport - ESLint JSON report
   * @returns {Promise<object>} Checkpoint result
   */
  async executeCheckpoint(checkpoint, files, eslintReport) {
    // Load checkpoint prompt file
    const checkpointPath = path.join('exec/lwc-code-review-checkpoints', `${checkpoint.name}.md`);

    if (!fs.existsSync(checkpointPath)) {
      throw new Error(`Checkpoint prompt not found: ${checkpointPath}`);
    }

    let checkpointPrompt = fs.readFileSync(checkpointPath, 'utf-8');

    // Read file contents for analysis
    const fileContents = files.map(filePath => {
      try {
        return fs.readFileSync(filePath, 'utf-8');
      } catch (error) {
        return `// Error reading file: ${error.message}`;
      }
    });

    // Prepare input JSON
    const inputJson = JSON.stringify({
      files: files,
      file_contents: fileContents,
      eslint_report: checkpoint.name === '01-eslint-lwc-static-analysis' ? JSON.parse(eslintReport) : undefined,
      eslint_context: checkpoint.name !== '01-eslint-lwc-static-analysis' ? this.sharedContext.eslint_violations : undefined
    }, null, 2);

    // Build the complete prompt
    const fullPrompt = `${checkpointPrompt}

## Input Data

\`\`\`json
${inputJson}
\`\`\`

## Task

Execute the checkpoint analysis as defined above. Return ONLY valid JSON matching the output format specified in the checkpoint prompt.`;

    if (this.options.verbose) {
      console.log(`\n[Checkpoint] ${checkpoint.name}`);
      console.log(`  Prompt length: ${fullPrompt.length} characters`);
      console.log(`  Files to analyze: ${files.length}`);
    }

    // Claude SDK API call
    const message = await this.anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 16000,
      messages: [{
        role: 'user',
        content: fullPrompt
      }]
    });

    // JSON response parsing and validation
    const responseText = message.content[0].text;

    // Extract JSON from response (may be wrapped in markdown code blocks)
    let jsonMatch = responseText.match(/```json\n([\s\S]+?)\n```/);
    if (!jsonMatch) {
      jsonMatch = responseText.match(/```\n([\s\S]+?)\n```/);
    }

    const jsonText = jsonMatch ? jsonMatch[1] : responseText;
    const result = JSON.parse(jsonText);

    // Update shared context for next checkpoint
    if (checkpoint.name === '01-eslint-lwc-static-analysis') {
      this.sharedContext.eslint_violations = result.violations || [];
    }

    if (this.options.verbose) {
      console.log(`  Response parsed successfully`);
      console.log(`  Usage: ${JSON.stringify(message.usage)}`);
    }

    return result;
  }

  /**
   * Aggregate results from all checkpoints
   * @returns {object} Aggregated report
   */
  aggregateResults() {
    if (this.options.verbose) {
      console.log('\n[Aggregation] Combining checkpoint results...');
    }

    // Basic aggregation structure
    const allViolations = [];
    const checkpointSummaries = [];

    for (const result of this.results) {
      if (result.violations) {
        allViolations.push(...result.violations);
      }

      checkpointSummaries.push({
        checkpoint: result.checkpoint_name,
        priority: result.checkpoint_priority,
        status: result.status,
        violation_count: result.violations?.length || 0,
        summary: result.summary
      });
    }

    // Deduplicate violations
    const uniqueViolations = this.deduplicateViolations(allViolations);

    // Calculate overall confidence
    const confidenceScore = this.calculateOverallConfidence(uniqueViolations);
    const confidenceRationale = this.generateConfidenceRationale(uniqueViolations);

    // Categorize violations by severity
    const criticalViolations = uniqueViolations.filter(v => v.severity === 'critical');
    const highViolations = uniqueViolations.filter(v => v.severity === 'high');
    const mediumViolations = uniqueViolations.filter(v => v.severity === 'medium');
    const lowViolations = uniqueViolations.filter(v => v.severity === 'low');

    // Determine production readiness
    const hasProductionBlockers = this.results.some(r => r.summary?.production_blocker === true);
    const productionReadiness = hasProductionBlockers ? 'critical-issues' :
                                criticalViolations.length > 0 ? 'needs-fixes' :
                                highViolations.length > 0 ? 'ready-with-improvements' :
                                'production-ready';

    return {
      metadata: {
        review_type: 'modular-checkpoint-lwc',
        timestamp: new Date().toISOString(),
        checkpoints_executed: this.results.length,
        total_violations: uniqueViolations.length
      },
      overall_assessment: {
        production_readiness: productionReadiness,
        confidence_score: confidenceScore,
        confidence_rationale: confidenceRationale,
        has_production_blockers: hasProductionBlockers
      },
      checkpoint_results: checkpointSummaries,
      violations_by_severity: {
        critical: criticalViolations,
        high: highViolations,
        medium: mediumViolations,
        low: lowViolations
      },
      all_violations: uniqueViolations,
      raw_checkpoint_results: this.results
    };
  }

  /**
   * Calculate overall confidence score
   * @param {Array} violations - All violations
   * @returns {number} Weighted confidence score
   */
  calculateOverallConfidence(violations) {
    // Checkpoint-specific confidence weights for LWC
    const confidenceWeights = {
      '01-eslint-lwc-static-analysis': 0.9,
      '02-code-standards': 0.7,
      '03-css-architecture': 0.7,
      '04-testing-standards': 0.6,
      '05-architecture-patterns': 0.7
    };

    // Weighted average based on violations found
    let totalWeight = 0;
    let weightedSum = 0;

    for (const result of this.results) {
      const checkpointName = result.checkpoint_name;
      const weight = confidenceWeights[checkpointName] || 0.5;
      const violationCount = result.violations?.length || 0;

      // Weight by number of violations
      const adjustedWeight = weight * (1 + violationCount * 0.1);

      totalWeight += adjustedWeight;
      weightedSum += weight * adjustedWeight;
    }

    const overallConfidence = totalWeight > 0 ? weightedSum / totalWeight : 0.7;

    return Math.round(overallConfidence * 100) / 100; // Round to 2 decimal places
  }

  /**
   * Generate confidence rationale
   * @param {Array} violations - All violations
   * @returns {string} Explanation of confidence score
   */
  generateConfidenceRationale(violations) {
    const sources = [];

    // Count violations by checkpoint
    const checkpointCounts = {};
    for (const violation of violations) {
      const checkpoint = violation.category?.split(':')[0] || 'Unknown';
      checkpointCounts[checkpoint] = (checkpointCounts[checkpoint] || 0) + 1;
    }

    // Evidence source listing
    for (const [checkpoint, count] of Object.entries(checkpointCounts)) {
      sources.push(`${checkpoint} (${count} findings)`);
    }

    return `Confidence based on ${this.results.length} checkpoint executions: ${sources.join(', ')}. ` +
           `Higher confidence in automated detections (ESLint-LWC, static analysis), ` +
           `moderate confidence in pattern-based checks (CSS, architecture, standards), ` +
           `lower confidence in subjective assessments (testing).`;
  }

  /**
   * Deduplicate violations across checkpoints
   * @param {Array} violations - All violations from all checkpoints
   * @returns {Array} Deduplicated violations
   */
  deduplicateViolations(violations) {
    // Map-based deduplication using file:line:category keys
    const violationMap = new Map();

    for (const violation of violations) {
      const key = `${violation.file}:${violation.line}:${violation.category}`;

      // Keep higher confidence violation
      if (!violationMap.has(key)) {
        violationMap.set(key, violation);
      } else {
        const existing = violationMap.get(key);
        if (violation.confidence > existing.confidence) {
          violationMap.set(key, violation);
        }
      }
    }

    const deduplicated = Array.from(violationMap.values());

    if (this.options.verbose) {
      console.log(`[Aggregation] Deduplicated ${violations.length} → ${deduplicated.length} violations`);
    }

    return deduplicated;
  }

  /**
   * Generate formatted report
   * @param {object} aggregatedResults - Aggregated checkpoint results
   * @returns {string} Markdown formatted report
   */
  generateReport(aggregatedResults) {
    const lines = [];

    // Checkpoint execution summary
    lines.push('# LWC Code Review - Modular Checkpoint Analysis');
    lines.push('');
    lines.push(`**Review Date**: ${aggregatedResults.metadata.timestamp}`);
    lines.push(`**Review Type**: ${aggregatedResults.metadata.review_type}`);
    lines.push(`**Checkpoints Executed**: ${aggregatedResults.metadata.checkpoints_executed}/5`);
    lines.push(`**Total Violations**: ${aggregatedResults.metadata.total_violations}`);
    lines.push('');

    // Overall assessment
    lines.push('## Overall Assessment');
    lines.push('');
    lines.push(`**Production Readiness**: ${aggregatedResults.overall_assessment.production_readiness}`);
    lines.push(`**Confidence Score**: ${aggregatedResults.overall_assessment.confidence_score}`);
    lines.push(`**Has Production Blockers**: ${aggregatedResults.overall_assessment.has_production_blockers ? 'YES ⚠️' : 'No'}`);
    lines.push('');
    lines.push('**Confidence Rationale**:');
    lines.push(aggregatedResults.overall_assessment.confidence_rationale);
    lines.push('');

    // Per-checkpoint results
    lines.push('## Checkpoint Results');
    lines.push('');
    for (const checkpoint of aggregatedResults.checkpoint_results) {
      const statusEmoji = checkpoint.status === 'pass' ? '✅' :
                         checkpoint.status === 'fail' ? '❌' :
                         checkpoint.status === 'warning' ? '⚠️' : '❓';

      lines.push(`### ${checkpoint.checkpoint} (${checkpoint.priority}) ${statusEmoji}`);
      lines.push('');
      lines.push(`- **Status**: ${checkpoint.status}`);
      lines.push(`- **Violations Found**: ${checkpoint.violation_count}`);

      if (checkpoint.summary) {
        lines.push(`- **Summary**:`);
        for (const [key, value] of Object.entries(checkpoint.summary)) {
          if (key !== 'production_blocker') {
            lines.push(`  - ${key}: ${value}`);
          }
        }
      }
      lines.push('');
    }

    // Critical violations section
    const criticalViolations = aggregatedResults.violations_by_severity.critical;
    if (criticalViolations.length > 0) {
      lines.push('## 🚨 Critical Violations (Production Blockers)');
      lines.push('');
      lines.push(`Found ${criticalViolations.length} critical violation(s) that must be addressed before deployment.`);
      lines.push('');

      for (const violation of criticalViolations) {
        lines.push(`### ${violation.category}`);
        lines.push('');
        lines.push(`**File**: ${violation.file}:${violation.line || 'N/A'}`);
        lines.push(`**Issue**: ${violation.issue}`);
        lines.push(`**Confidence**: ${violation.confidence}`);
        lines.push('');
        lines.push('**Evidence**:');
        lines.push('```javascript');
        lines.push(violation.evidence || 'N/A');
        lines.push('```');
        lines.push('');
        lines.push('**Fix Guidance**:');
        lines.push('```javascript');
        lines.push(violation.fix_guidance || 'No guidance provided');
        lines.push('```');
        lines.push('');
      }
    }

    // High priority issues
    const highViolations = aggregatedResults.violations_by_severity.high;
    if (highViolations.length > 0) {
      lines.push('## ⚠️ High Priority Issues');
      lines.push('');
      lines.push(`Found ${highViolations.length} high priority issue(s).`);
      lines.push('');

      // Group by category
      const byCategory = {};
      for (const violation of highViolations) {
        const category = violation.category || 'Uncategorized';
        if (!byCategory[category]) {
          byCategory[category] = [];
        }
        byCategory[category].push(violation);
      }

      for (const [category, violations] of Object.entries(byCategory)) {
        lines.push(`### ${category} (${violations.length} issue${violations.length > 1 ? 's' : ''})`);
        lines.push('');
        for (const violation of violations) {
          lines.push(`- **${violation.file}:${violation.line || 'N/A'}** - ${violation.issue}`);
        }
        lines.push('');
      }
    }

    // Recommendations section
    const mediumViolations = aggregatedResults.violations_by_severity.medium;
    const lowViolations = aggregatedResults.violations_by_severity.low;

    if (mediumViolations.length > 0 || lowViolations.length > 0) {
      lines.push('## 📋 Recommendations');
      lines.push('');

      if (mediumViolations.length > 0) {
        lines.push(`### Medium Priority (${mediumViolations.length} issue${mediumViolations.length > 1 ? 's' : ''})`);
        lines.push('');
        for (const violation of mediumViolations.slice(0, 10)) {
          lines.push(`- ${violation.category}: ${violation.issue} (${violation.file})`);
        }
        if (mediumViolations.length > 10) {
          lines.push(`- ...and ${mediumViolations.length - 10} more medium issues`);
        }
        lines.push('');
      }

      if (lowViolations.length > 0) {
        lines.push(`### Low Priority (${lowViolations.length} issue${lowViolations.length > 1 ? 's' : ''})`);
        lines.push('');
        lines.push(`See full JSON results below for complete list of low priority issues.`);
        lines.push('');
      }
    }

    // Positive findings
    lines.push('## ✅ Positive Findings');
    lines.push('');
    const passedCheckpoints = aggregatedResults.checkpoint_results.filter(c => c.status === 'pass');
    if (passedCheckpoints.length > 0) {
      lines.push(`${passedCheckpoints.length} checkpoint(s) passed without violations:`);
      for (const checkpoint of passedCheckpoints) {
        lines.push(`- ${checkpoint.checkpoint}`);
      }
    } else {
      lines.push('No checkpoints passed without violations. Focus on addressing critical and high priority issues first.');
    }
    lines.push('');

    // Full JSON results
    lines.push('## 📊 Full JSON Results');
    lines.push('');
    lines.push('```json');
    lines.push(JSON.stringify(aggregatedResults, null, 2));
    lines.push('```');

    return lines.join('\n');
  }

  /**
   * Save report to file
   * @param {string} report - Markdown report content
   * @param {object} options - CLI options
   * @returns {string} Path to saved report
   */
  saveReport(report, options = {}) {
    const outputDir = options.output || 'docs/analysis';

    // Create directory if missing
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Timestamped filename with ticket prefix
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const ticketPrefix = options.ticket ? `${options.ticket}-` : '';
    const filename = `${ticketPrefix}lwc-code-review-modular-${timestamp}.md`;
    const reportPath = path.join(outputDir, filename);

    fs.writeFileSync(reportPath, report, 'utf-8');

    if (options.verbose) {
      console.log(`[Report] Saved to: ${reportPath}`);
    }

    return reportPath;
  }
}

/**
 * Generate timestamped ESLint report
 * @param {object} options - CLI options including verbose flag
 * @returns {string} ESLint report JSON content
 */
function getESLintReport(options = {}) {
  // Generate timestamped filename
  const timestamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+/, '').replace('T', '_');
  const reportPath = path.join('tmp', `eslint_lwc_report_${timestamp}.json`);
  const absoluteReportPath = path.resolve(reportPath);

  // ESLint project paths - LWC specific
  // Run from sf_project directory where eslint config exists
  const eslintCommand = `cd development/sf_project && npx eslint force-app/main/default/lwc/**/*.js --format json --output-file ${absoluteReportPath}`;

  // Verbose logging
  if (options.verbose) {
    console.log(`[ESLint] Generating report: ${reportPath}`);
    console.log(`[ESLint] Command: ${eslintCommand}`);
  }

  try {
    // Execute ESLint command
    execSync(eslintCommand, {
      encoding: 'utf-8',
      stdio: options.verbose ? 'inherit' : 'pipe'
    });

    // Parse and validate JSON output
    const eslintContent = fs.readFileSync(reportPath, 'utf-8');
    const eslintJson = JSON.parse(eslintContent);

    if (options.verbose) {
      console.log(`[ESLint] Report generated successfully`);
      console.log(`[ESLint] Files analyzed: ${eslintJson.length || 0}`);
    }

    return eslintContent;

  } catch (error) {
    // Error handling for ESLint failures
    if (error.code === 'ENOENT') {
      throw new Error('ESLint not found. Please ensure ESLint is installed: npm install eslint');
    }

    // ESLint returns non-zero exit code when violations are found, which is expected
    // Check if the report file was created despite the error
    if (fs.existsSync(reportPath)) {
      try {
        const eslintContent = fs.readFileSync(reportPath, 'utf-8');
        JSON.parse(eslintContent); // Validate JSON

        if (options.verbose) {
          console.log(`[ESLint] Report generated with violations (exit code: ${error.status})`);
        }

        return eslintContent;
      } catch (parseError) {
        throw new Error(`ESLint generated invalid JSON: ${parseError.message}`);
      }
    }

    throw new Error(`ESLint execution failed: ${error.message}`);
  }
}

/**
 * Fetch files changed in a GitHub PR
 * @param {string} prUrl - GitHub PR URL
 * @param {object} options - CLI options including verbose flag
 * @returns {Promise<string[]>} Array of LWC file paths
 */
async function fetchPRFiles(prUrl, options = {}) {
  // Parse PR URL
  const prRegex = /github\.com\/([^\/]+)\/([^\/]+)\/pull\/(\d+)/;
  const match = prUrl.match(prRegex);

  if (!match) {
    throw new Error(`Invalid GitHub PR URL format. Expected: https://github.com/owner/repo/pull/123`);
  }

  const [, owner, repo, pullNumber] = match;

  if (options.verbose) {
    console.log(`[GitHub] Fetching files from PR: ${owner}/${repo}#${pullNumber}`);
  }

  try {
    const octokit = new Octokit({
      auth: process.env.GITHUB_TOKEN
    });

    const { data: files } = await octokit.pulls.listFiles({
      owner,
      repo,
      pull_number: parseInt(pullNumber, 10)
    });

    // Filter to LWC files (.js, .html, .css in lwc directories)
    const lwcFiles = files
      .map(f => f.filename)
      .filter(f => f.includes('/lwc/') && (f.endsWith('.js') || f.endsWith('.html') || f.endsWith('.css')));

    if (options.verbose) {
      console.log(`[GitHub] Found ${files.length} total files, ${lwcFiles.length} LWC files`);
      lwcFiles.forEach(f => console.log(`  - ${f}`));
    }

    return lwcFiles;

  } catch (error) {
    if (error.status === 401) {
      throw new Error('GitHub authentication failed. Please set GITHUB_TOKEN environment variable');
    }
    if (error.status === 403) {
      throw new Error('GitHub API rate limit exceeded. Please set GITHUB_TOKEN for higher limits');
    }
    if (error.status === 404) {
      throw new Error(`GitHub PR not found: ${owner}/${repo}#${pullNumber}`);
    }
    throw new Error(`GitHub API error: ${error.message}`);
  }
}

/**
 * Determine which files to review based on CLI options
 * @param {object} options - CLI options (files, all, pr, verbose)
 * @returns {Promise<string[]>} Array of file paths to review
 */
async function getFilesToReview(options = {}) {
  let filesToReview = [];

  // --files flag (comma-separated paths)
  if (options.files) {
    filesToReview = options.files.split(',').map(f => f.trim());

    if (options.verbose) {
      console.log(`[Files] Using manually specified files (${filesToReview.length})`);
    }
  }
  // --pr flag (GitHub PR URL)
  else if (options.pr) {
    filesToReview = await fetchPRFiles(options.pr, options);
  }
  // --all flag (all LWC files in development/sf_project/force-app/)
  else if (options.all) {
    const findCommand = 'find development/sf_project/force-app/main/default/lwc -type f \\( -name "*.js" -o -name "*.html" -o -name "*.css" \\) ! -path "*/__tests__/*"';

    if (options.verbose) {
      console.log(`[Files] Finding all LWC files: ${findCommand}`);
    }

    try {
      const output = execSync(findCommand, { encoding: 'utf-8' });
      filesToReview = output.trim().split('\n').filter(f => f.length > 0);

      if (options.verbose) {
        console.log(`[Files] Found ${filesToReview.length} LWC files`);
      }
    } catch (error) {
      throw new Error(`Failed to find LWC files: ${error.message}`);
    }
  }
  else {
    throw new Error('No file detection method specified. Use --files, --pr, or --all');
  }

  // Validate file paths exist
  const existingFiles = [];
  const missingFiles = [];

  for (const file of filesToReview) {
    if (fs.existsSync(file)) {
      existingFiles.push(file);
    } else {
      missingFiles.push(file);
    }
  }

  if (missingFiles.length > 0 && options.verbose) {
    console.warn(`[Files] Warning: ${missingFiles.length} files not found:`);
    missingFiles.forEach(f => console.warn(`  - ${f}`));
  }

  // Error handling for no files found
  if (existingFiles.length === 0) {
    throw new Error('No valid LWC files found to review');
  }

  if (options.verbose) {
    console.log(`[Files] ${existingFiles.length} files will be reviewed`);
  }

  return existingFiles;
}

/**
 * Main CLI entry point
 */
async function main() {
  // Configure CLI
  program
    .name('lwc-code-review')
    .description('Execute LWC code review using Claude Code SDK')
    .option('-f, --files <paths>', 'Comma-separated file paths to review')
    .option('-p, --pr <url>', 'GitHub PR URL to review')
    .option('-a, --all', 'Review all LWC files in force-app/')
    .option('-t, --ticket <id>', 'ClickUp ticket ID for output filename')
    .option('-o, --output <path>', 'Output directory', 'docs/analysis')
    .option('-v, --verbose', 'Verbose logging')
    .option('--mode <mode>', 'Review mode (monolithic/modular)', 'modular')
    .parse();

  const options = program.opts();

  try {
    // CRITICAL: Validate ANTHROPIC_API_KEY exists before proceeding
    if (!process.env.ANTHROPIC_API_KEY) {
      console.error('\n❌ ERROR: ANTHROPIC_API_KEY not found in environment');
      console.error('\nThe LWC code review requires Claude AI API access.');
      console.error('\nPlease add ANTHROPIC_API_KEY to your .env file:');
      console.error('  1. Open .env file in project root');
      console.error('  2. Add line: ANTHROPIC_API_KEY=your-api-key-here');
      console.error('  3. Save the file and try again');
      console.error('\nGet your API key from: https://console.anthropic.com/settings/keys\n');
      process.exit(1);
    }

    // Determine files to review
    const filesToReview = await getFilesToReview(options);

    // Generate ESLint report
    const eslintReport = getESLintReport(options);

    // Execute modular checkpoint-based review (default mode for LWC)
    const orchestrator = new CheckpointOrchestrator(options);
    const aggregatedResults = await orchestrator.executeAllCheckpoints(filesToReview, eslintReport);

    // Generate report
    const report = orchestrator.generateReport(aggregatedResults);

    // Determine severity for exit code and display
    const hasProductionBlockers = aggregatedResults.overall_assessment.has_production_blockers;
    const criticalCount = aggregatedResults.violations_by_severity.critical.length;
    const highCount = aggregatedResults.violations_by_severity.high.length;
    const totalViolations = aggregatedResults.metadata.total_violations;

    // Print report to console
    console.log('\n' + '='.repeat(80));
    console.log(report);
    console.log('='.repeat(80) + '\n');

    // Display summary with appropriate emoji
    if (hasProductionBlockers || criticalCount > 0) {
      console.log(`\n❌ Code review completed with CRITICAL issues`);
    } else if (highCount > 0) {
      console.log(`\n⚠️  Code review completed with warnings`);
    } else if (totalViolations > 0) {
      console.log(`\n✅ Code review completed with minor issues`);
    } else {
      console.log(`\n✅ Code review completed - no violations found`);
    }

    console.log(`\n📊 Summary:`);
    console.log(`   Production Readiness: ${aggregatedResults.overall_assessment.production_readiness}`);
    console.log(`   Confidence Score: ${aggregatedResults.overall_assessment.confidence_score}`);
    console.log(`   Total Violations: ${totalViolations}`);

    if (criticalCount > 0 || highCount > 0) {
      console.log(`   🚨 Critical: ${criticalCount}`);
      console.log(`   ⚠️  High: ${highCount}`);
    }

    if (hasProductionBlockers) {
      console.error(`\n🚫 DEPLOYMENT BLOCKED: Production blockers detected!`);
      console.error(`   Review the output above for critical issues that must be fixed before deployment.\n`);
      process.exit(1); // Exit with error code
    } else if (criticalCount > 0) {
      console.error(`\n⚠️  CRITICAL ISSUES: ${criticalCount} critical violation(s) found!`);
      console.error(`   These should be addressed before production deployment.\n`);
      process.exit(1); // Exit with error code for critical violations
    } else if (highCount > 0) {
      console.log(`\n⚠️  High priority issues found. Review recommended before deployment.\n`);
      // Exit with 0 for high priority (warning only)
    }

  } catch (error) {
    // Error handling
    console.error(`\n❌ Code review failed: ${error.message}`);
    if (options.verbose) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

// Execute main if run directly
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Auto-run main when executed directly
main();

export {
  getESLintReport,
  getFilesToReview,
  fetchPRFiles,
  CheckpointOrchestrator
};
