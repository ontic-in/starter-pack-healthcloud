#!/usr/bin/env node

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import Anthropic from '@anthropic-ai/sdk';
import { program } from 'commander';
import ora from 'ora';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 6 checkpoints for prompt template and test suite review
const CHECKPOINTS = [
  { name: '01-structure-analysis', priority: 'CRITICAL', order: 1 },
  { name: '02-decision-logic-validation', priority: 'CRITICAL', order: 2 },
  { name: '03-quality-assessment', priority: 'HIGH', order: 3 },
  { name: '04-test-suite-analysis', priority: 'CRITICAL', order: 4 },
  { name: '05-specification-alignment', priority: 'CRITICAL', order: 5 },
  { name: '06-test-suite-best-practices', priority: 'MEDIUM', order: 6 }
];

/**
 * PromptReviewOrchestrator - Executes modular checkpoint-based prompt template review
 */
class PromptReviewOrchestrator {
  private options: any;
  private anthropic: Anthropic;
  private results: any[];
  private sharedContext: any;

  constructor(options: any = {}) {
    this.options = options;

    // Initialize Anthropic client
    if (!process.env.ANTHROPIC_API_KEY) {
      throw new Error('ANTHROPIC_API_KEY environment variable not set');
    }

    this.anthropic = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY
    });

    this.results = [];
    this.sharedContext = {};

    if (options.verbose) {
      console.log('[Orchestrator] Initialized with 6 checkpoints');
    }
  }

  /**
   * Validate dependencies before execution
   */
  validateDependencies(): void {
    const requiredFiles = [
      'development/prompt_development_and_testing/guide/prompt-guide.md'
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
   */
  async executeAllCheckpoints(promptContent: string, testContent: string): Promise<any> {
    // Pre-flight validation
    this.validateDependencies();

    // Initialize spinner
    const spinner = ora('Starting checkpoint orchestration...').start();

    try {
      // Checkpoint execution loop
      for (const checkpoint of CHECKPOINTS) {
        spinner.text = `Executing ${checkpoint.name} (${checkpoint.priority})...`;

        try {
          const result = await this.executeCheckpoint(checkpoint, promptContent, testContent);
          this.results.push(result);

          if (this.options.verbose) {
            console.log(`\n[Checkpoint] ${checkpoint.name} completed`);
            console.log(`  Status: ${result.status}`);
            console.log(`  Violations: ${result.violations?.length || 0}`);
          }
        } catch (error: any) {
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

    } catch (error: any) {
      spinner.fail(`Checkpoint orchestration failed: ${error.message}`);
      throw error;
    }
  }

  /**
   * Execute single checkpoint
   */
  async executeCheckpoint(checkpoint: any, promptContent: string, testContent: string): Promise<any> {
    // Load checkpoint prompt file
    const checkpointPath = path.join('exec/prompt-template-review-checkpoints', `${checkpoint.name}.md`);

    if (!fs.existsSync(checkpointPath)) {
      throw new Error(`Checkpoint prompt not found: ${checkpointPath}`);
    }

    const checkpointPrompt = fs.readFileSync(checkpointPath, 'utf-8');

    // Prepare input JSON based on checkpoint requirements
    let inputJson: any = {};

    // CP1: Structure Analysis
    if (checkpoint.name === '01-structure-analysis') {
      inputJson = {
        prompt_template_content: promptContent
      };
    }
    // CP2: Decision Logic Validation
    else if (checkpoint.name === '02-decision-logic-validation') {
      inputJson = {
        prompt_template_content: promptContent,
        structure_results: this.sharedContext.structure_results || {
          sections_present: [],
          compliance_score: 0.0
        }
      };
    }
    // CP3: Quality Assessment
    else if (checkpoint.name === '03-quality-assessment') {
      inputJson = {
        prompt_template_content: promptContent,
        structure_results: this.sharedContext.structure_results || {},
        decision_logic_results: this.sharedContext.decision_logic_results || {}
      };
    }
    // CP4: Test Suite Analysis
    else if (checkpoint.name === '04-test-suite-analysis') {
      inputJson = {
        test_suite_content: testContent,
        test_file_name: this.options.test ? path.basename(this.options.test) : 'test.ts'
      };
    }
    // CP5: Specification Alignment
    else if (checkpoint.name === '05-specification-alignment') {
      inputJson = {
        expected_behaviors: this.sharedContext.expected_behaviors || [],
        test_scenarios: this.sharedContext.test_scenarios || [],
        tests_tell_stories_rating: this.sharedContext.tests_tell_stories_rating || 'no',
        tests_as_specification_rating: this.sharedContext.tests_as_specification_rating || 'poor'
      };
    }
    // CP6: Test Suite Best Practices
    else if (checkpoint.name === '06-test-suite-best-practices') {
      inputJson = {
        test_suite_content: testContent,
        test_scenarios: this.sharedContext.test_scenarios || []
      };
    }

    // Build the complete prompt
    const fullPrompt = `${checkpointPrompt}

## Input Data

\`\`\`json
${JSON.stringify(inputJson, null, 2)}
\`\`\`

## Task

Execute the checkpoint analysis as defined above. Return ONLY valid JSON matching the output format specified in the checkpoint prompt.`;

    if (this.options.verbose) {
      console.log(`\n[Checkpoint] ${checkpoint.name}`);
      console.log(`  Prompt length: ${fullPrompt.length} characters`);
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

    // Update shared context for next checkpoints
    if (checkpoint.name === '01-structure-analysis') {
      this.sharedContext.structure_results = {
        sections_present: result.sections_present || [],
        compliance_score: result.structure_compliance?.compliance_score || 0.0
      };
    } else if (checkpoint.name === '02-decision-logic-validation') {
      this.sharedContext.expected_behaviors = result.expected_behaviors || [];
      this.sharedContext.decision_logic_results = {
        completeness: result.decision_paths?.completeness_assessment || 'minimal',
        validation_rules_count: result.validation_rules?.length || 0
      };
    } else if (checkpoint.name === '04-test-suite-analysis') {
      this.sharedContext.test_scenarios = result.test_scenarios_identified || [];
      this.sharedContext.tests_tell_stories_rating = result.kent_beck_assessment?.tests_tell_stories || 'no';
      this.sharedContext.tests_as_specification_rating = result.kent_beck_assessment?.tests_as_specification || 'poor';
    }

    if (this.options.verbose) {
      console.log(`  Response parsed successfully`);
      console.log(`  Usage: ${JSON.stringify(message.usage)}`);
    }

    return result;
  }

  /**
   * Aggregate results from all checkpoints
   */
  aggregateResults(): any {
    if (this.options.verbose) {
      console.log('\n[Aggregation] Combining checkpoint results...');
    }

    // Basic aggregation structure
    const allViolations: any[] = [];
    const checkpointSummaries: any[] = [];

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
    const criticalViolations = uniqueViolations.filter((v: any) => v.severity === 'critical');
    const highViolations = uniqueViolations.filter((v: any) => v.severity === 'high');
    const mediumViolations = uniqueViolations.filter((v: any) => v.severity === 'medium');
    const lowViolations = uniqueViolations.filter((v: any) => v.severity === 'low');

    // Calculate PASS/FAIL based on 5 criteria from CP5
    const cp5Result = this.results.find((r: any) => r.checkpoint_name === '05-specification-alignment');
    const cp4Result = this.results.find((r: any) => r.checkpoint_name === '04-test-suite-analysis');

    const allBehaviorsTested = cp5Result?.summary?.behaviors_without_tests_count === 0;
    const noGenericTestNames = cp4Result?.kent_beck_assessment?.tests_tell_stories === 'yes';
    const noCriticalViolations = criticalViolations.length === 0;
    const alignmentScoreAcceptable = (cp5Result?.alignment_score || 0) >= 0.7;
    const kentBeckQualityAcceptable = ['excellent', 'good'].includes(cp4Result?.kent_beck_assessment?.tests_as_specification || 'poor');

    const passCriteria = {
      all_behaviors_tested: allBehaviorsTested,
      no_generic_test_names: noGenericTestNames,
      no_critical_violations: noCriticalViolations,
      alignment_score_acceptable: alignmentScoreAcceptable,
      kent_beck_quality_acceptable: kentBeckQualityAcceptable
    };

    const allCriteriaMet = Object.values(passCriteria).every(Boolean);

    // Determine production readiness
    const hasProductionBlockers = this.results.some((r: any) => r.summary?.production_blocker === true);
    const productionReadiness = hasProductionBlockers ? 'critical-issues' :
                                !allCriteriaMet ? 'needs-fixes' :
                                criticalViolations.length > 0 ? 'needs-fixes' :
                                highViolations.length > 0 ? 'ready-with-improvements' :
                                'production-ready';

    return {
      metadata: {
        review_type: 'modular-checkpoint-prompt-review',
        timestamp: new Date().toISOString(),
        checkpoints_executed: this.results.length,
        total_violations: uniqueViolations.length
      },
      overall_assessment: {
        production_readiness: productionReadiness,
        confidence_score: confidenceScore,
        confidence_rationale: confidenceRationale,
        has_production_blockers: hasProductionBlockers,
        pass_fail_status: allCriteriaMet ? 'PASS' : 'FAIL',
        pass_criteria: passCriteria
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
   */
  calculateOverallConfidence(violations: any[]): number {
    // Checkpoint-specific confidence weights
    const confidenceWeights: any = {
      '01-structure-analysis': 0.9,
      '02-decision-logic-validation': 0.7,
      '03-quality-assessment': 0.6,
      '04-test-suite-analysis': 0.7,
      '05-specification-alignment': 0.8,
      '06-test-suite-best-practices': 0.8
    };

    // Weighted average based on violations found
    let totalWeight = 0;
    let weightedSum = 0;

    for (const result of this.results) {
      const checkpointName = result.checkpoint_name;
      const weight = confidenceWeights[checkpointName] || 0.5;
      const violationCount = result.violations?.length || 0;

      // Weight by number of violations (more violations = more data = higher confidence in that checkpoint)
      const adjustedWeight = weight * (1 + violationCount * 0.1);

      totalWeight += adjustedWeight;
      weightedSum += weight * adjustedWeight;
    }

    const overallConfidence = totalWeight > 0 ? weightedSum / totalWeight : 0.7;

    return Math.round(overallConfidence * 100) / 100; // Round to 2 decimal places
  }

  /**
   * Generate confidence rationale
   */
  generateConfidenceRationale(violations: any[]): string {
    const sources = [];

    // Count violations by checkpoint
    const checkpointCounts: any = {};
    for (const violation of violations) {
      const checkpoint = violation.category?.split(':')[0] || 'Unknown';
      checkpointCounts[checkpoint] = (checkpointCounts[checkpoint] || 0) + 1;
    }

    // Evidence source listing
    for (const [checkpoint, count] of Object.entries(checkpointCounts)) {
      sources.push(`${checkpoint} (${count} findings)`);
    }

    return `Confidence based on ${this.results.length} checkpoint executions: ${sources.join(', ')}. ` +
           `Higher confidence in structure analysis (0.9) and alignment checks (0.8), ` +
           `moderate confidence in test analysis (0.7-0.8), ` +
           `lower confidence in subjective quality assessments (0.6-0.7).`;
  }

  /**
   * Deduplicate violations across checkpoints
   */
  deduplicateViolations(violations: any[]): any[] {
    // Map-based deduplication using category:issue keys
    const violationMap = new Map();

    for (const violation of violations) {
      const key = `${violation.category}:${violation.issue}`;

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
   */
  generateReport(aggregatedResults: any): string {
    const lines = [];

    // Checkpoint execution summary
    lines.push('# Prompt Template & Test Suite Review - Modular Checkpoint Analysis');
    lines.push('');
    lines.push(`**Review Date**: ${aggregatedResults.metadata.timestamp}`);
    lines.push(`**Review Type**: ${aggregatedResults.metadata.review_type}`);
    lines.push(`**Checkpoints Executed**: ${aggregatedResults.metadata.checkpoints_executed}/6`);
    lines.push(`**Total Violations**: ${aggregatedResults.metadata.total_violations}`);
    lines.push('');

    // Overall assessment
    lines.push('## Overall Assessment');
    lines.push('');
    lines.push(`**PASS/FAIL**: ${aggregatedResults.overall_assessment.pass_fail_status} ${aggregatedResults.overall_assessment.pass_fail_status === 'PASS' ? '✅' : '❌'}`);
    lines.push(`**Production Readiness**: ${aggregatedResults.overall_assessment.production_readiness}`);
    lines.push(`**Confidence Score**: ${aggregatedResults.overall_assessment.confidence_score}`);
    lines.push(`**Has Production Blockers**: ${aggregatedResults.overall_assessment.has_production_blockers ? 'YES ⚠️' : 'No'}`);
    lines.push('');

    // PASS/FAIL criteria breakdown
    lines.push('### PASS/FAIL Criteria (All 5 must be TRUE)');
    lines.push('');
    const criteria = aggregatedResults.overall_assessment.pass_criteria;
    lines.push(`1. ✅ All behaviors tested: ${criteria.all_behaviors_tested ? 'TRUE' : 'FALSE'}`);
    lines.push(`2. ${criteria.no_generic_test_names ? '✅' : '❌'} No generic test names: ${criteria.no_generic_test_names ? 'TRUE' : 'FALSE'}`);
    lines.push(`3. ${criteria.no_critical_violations ? '✅' : '❌'} No critical violations: ${criteria.no_critical_violations ? 'TRUE' : 'FALSE'}`);
    lines.push(`4. ${criteria.alignment_score_acceptable ? '✅' : '❌'} Alignment score >= 0.7: ${criteria.alignment_score_acceptable ? 'TRUE' : 'FALSE'}`);
    lines.push(`5. ${criteria.kent_beck_quality_acceptable ? '✅' : '❌'} Kent Beck quality good/excellent: ${criteria.kent_beck_quality_acceptable ? 'TRUE' : 'FALSE'}`);
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
      lines.push(`Found ${criticalViolations.length} critical violation(s) that must be addressed.`);
      lines.push('');

      for (const violation of criticalViolations) {
        lines.push(`### ${violation.category}`);
        lines.push('');
        lines.push(`**Issue**: ${violation.issue}`);
        lines.push(`**Confidence**: ${violation.confidence}`);
        lines.push('');
        lines.push('**Evidence**:');
        lines.push('```');
        lines.push(violation.evidence || 'N/A');
        lines.push('```');
        lines.push('');
        lines.push('**Fix Guidance**:');
        lines.push(violation.fix_guidance || 'No guidance provided');
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
      const byCategory: any = {};
      for (const violation of highViolations) {
        const category = violation.category || 'Uncategorized';
        if (!byCategory[category]) {
          byCategory[category] = [];
        }
        byCategory[category].push(violation);
      }

      for (const [category, violations] of Object.entries(byCategory)) {
        const viols = violations as any[];
        lines.push(`### ${category} (${viols.length} issue${viols.length > 1 ? 's' : ''})`);
        lines.push('');
        for (const violation of viols) {
          lines.push(`- ${violation.issue}`);
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
          lines.push(`- ${violation.category}: ${violation.issue}`);
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
    const passedCheckpoints = aggregatedResults.checkpoint_results.filter((c: any) => c.status === 'pass');
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
}

/**
 * Main CLI entry point
 */
async function main() {
  // Configure CLI
  program
    .name('prompt-review')
    .description('Execute prompt template and test suite review using modular checkpoints')
    .requiredOption('-p, --prompt <path>', 'Path to prompt template file')
    .requiredOption('-t, --test <path>', 'Path to test suite file')
    .option('-v, --verbose', 'Verbose logging')
    .parse();

  const options = program.opts();

  try {
    // CRITICAL: Validate ANTHROPIC_API_KEY exists before proceeding
    if (!process.env.ANTHROPIC_API_KEY) {
      console.error('\n❌ ERROR: ANTHROPIC_API_KEY not found in environment');
      console.error('\nThe prompt review requires Claude AI API access.');
      console.error('\nPlease add ANTHROPIC_API_KEY to your .env file:');
      console.error('  1. Open .env file in project root');
      console.error('  2. Add line: ANTHROPIC_API_KEY=your-api-key-here');
      console.error('  3. Save the file and try again');
      console.error('\nGet your API key from: https://console.anthropic.com/settings/keys\n');
      process.exit(1);
    }

    // Validate prompt file exists
    if (!fs.existsSync(options.prompt)) {
      throw new Error(`Prompt file not found: ${options.prompt}`);
    }

    // Validate test file exists
    if (!fs.existsSync(options.test)) {
      throw new Error(`Test file not found: ${options.test}`);
    }

    // Read files
    const promptContent = fs.readFileSync(options.prompt, 'utf-8');
    const testContent = fs.readFileSync(options.test, 'utf-8');

    if (options.verbose) {
      console.log(`[Files] Prompt: ${options.prompt} (${promptContent.length} chars)`);
      console.log(`[Files] Test: ${options.test} (${testContent.length} chars)`);
    }

    // Execute modular checkpoint-based review
    const orchestrator = new PromptReviewOrchestrator(options);
    const aggregatedResults = await orchestrator.executeAllCheckpoints(promptContent, testContent);

    // Generate report
    const report = orchestrator.generateReport(aggregatedResults);

    // Determine severity for exit code and display
    const passFail = aggregatedResults.overall_assessment.pass_fail_status;
    const hasProductionBlockers = aggregatedResults.overall_assessment.has_production_blockers;
    const criticalCount = aggregatedResults.violations_by_severity.critical.length;
    const highCount = aggregatedResults.violations_by_severity.high.length;
    const totalViolations = aggregatedResults.metadata.total_violations;

    // Print report to console
    console.log('\n' + '='.repeat(80));
    console.log(report);
    console.log('='.repeat(80) + '\n');

    // Display summary with appropriate emoji
    if (passFail === 'PASS') {
      console.log(`\n✅ Prompt review PASSED - All 5 criteria met`);
    } else {
      console.log(`\n❌ Prompt review FAILED - Not all criteria met`);
    }

    console.log(`\n📊 Summary:`);
    console.log(`   Production Readiness: ${aggregatedResults.overall_assessment.production_readiness}`);
    console.log(`   Confidence Score: ${aggregatedResults.overall_assessment.confidence_score}`);
    console.log(`   Total Violations: ${totalViolations}`);

    if (criticalCount > 0 || highCount > 0) {
      console.log(`   🚨 Critical: ${criticalCount}`);
      console.log(`   ⚠️  High: ${highCount}`);
    }

    // PASS/FAIL criteria
    console.log(`\n   PASS/FAIL Criteria:`);
    const criteria = aggregatedResults.overall_assessment.pass_criteria;
    console.log(`   ${criteria.all_behaviors_tested ? '✅' : '❌'} All behaviors tested`);
    console.log(`   ${criteria.no_generic_test_names ? '✅' : '❌'} No generic test names`);
    console.log(`   ${criteria.no_critical_violations ? '✅' : '❌'} No critical violations`);
    console.log(`   ${criteria.alignment_score_acceptable ? '✅' : '❌'} Alignment score >= 0.7`);
    console.log(`   ${criteria.kent_beck_quality_acceptable ? '✅' : '❌'} Kent Beck quality good/excellent`);

    if (passFail === 'FAIL') {
      console.error(`\n❌ REVIEW FAILED: Not all criteria met!`);
      console.error(`   Review the output above for issues that must be fixed.\n`);
      process.exit(1); // Exit with error code
    } else {
      console.log(`\n✅ All criteria met. Prompt template and test suite are production-ready.\n`);
    }

  } catch (error: any) {
    // Error handling
    console.error(`\n❌ Prompt review failed: ${error.message}`);
    if (options.verbose) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

// Auto-run main when executed directly
main();

export {
  PromptReviewOrchestrator,
  CHECKPOINTS
};
