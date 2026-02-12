#!/usr/bin/env npx tsx

/**
 * Video Frame Extraction Tool for Playwright Test Videos
 *
 * REQUIRED DEPENDENCIES (must be installed in the project using this script):
 * npm install --save-dev commander ffmpeg-extract-frames fluent-ffmpeg @types/fluent-ffmpeg
 *
 * REQUIRED SYSTEM DEPENDENCY:
 * brew install ffmpeg (macOS) or apt-get install ffmpeg (Linux)
 *
 * Usage:
 * npx tsx run/extract-video-frames-local.ts path/to/video.webm --interval 1 --verbose
 * npx tsx run/extract-video-frames-local.ts --all-playwright --interval 2
 */

import fs from 'fs';
import path from 'path';
import { Command } from 'commander';
import ffmpeg from 'fluent-ffmpeg';
import extractFrames from 'ffmpeg-extract-frames';

// Type definitions for ffmpeg
interface FFmpegFormat {
  duration?: number;
}

interface FFmpegMetadata {
  format: FFmpegFormat;
}

interface CommandOptions {
  interval: string;
  output: string;
  format: string;
  prefix: string;
  verbose: boolean;
  allPlaywright: boolean;
}

interface ExtractFramesOptions {
  interval: number;
  output: string;
  format: string;
  prefix: string;
  verbose: boolean;
}

/**
 * Get video duration in seconds
 */
// eslint-disable-next-line require-await
async function getVideoDuration(videoPath: string): Promise<number> {
  return new Promise((resolve, reject) => {
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access
    ffmpeg.ffprobe(videoPath, (err: Error | null, metadata: FFmpegMetadata) => {
      if (err) {
        reject(err);
        return;
      }
      
      const duration = metadata.format.duration;
      if (duration) {
        resolve(duration);
      } else {
        reject(new Error('Could not determine video duration'));
      }
    });
  });
}

/**
 * Generate timestamps at regular intervals
 */
export function generateTimestamps(duration: number, interval: number): number[] {
  const timestamps: number[] = [];
  
  for (let time = 0; time < duration; time += interval) {
    timestamps.push(time);
  }
  
  return timestamps;
}

/**
 * Calculate padding width for timestamps
 */
export function calculatePaddingWidth(timestamps: number[]): number {
  const maxTimestamp = Math.max(...timestamps);
  return Math.max(3, maxTimestamp.toString().length + 1);
}

/**
 * Create zero-padded timestamps for alphabetical sorting
 */
export function createPaddedTimestamps(timestamps: number[]): string[] {
  const paddingWidth = calculatePaddingWidth(timestamps);
  return timestamps.map(t => t.toString().padStart(paddingWidth, '0'));
}

/**
 * Generate ordered frame names for a given video duration and interval
 */
export function generateOrderedFrameNames(duration: number, interval: number, prefix: string, format: string): string[] {
  const timestamps = generateTimestamps(duration, interval);
  const paddedTimestamps = createPaddedTimestamps(timestamps);
  return paddedTimestamps.map(ts => `${prefix}-${ts}.${format}`);
}

/**
 * Extract frames from video at specified intervals
 */
async function extractVideoFrames(
  videoPath: string,
  options: ExtractFramesOptions
): Promise<void> {
  const { interval, format, prefix, verbose } = options;
  
  if (verbose) {
    console.log(`📹 Processing video: ${videoPath}`);
  }
  
  // Check if video file exists
  if (!fs.existsSync(videoPath)) {
    throw new Error(`Video file not found: ${videoPath}`);
  }
  
  // Get video duration
  const duration = await getVideoDuration(videoPath);
  if (verbose) {
    console.log(`⏱️  Video duration: ${duration.toFixed(2)} seconds`);
  }
  
  // Generate timestamps
  const timestamps = generateTimestamps(duration, interval);
  if (verbose) {
    console.log(`🎯 Extracting ${timestamps.length} frames at ${interval}s intervals`);
  }
  
  // Extract frames into the same directory as the video
  const videoDir = path.dirname(videoPath);
  const paddedTimestamps = createPaddedTimestamps(timestamps);
  
  try {
    // Extract frames individually with custom naming to ensure proper sorting
    for (let i = 0; i < timestamps.length; i++) {
      const timestamp = timestamps[i];
      const paddedTimestamp = paddedTimestamps[i];
      const outputFile = path.join(videoDir, `${prefix}-${paddedTimestamp}.${format}`);
      
      // eslint-disable-next-line @typescript-eslint/no-unsafe-call
      await extractFrames({
        input: videoPath,
        output: outputFile,
        timestamps: [timestamp.toString()],
      // eslint-disable-next-line @typescript-eslint/no-unsafe-member-access
      }).catch((error: Error) => {
        throw new Error(`Failed to extract frame at ${timestamp}s: ${error.message}`);
      });
    }
    
    if (verbose) {
      console.log(`✅ Successfully extracted frames to: ${videoDir}`);
      console.log(`🖼️  Files named: ${prefix}-{zero_padded_timestamp}.${format}`);
    }
  } catch (error) {
    throw new Error(`Failed to extract frames: ${error}`);
  }
}

/**
 * Process multiple video files
 */
async function processMultipleVideos(
  videoPaths: string[],
  options: ExtractFramesOptions
): Promise<void> {
  console.log(`🎬 Processing ${videoPaths.length} video files...\n`);
  
  for (const videoPath of videoPaths) {
    try {
      const videoName = path.basename(videoPath, path.extname(videoPath));
      await extractVideoFrames(videoPath, options);
      console.log(`✅ Completed: ${videoName}\n`);
    } catch (error) {
      console.error(`❌ Error processing ${videoPath}: ${error}`);
    }
  }
}

/**
 * Find all Playwright test videos
 */
function findPlaywrightVideos(): string[] {
  const testResultsDir = path.join(process.cwd(), 'test-results');
  
  if (!fs.existsSync(testResultsDir)) {
    return [];
  }
  
  const videos: string[] = [];
  
  function scanDirectory(dir: string): void {
    const entries = fs.readdirSync(dir);
    
    for (const entry of entries) {
      const fullPath = path.join(dir, entry);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        scanDirectory(fullPath);
      } else if (entry === 'video.webm') {
        videos.push(fullPath);
      }
    }
  }
  
  scanDirectory(testResultsDir);
  return videos;
}

/**
 * Main CLI function
 */
function main(): void {
  const program = new Command();
  
  program
    .name('extract-video-frames')
    .description('Extract frames from video files at regular intervals')
    .version('1.0.0')
    .addHelpText('after', `
Examples:
  Extract frames from a single video:
    npx tsx scripts/extract-video-frames.ts path/to/video.webm --interval 5 --verbose

  Process all Playwright videos:
    npx tsx scripts/extract-video-frames.ts --all-playwright --interval 2 --format png

  Custom output configuration:
    npx tsx scripts/extract-video-frames.ts video.webm --prefix screenshot --interval 1

Output:
  Frames are extracted into the same directory as the video file with timestamped names:
  - frame-0.jpg      (frame at 0 seconds)
  - frame-3000.jpg   (frame at 3 seconds)
  - frame-6000.jpg   (frame at 6 seconds)

Requirements:
  - FFmpeg must be installed: brew install ffmpeg
  - Node.js packages: pnpm add ffmpeg-extract-frames fluent-ffmpeg commander

For more details, see: documentation/VIDEO_FRAME_EXTRACTION_SPEC.md
`);
  
  program
    .argument('[video-path]', 'Path to video file (optional, will scan for Playwright videos if not provided)')
    .option('-i, --interval <seconds>', 'Interval between frames in seconds', '3')
    .option('-o, --output <path>', 'Output directory path (deprecated - frames now go to video directory)', './extracted-frames/frame.jpg')
    .option('-f, --format <format>', 'Output image format', 'jpg')
    .option('-p, --prefix <prefix>', 'Filename prefix', 'frame')
    .option('-v, --verbose', 'Verbose output', false)
    .option('--all-playwright', 'Process all Playwright test videos', false)
    .action(async (videoPath: string | undefined, options: CommandOptions) => {
      try {
        const extractOptions: ExtractFramesOptions = {
          interval: parseFloat(options.interval),
          output: options.output,
          format: options.format,
          prefix: options.prefix,
          verbose: options.verbose,
        };
        
        if (options.allPlaywright || !videoPath) {
          // Process all Playwright videos
          const playwrightVideos = findPlaywrightVideos();
          
          if (playwrightVideos.length === 0) {
            console.log('❌ No Playwright test videos found in test-results/');
            process.exit(1);
          }
          
          if (options.verbose) {
            console.log(`📁 Found ${playwrightVideos.length} Playwright videos:`);
            playwrightVideos.forEach(video => {
              console.log(`   - ${video}`);
            });
            console.log('');
          }
          
          await processMultipleVideos(playwrightVideos, extractOptions);
        } else {
          // Process single video
          await extractVideoFrames(videoPath, extractOptions);
        }
        
        console.log('🎉 Frame extraction completed successfully!');
      } catch (error) {
        console.error(`❌ Error: ${String(error)}`);
        process.exit(1);
      }
    });
  
  program.parse();
}

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Check if this is the main module (ES module equivalent)
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { extractVideoFrames, findPlaywrightVideos };