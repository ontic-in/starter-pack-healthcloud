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

// T060: CHECKPOINTS constant array with all 8 checkpoints
const CHECKPOINTS = [
  { name: '01-pmd-static-analysis', priority: 'CRITICAL', order: 1 },
  { name: '02-sharing-keyword-audit', priority: 'CRITICAL', order: 2 },
  { name: '03-security-crud-fls', priority: 'CRITICAL', order: 3 },
  { name: '04-static-method-analysis', priority: 'CRITICAL', order: 4 },
  { name: '05-architecture-patterns', priority: 'HIGH', order: 5 },
  { name: '06-code-standards', priority: 'HIGH', order: 6 },
  { name: '07-testing-standards', priority: 'MEDIUM', order: 7 },
  { name: '08-quality-process', priority: 'LOW', order: 8 }
];

/**
 * CheckpointOrchestrator - Executes modular checkpoint-based code review
 * Tasks: T061-T093
 */
class CheckpointOrchestrator {
  /**
   * T062: Constructor with Anthropic client initialization
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

    // T063: Initialize results and shared context
    this.results = [];
    this.sharedContext = {};

    if (options.verbose) {
      console.log('[Orchestrator] Initialized with 8 checkpoints');
    }
  }

  /**
   * T064-T068: Validate dependencies before execution
   * @throws {Error} if required files are missing
   */
  validateDependencies() {
    const requiredFiles = [
      'docs/RFCs/RFC_SALESFORCE_PRACTICES.md',
      'docs/guides/CONFIDENCE_SCORING_GUIDE_APEX_CODE_REVIEW.md',
      'docs/SALESFORCE_APEX_STATIC_TYPES_GUIDE.md'
    ];

    const missingFiles = [];

    for (const file of requiredFiles) {
      if (!fs.existsSync(file)) {
        missingFiles.push(file);
      }
    }

    // T068: Clear error message with missing files list
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
   * T069-T072: Execute all checkpoints
   * @param {string[]} files - Array of file paths to review
   * @param {string} pmdReport - PMD JSON report content
   * @returns {Promise<object>} Aggregated results
   */
  async executeAllCheckpoints(files, pmdReport) {
    // T070: Pre-flight validation
    this.validateDependencies();

    // T071: Initialize spinner
    const spinner = ora('Starting checkpoint orchestration...').start();

    try {
      // T072: Checkpoint execution loop
      for (const checkpoint of CHECKPOINTS) {
        spinner.text = `Executing ${checkpoint.name} (${checkpoint.priority})...`;

        try {
          const result = await this.executeCheckpoint(checkpoint, files, pmdReport);
          this.results.push(result);

          if (this.options.verbose) {
            console.log(`\n[Checkpoint] ${checkpoint.name} completed`);
            console.log(`  Status: ${result.status}`);
            console.log(`  Violations: ${result.violations?.length || 0}`);
          }
        } catch (error) {
          // T078: Error handling for failed checkpoints
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
   * T073-T080: Execute single checkpoint
   * @param {object} checkpoint - Checkpoint metadata
   * @param {string[]} files - Array of file paths
   * @param {string} pmdReport - PMD JSON report
   * @returns {Promise<object>} Checkpoint result
   */
  async executeCheckpoint(checkpoint, files, pmdReport) {
    // T074: Load checkpoint prompt file
    const checkpointPath = path.join('exec/apex-code-review-checkpoints', `${checkpoint.name}.md`);

    if (!fs.existsSync(checkpointPath)) {
      throw new Error(`Checkpoint prompt not found: ${checkpointPath}`);
    }

    let checkpointPrompt = fs.readFileSync(checkpointPath, 'utf-8');

    // T075: Prompt variable substitution
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
      pmd_report: checkpoint.name === '01-pmd-static-analysis' ? JSON.parse(pmdReport) : undefined,
      pmd_context: checkpoint.name !== '01-pmd-static-analysis' ? this.sharedContext.pmd_violations : undefined
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

    // T076: Claude SDK API call
    const message = await this.anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 16000,
      messages: [{
        role: 'user',
        content: fullPrompt
      }]
    });

    // T077: JSON response parsing and validation
    const responseText = message.content[0].text;

    // Extract JSON from response (may be wrapped in markdown code blocks)
    let jsonMatch = responseText.match(/```json\n([\s\S]+?)\n```/);
    if (!jsonMatch) {
      jsonMatch = responseText.match(/```\n([\s\S]+?)\n```/);
    }

    const jsonText = jsonMatch ? jsonMatch[1] : responseText;
    const result = JSON.parse(jsonText);

    // T080: Update shared context for next checkpoint
    if (checkpoint.name === '01-pmd-static-analysis') {
      this.sharedContext.pmd_violations = result.violations || [];
    }

    if (this.options.verbose) {
      console.log(`  Response parsed successfully`);
      console.log(`  Usage: ${JSON.stringify(message.usage)}`);
    }

    return result;
  }

  /**
   * T081-T093: Aggregate results from all checkpoints
   * @returns {object} Aggregated report
   */
  aggregateResults() {
    if (this.options.verbose) {
      console.log('\n[Aggregation] Combining checkpoint results...');
    }

    // T082: Basic aggregation structure
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

    // T093: Deduplicate violations
    const uniqueViolations = this.deduplicateViolations(allViolations);

    // T083-T087: Calculate overall confidence
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
        review_type: 'modular-checkpoint',
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
   * T083-T085: Calculate overall confidence score
   * @param {Array} violations - All violations
   * @returns {number} Weighted confidence score
   */
  calculateOverallConfidence(violations) {
    // T084: Checkpoint-specific confidence weights
    const confidenceWeights = {
      '01-pmd-static-analysis': 0.9,
      '02-sharing-keyword-audit': 0.9,
      '03-security-crud-fls': 0.8,
      '04-static-method-analysis': 0.9,
      '05-architecture-patterns': 0.7,
      '06-code-standards': 0.7,
      '07-testing-standards': 0.6,
      '08-quality-process': 0.5
    };

    // T085: Weighted average based on violations found
    let totalWeight = 0;
    let weightedSum = 0;

    for (const result of this.results) {
      const checkpointName = result.checkpoint_name;
      const weight = confidenceWeights[checkpointName] || 0.5;
      const violationCount = result.violations?.length || 0;

      // Weight by number of violations (more violations = more data = higher confidence in that checkpoint)
      const adjustedWeight = weight * (1 + violationCount * 0.1);

      totalWeight += adjustedWeight;
      weightedSum += weight * adjustedWeight; // Use weight variable, not confidenceWeights[checkpointName]
    }

    const overallConfidence = totalWeight > 0 ? weightedSum / totalWeight : 0.7;

    return Math.round(overallConfidence * 100) / 100; // Round to 2 decimal places
  }

  /**
   * T086-T087: Generate confidence rationale
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

    // T087: Evidence source listing
    for (const [checkpoint, count] of Object.entries(checkpointCounts)) {
      sources.push(`${checkpoint} (${count} findings)`);
    }

    return `Confidence based on ${this.results.length} checkpoint executions: ${sources.join(', ')}. ` +
           `Higher confidence in automated detections (PMD, static analysis), ` +
           `moderate confidence in pattern-based checks (architecture, standards), ` +
           `lower confidence in subjective assessments (quality, testing).`;
  }

  /**
   * T088-T090: Deduplicate violations across checkpoints
   * @param {Array} violations - All violations from all checkpoints
   * @returns {Array} Deduplicated violations
   */
  deduplicateViolations(violations) {
    // T089: Map-based deduplication using file:line:category keys
    const violationMap = new Map();

    for (const violation of violations) {
      const key = `${violation.file}:${violation.line}:${violation.category}`;

      // T090: Keep higher confidence violation
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
   * T094-T102: Generate formatted report
   * @param {object} aggregatedResults - Aggregated checkpoint results
   * @returns {string} Markdown formatted report
   */
  generateReport(aggregatedResults) {
    const lines = [];

    // T095: Checkpoint execution summary
    lines.push('# Apex Code Review - Modular Checkpoint Analysis');
    lines.push('');
    lines.push(`**Review Date**: ${aggregatedResults.metadata.timestamp}`);
    lines.push(`**Review Type**: ${aggregatedResults.metadata.review_type}`);
    lines.push(`**Checkpoints Executed**: ${aggregatedResults.metadata.checkpoints_executed}/8`);
    lines.push(`**Total Violations**: ${aggregatedResults.metadata.total_violations}`);
    lines.push('');

    // T096: Overall assessment
    lines.push('## Overall Assessment');
    lines.push('');
    lines.push(`**Production Readiness**: ${aggregatedResults.overall_assessment.production_readiness}`);
    lines.push(`**Confidence Score**: ${aggregatedResults.overall_assessment.confidence_score}`);
    lines.push(`**Has Production Blockers**: ${aggregatedResults.overall_assessment.has_production_blockers ? 'YES ⚠️' : 'No'}`);
    lines.push('');
    lines.push('**Confidence Rationale**:');
    lines.push(aggregatedResults.overall_assessment.confidence_rationale);
    lines.push('');

    // T097: Per-checkpoint results
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

    // T098: Critical violations section
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
        lines.push('```apex');
        lines.push(violation.evidence || 'N/A');
        lines.push('```');
        lines.push('');
        lines.push('**Fix Guidance**:');
        lines.push('```apex');
        lines.push(violation.fix_guidance || 'No guidance provided');
        lines.push('```');
        lines.push('');
      }
    }

    // T099: High priority issues
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

    // T100: Recommendations section
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

    // T101: Positive findings
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

    // T102: Full JSON results
    lines.push('## 📊 Full JSON Results');
    lines.push('');
    lines.push('```json');
    lines.push(JSON.stringify(aggregatedResults, null, 2));
    lines.push('```');

    return lines.join('\n');
  }

  /**
   * T103-T106: Save report to file
   * @param {string} report - Markdown report content
   * @param {object} options - CLI options
   * @returns {string} Path to saved report
   */
  saveReport(report, options = {}) {
    const outputDir = options.output || 'docs/analysis';

    // T106: Create directory if missing
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // T104-T105: Timestamped filename with ticket prefix
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const ticketPrefix = options.ticket ? `${options.ticket}-` : '';
    const filename = `${ticketPrefix}apex-code-review-modular-${timestamp}.md`;
    const reportPath = path.join(outputDir, filename);

    fs.writeFileSync(reportPath, report, 'utf-8');

    if (options.verbose) {
      console.log(`[Report] Saved to: ${reportPath}`);
    }

    return reportPath;
  }
}

/**
 * Generate timestamped PMD report
 * Tasks: T010-T016
 * @param {object} options - CLI options including verbose flag
 * @returns {string} PMD report JSON content
 */
function getPMDReport(options = {}) {
  // T012: Generate timestamped filename
  const timestamp = new Date().toISOString().replace(/[-:]/g, '').replace(/\..+/, '').replace('T', '_');
  const reportPath = path.join('tmp', `pmd_apex_report_${timestamp}.json`);
  const absoluteReportPath = path.resolve(reportPath);

  // PMD project paths
  const pmdProjectDir = 'development/sf_project';
  const pmdCommand = `cd ${pmdProjectDir} && PMD_APEX_ROOT_DIRECTORY=$(pwd) pmd check -d force-app/main/default/classes -R pmd-ruleset.xml -f json -r ${absoluteReportPath}`;

  // T016: Verbose logging
  if (options.verbose) {
    console.log(`[PMD] Generating report: ${reportPath}`);
    console.log(`[PMD] Command: ${pmdCommand}`);
  }

  try {
    // T011: Execute PMD command
    // T013: Save to tmp/ directory
    execSync(pmdCommand, {
      encoding: 'utf-8',
      stdio: options.verbose ? 'inherit' : 'pipe'
    });

    // T015: Parse and validate JSON output
    const pmdContent = fs.readFileSync(reportPath, 'utf-8');
    const pmdJson = JSON.parse(pmdContent);

    if (options.verbose) {
      console.log(`[PMD] Report generated successfully`);
      console.log(`[PMD] Files analyzed: ${pmdJson.files?.length || 0}`);
    }

    return pmdContent;

  } catch (error) {
    // T014: Error handling for PMD failures
    if (error.code === 'ENOENT') {
      throw new Error('PMD not found. Please ensure PMD is installed and in your PATH');
    }

    // PMD returns non-zero exit code when violations are found, which is expected
    // Check if the report file was created despite the error
    if (fs.existsSync(reportPath)) {
      try {
        const pmdContent = fs.readFileSync(reportPath, 'utf-8');
        JSON.parse(pmdContent); // Validate JSON

        if (options.verbose) {
          console.log(`[PMD] Report generated with violations (exit code: ${error.status})`);
        }

        return pmdContent;
      } catch (parseError) {
        throw new Error(`PMD generated invalid JSON: ${parseError.message}`);
      }
    }

    throw new Error(`PMD execution failed: ${error.message}`);
  }
}

/**
 * Fetch files changed in a GitHub PR
 * Tasks: T021-T024, T028-T029
 * @param {string} prUrl - GitHub PR URL
 * @param {object} options - CLI options including verbose flag
 * @returns {Promise<string[]>} Array of Apex file paths
 */
async function fetchPRFiles(prUrl, options = {}) {
  // T022: Parse PR URL to extract owner, repo, and PR number
  // T028: Validate PR URL format
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
    // T025: GITHUB_TOKEN support for authenticated API calls
    const octokit = new Octokit({
      auth: process.env.GITHUB_TOKEN
    });

    // T023: Use GitHub API to fetch PR files
    const { data: files } = await octokit.pulls.listFiles({
      owner,
      repo,
      pull_number: parseInt(pullNumber, 10)
    });

    // T024: Filter to only .cls files (Apex classes)
    const apexFiles = files
      .map(f => f.filename)
      .filter(f => f.endsWith('.cls'));

    if (options.verbose) {
      console.log(`[GitHub] Found ${files.length} total files, ${apexFiles.length} Apex files`);
      apexFiles.forEach(f => console.log(`  - ${f}`));
    }

    return apexFiles;

  } catch (error) {
    // T029: Error handling for GitHub API failures
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
 * Tasks: T017-T020, T026-T027
 * @param {object} options - CLI options (files, all, pr, verbose)
 * @returns {Promise<string[]>} Array of file paths to review
 */
async function getFilesToReview(options = {}) {
  let filesToReview = [];

  // T018: --files flag (comma-separated paths)
  if (options.files) {
    filesToReview = options.files.split(',').map(f => f.trim());

    if (options.verbose) {
      console.log(`[Files] Using manually specified files (${filesToReview.length})`);
    }
  }
  // T020: --pr flag (GitHub PR URL)
  else if (options.pr) {
    filesToReview = await fetchPRFiles(options.pr, options);
  }
  // T019: --all flag (all Apex files in force-app/)
  else if (options.all) {
    const findCommand = 'find force-app -type f -name "*.cls"';

    if (options.verbose) {
      console.log(`[Files] Finding all Apex files: ${findCommand}`);
    }

    try {
      const output = execSync(findCommand, { encoding: 'utf-8' });
      filesToReview = output.trim().split('\n').filter(f => f.length > 0);

      if (options.verbose) {
        console.log(`[Files] Found ${filesToReview.length} Apex files`);
      }
    } catch (error) {
      throw new Error(`Failed to find Apex files: ${error.message}`);
    }
  }
  else {
    throw new Error('No file detection method specified. Use --files, --pr, or --all');
  }

  // T026: Validate file paths exist
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

  // T027: Error handling for no files found
  if (existingFiles.length === 0) {
    throw new Error('No valid Apex files found to review');
  }

  if (options.verbose) {
    console.log(`[Files] ${existingFiles.length} files will be reviewed`);
  }

  return existingFiles;
}

/**
 * Prepare review prompt by replacing template variables
 * Tasks: T030-T036
 * @param {string} templatePath - Path to prompt template file
 * @param {string} pmdReport - PMD JSON report content
 * @param {string[]} filePaths - Array of file paths to review
 * @param {object} options - CLI options including verbose flag
 * @returns {string} Prepared prompt with variables replaced
 */
function preparePrompt(templatePath, pmdReport, filePaths, options = {}) {
  // T031: Read template file
  // T034: Error handling for missing template
  if (!fs.existsSync(templatePath)) {
    throw new Error(`Prompt template not found: ${templatePath}`);
  }

  try {
    let prompt = fs.readFileSync(templatePath, 'utf-8');

    // T032: Replace PMD report placeholder
    prompt = prompt.replace(/\{!\$Input:pmd_report_json\}/g, pmdReport);

    // T033: Replace file paths placeholder
    const filePathsStr = filePaths.join(',');
    prompt = prompt.replace(/\{!\$Input:file_paths\}/g, filePathsStr);

    // T036: Verbose logging with truncated prompt preview
    if (options.verbose) {
      console.log(`[Prompt] Template loaded: ${templatePath}`);
      console.log(`[Prompt] Length: ${prompt.length} characters`);
      console.log(`[Prompt] Preview (first 100 chars): ${prompt.substring(0, 100)}...`);
      console.log(`[Prompt] Preview (last 100 chars): ...${prompt.substring(prompt.length - 100)}`);
    }

    // T035: Validate all variables were replaced
    const unreplacedVars = prompt.match(/\{!\$Input:[^}]+\}/g);
    if (unreplacedVars) {
      throw new Error(`Template contains unreplaced variables: ${unreplacedVars.join(', ')}`);
    }

    return prompt;

  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error(`Failed to read template file: ${templatePath}`);
    }
    throw error;
  }
}

/**
 * Execute code review using Claude Code SDK
 * Tasks: T037-T045
 * @param {string} prompt - Prepared review prompt
 * @param {object} options - CLI options including verbose flag
 * @returns {Promise<string>} Review result text
 */
async function executeReview(prompt, options = {}) {
  // T042: Check for API key
  if (!process.env.ANTHROPIC_API_KEY) {
    throw new Error('ANTHROPIC_API_KEY environment variable not set. Please add it to .env file');
  }

  // T038: Initialize Anthropic SDK client
  const anthropic = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY
  });

  // T045: Verbose logging for request metadata
  if (options.verbose) {
    console.log(`[Claude] Sending review request`);
    console.log(`[Claude] Model: claude-sonnet-4-20250514`);
    console.log(`[Claude] Max tokens: 16000`);
    console.log(`[Claude] Prompt length: ${prompt.length} characters`);
  }

  try {
    // T039: Configure message parameters
    // T040: Send review prompt
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 16000,
      messages: [{
        role: 'user',
        content: prompt
      }]
    });

    // T041: Extract text response
    const reviewText = message.content[0].text;

    // T045: Verbose logging for response metadata
    if (options.verbose) {
      console.log(`[Claude] Review completed`);
      console.log(`[Claude] Response length: ${reviewText.length} characters`);
      console.log(`[Claude] Stop reason: ${message.stop_reason}`);
      console.log(`[Claude] Usage: ${JSON.stringify(message.usage)}`);
    }

    return reviewText;

  } catch (error) {
    // T043: Error handling for SDK call failures
    // T044: Timeout handling (handled by SDK)
    if (error.status === 401) {
      throw new Error('Authentication failed. Please check your ANTHROPIC_API_KEY');
    }
    if (error.status === 429) {
      throw new Error('Rate limit exceeded. Please try again later');
    }
    if (error.code === 'ENOTFOUND' || error.code === 'ETIMEDOUT') {
      throw new Error(`Network error: ${error.message}`);
    }
    throw new Error(`Claude API error: ${error.message}`);
  }
}

/**
 * Save review report to file
 * Tasks: T046-T051
 * @param {string} reviewText - Review result text
 * @param {object} options - CLI options including ticket ID and output directory
 * @returns {string} Path to saved report
 */
function saveReport(reviewText, options = {}) {
  const outputDir = options.output || 'docs/analysis';

  // T050: Ensure output directory exists
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // T047-T048: Generate filename with optional ticket prefix
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const ticketPrefix = options.ticket ? `${options.ticket}-` : '';
  const filename = `${ticketPrefix}apex-code-review-${timestamp}.md`;
  const reportPath = path.join(outputDir, filename);

  try {
    // T049: Save to file
    fs.writeFileSync(reportPath, reviewText, 'utf-8');

    if (options.verbose) {
      console.log(`[Report] Saved to: ${reportPath}`);
    }

    return reportPath;

  } catch (error) {
    // T051: Error handling
    throw new Error(`Failed to save report: ${error.message}`);
  }
}

/**
 * Display summary of review results
 * Tasks: T052-T058
 * @param {string} reviewText - Review result text
 * @param {string} reportPath - Path to saved report
 * @param {object} options - CLI options
 */
function displaySummary(reviewText, reportPath, options = {}) {
  console.log('\n=== Code Review Summary ===');

  // T053-T054: Try to parse JSON and display metrics
  try {
    const review = JSON.parse(reviewText);

    if (review.overall_assessment) {
      console.log(`Production Readiness: ${review.overall_assessment.production_readiness || 'N/A'}`);
      console.log(`RFC Compliance: ${review.overall_assessment.rfc_compliance_status || 'N/A'}`);
      console.log(`Confidence Score: ${review.overall_assessment.confidence_score || 'N/A'}`);
    }

    // T055: Display violation counts
    if (review.critical_violations) {
      console.log(`Critical Violations: ${review.critical_violations.length}`);
    }
    if (review.high_priority_issues) {
      console.log(`High Priority Issues: ${review.high_priority_issues.length}`);
    }

    // T056: Display static analysis summary
    if (review.static_method_analysis?.summary) {
      console.log(`Static Method Analysis: ${review.static_method_analysis.summary}`);
    }

  } catch (parseError) {
    // T057: Handle non-JSON responses
    if (options.verbose) {
      console.log('[Summary] Response is not JSON format');
    }
    console.log(`Review length: ${reviewText.length} characters`);
    console.log(`Preview: ${reviewText.substring(0, 500)}...`);
  }

  // T058: Display file path
  console.log(`\nFull report: ${reportPath}`);
}

/**
 * Main CLI entry point
 * Tasks: T059-T073 (Phase 7), T107-T112 (Phase 4 integration)
 */
async function main() {
  // T060: Configure CLI
  program
    .name('apex-code-review')
    .description('Execute Apex code review using Claude Code SDK')
    .option('-f, --files <paths>', 'Comma-separated file paths to review')
    .option('-p, --pr <url>', 'GitHub PR URL to review')
    .option('-a, --all', 'Review all Apex files in force-app/')
    .option('-t, --ticket <id>', 'ClickUp ticket ID for output filename')
    .option('-o, --output <path>', 'Output directory', 'docs/analysis')
    .option('-v, --verbose', 'Verbose logging')
    .option('--mode <mode>', 'Review mode (monolithic/modular)', 'monolithic')
    .parse();

  const options = program.opts();

  try {
    // CRITICAL: Validate ANTHROPIC_API_KEY exists before proceeding
    if (!process.env.ANTHROPIC_API_KEY) {
      console.error('\n❌ ERROR: ANTHROPIC_API_KEY not found in environment');
      console.error('\nThe Apex code review requires Claude AI API access.');
      console.error('\nPlease add ANTHROPIC_API_KEY to your .env file:');
      console.error('  1. Open .env file in project root');
      console.error('  2. Add line: ANTHROPIC_API_KEY=your-api-key-here');
      console.error('  3. Save the file and try again');
      console.error('\nGet your API key from: https://console.anthropic.com/settings/keys\n');
      process.exit(1);
    }

    // Determine files to review
    const filesToReview = await getFilesToReview(options);

    // Generate PMD report
    const pmdReport = getPMDReport(options);

    // T107-T109: Conditional logic based on --mode flag
    if (options.mode === 'modular') {
      // Execute modular checkpoint-based review
      const orchestrator = new CheckpointOrchestrator(options);
      const aggregatedResults = await orchestrator.executeAllCheckpoints(filesToReview, pmdReport);

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

    } else {
      // T109: Execute monolithic review (Phase 1 logic)
      const spinner = ora('Initializing code review...').start();

      spinner.text = `Found ${filesToReview.length} files to review`;
      spinner.text = 'Preparing review prompt...';
      const prompt = preparePrompt('exec/APEX_CODE_REVIEW.md', pmdReport, filesToReview, options);

      spinner.text = 'Executing code review (this may take 2-3 minutes)...';
      const reviewResult = await executeReview(prompt, options);

      spinner.text = 'Saving report...';
      const reportPath = saveReport(reviewResult, options);

      // T071: Success message
      spinner.succeed(`Code review complete: ${reportPath}`);

      // Display summary
      displaySummary(reviewResult, reportPath, options);
    }

  } catch (error) {
    // T070: Error handling
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
  getPMDReport,
  getFilesToReview,
  fetchPRFiles,
  preparePrompt,
  executeReview,
  saveReport,
  displaySummary,
  CheckpointOrchestrator
};
