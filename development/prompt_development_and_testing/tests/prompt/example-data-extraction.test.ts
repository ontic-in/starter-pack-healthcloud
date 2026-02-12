import { describe, it, expect } from 'vitest';
import { runPromptTest } from '../../utils/prompt-test-runner';

describe('Example: Data Extraction Prompt', () => {
  const promptPath = 'prompts/Example_Data_Extraction.md';

  it('should extract name and intent from basic introduction', async () => {
    const userMessage = "Hi, I'm John Smith. I'm interested in your MBA program and would like to know more about admission requirements.";
    
    const result = await runPromptTest(promptPath, {
      User_Message: userMessage
    });

    expect(result.name).toBe('John Smith');
    expect(result.email).toBeNull();
    expect(result.phone).toBeNull();
    expect(result.interest).toContain('MBA');
    expect(result.intent).toBe('inquire');
  });

  it('should extract email, phone, and apply intent', async () => {
    const userMessage = "My email is jane.doe@email.com and my number is +65 9123 4567. I want to apply for the Data Science program.";
    
    const result = await runPromptTest(promptPath, {
      User_Message: userMessage
    });

    expect(result.name).toBeNull();
    expect(result.email).toBe('jane.doe@email.com');
    expect(result.phone).toBe('+65 9123 4567');
    expect(result.interest).toContain('Data Science');
    expect(result.intent).toBe('apply');
  });

  it('should identify schedule intent correctly', async () => {
    const userMessage = "Can I schedule a campus visit? I'm interested in your engineering courses.";
    
    const result = await runPromptTest(promptPath, {
      User_Message: userMessage
    });

    expect(result.intent).toBe('schedule');
    expect(result.interest).toContain('engineering');
  });

  it('should handle missing information gracefully', async () => {
    const userMessage = "Tell me about your programs.";
    
    const result = await runPromptTest(promptPath, {
      User_Message: userMessage
    });

    expect(result.name).toBeNull();
    expect(result.email).toBeNull();
    expect(result.phone).toBeNull();
    expect(result.intent).toBe('inquire');
  });

  it('should extract multiple contact methods', async () => {
    const userMessage = "I'm Dr. Sarah Johnson, reach me at sarah.j@company.com or +1 555-123-4567. Interested in Executive MBA.";
    
    const result = await runPromptTest(promptPath, {
      User_Message: userMessage
    });

    expect(result.name).toBe('Dr. Sarah Johnson');
    expect(result.email).toBe('sarah.j@company.com');
    expect(result.phone).toBeTruthy(); // Phone format may vary
    expect(result.interest).toContain('Executive MBA');
  });

  it('should return valid JSON structure', async () => {
    const userMessage = "Hello there!";
    
    const result = await runPromptTest(promptPath, {
      User_Message: userMessage
    });

    // Verify JSON structure
    expect(result).toHaveProperty('name');
    expect(result).toHaveProperty('email');
    expect(result).toHaveProperty('phone');
    expect(result).toHaveProperty('interest');
    expect(result).toHaveProperty('intent');
    
    // Verify intent is one of allowed values
    expect(['inquire', 'apply', 'schedule', 'other']).toContain(result.intent);
  });
});
