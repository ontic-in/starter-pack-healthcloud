/**
 * Seed Data Script: Care Plan Templates
 * ======================================
 * Creates 3 care plan templates with associated goals and tasks
 * for the Patient 360 Health Cloud starter pack.
 *
 * Run via: sf apex run --file scripts/seedCarePlanTemplates.apex
 *
 * Templates:
 *   1. Diabetes Management Protocol (ICD-10: E11)
 *   2. Hypertension Control Protocol (ICD-10: I10)
 *   3. Cardiac Risk Reduction Protocol (ICD-10: I25)
 *
 * Uses bulkified DML: all goals inserted in one batch, all tasks in one batch.
 */

// ============================================================================
// STEP 1: Create Care Plan Templates
// ============================================================================

// -- Template 1: Diabetes Management Protocol --
CarePlanTemplate diabetesTemplate = new CarePlanTemplate(
    Name = 'Diabetes Management Protocol',
    Description = 'Standardised care plan for Type 2 Diabetes based on MOH Clinical Practice Guidelines',
    ICD10_Code__c = 'E11',
    Version__c = 1,
    IsActive = true,
    MOH_Guideline_Ref__c = 'https://www.moh.gov.sg/resources-statistics/guidelines/cpg'
);

// -- Template 2: Hypertension Control Protocol --
CarePlanTemplate hypertensionTemplate = new CarePlanTemplate(
    Name = 'Hypertension Control Protocol',
    Description = 'Standardised care plan for Essential Hypertension based on MOH guidelines',
    ICD10_Code__c = 'I10',
    Version__c = 1,
    IsActive = true
);

// -- Template 3: Cardiac Risk Reduction Protocol --
CarePlanTemplate cardiacTemplate = new CarePlanTemplate(
    Name = 'Cardiac Risk Reduction Protocol',
    Description = 'Standardised care plan for Chronic Ischaemic Heart Disease and cardiac risk reduction',
    ICD10_Code__c = 'I25',
    Version__c = 1,
    IsActive = true
);

List<CarePlanTemplate> templates = new List<CarePlanTemplate>{
    diabetesTemplate,
    hypertensionTemplate,
    cardiacTemplate
};
insert templates;

System.debug('Created ' + templates.size() + ' Care Plan Templates');
System.debug('  [1] ' + diabetesTemplate.Name + ' (Id: ' + diabetesTemplate.Id + ')');
System.debug('  [2] ' + hypertensionTemplate.Name + ' (Id: ' + hypertensionTemplate.Id + ')');
System.debug('  [3] ' + cardiacTemplate.Name + ' (Id: ' + cardiacTemplate.Id + ')');

// ============================================================================
// STEP 2: Create Care Plan Template Goals (bulkified)
// ============================================================================

List<CarePlanTemplateGoal> allGoals = new List<CarePlanTemplateGoal>();

// -- Diabetes Goals (6) --
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = diabetesTemplate.Id,
    Name = 'HbA1c Control',
    Target_Value__c = '< 7.0%',
    Measure__c = 'HbA1c blood test',
    Review_Frequency__c = 'Quarterly'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = diabetesTemplate.Id,
    Name = 'Blood Pressure',
    Target_Value__c = '< 140/90 mmHg',
    Measure__c = 'BP reading',
    Review_Frequency__c = 'Per Visit'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = diabetesTemplate.Id,
    Name = 'LDL Cholesterol',
    Target_Value__c = '< 2.6 mmol/L',
    Measure__c = 'Lipid panel',
    Review_Frequency__c = '6-Monthly'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = diabetesTemplate.Id,
    Name = 'BMI Reduction',
    Target_Value__c = '< 25 kg/m2',
    Measure__c = 'Weight/height measurement',
    Review_Frequency__c = 'Monthly'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = diabetesTemplate.Id,
    Name = 'Foot Assessment',
    Target_Value__c = 'No ulcers',
    Measure__c = 'Visual inspection',
    Review_Frequency__c = '6-Monthly'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = diabetesTemplate.Id,
    Name = 'Eye Screening',
    Target_Value__c = 'No retinopathy',
    Measure__c = 'Fundoscopy',
    Review_Frequency__c = 'Annually'
));

// -- Hypertension Goals (4) --
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Name = 'Systolic BP',
    Target_Value__c = '< 140 mmHg',
    Measure__c = 'BP reading',
    Review_Frequency__c = 'Per Visit'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Name = 'Diastolic BP',
    Target_Value__c = '< 90 mmHg',
    Measure__c = 'BP reading',
    Review_Frequency__c = 'Per Visit'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Name = 'Salt Intake',
    Target_Value__c = '< 5g/day',
    Measure__c = 'Dietary assessment',
    Review_Frequency__c = 'Monthly'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Name = 'Exercise',
    Target_Value__c = '150 min/week',
    Measure__c = 'Patient report',
    Review_Frequency__c = 'Monthly'
));

// -- Cardiac Goals (5) --
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = cardiacTemplate.Id,
    Name = 'LDL Cholesterol',
    Target_Value__c = '< 1.8 mmol/L',
    Measure__c = 'Lipid panel',
    Review_Frequency__c = 'Quarterly'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = cardiacTemplate.Id,
    Name = 'Resting Heart Rate',
    Target_Value__c = '60-80 bpm',
    Measure__c = 'ECG/pulse',
    Review_Frequency__c = 'Per Visit'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = cardiacTemplate.Id,
    Name = 'Exercise Tolerance',
    Target_Value__c = '6-min walk > 400m',
    Measure__c = 'Walk test',
    Review_Frequency__c = '6-Monthly'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = cardiacTemplate.Id,
    Name = 'Smoking Cessation',
    Target_Value__c = 'Non-smoker',
    Measure__c = 'Patient report',
    Review_Frequency__c = 'Per Visit'
));
allGoals.add(new CarePlanTemplateGoal(
    CarePlanTemplateId = cardiacTemplate.Id,
    Name = 'Weight Management',
    Target_Value__c = 'BMI < 25',
    Measure__c = 'Weight measurement',
    Review_Frequency__c = 'Monthly'
));

insert allGoals;

System.debug('Created ' + allGoals.size() + ' Care Plan Template Goals');
System.debug('  Diabetes goals: 6');
System.debug('  Hypertension goals: 4');
System.debug('  Cardiac goals: 5');

// ============================================================================
// STEP 3: Create Care Plan Template Tasks (bulkified)
// ============================================================================

List<CarePlanTemplateTask> allTasks = new List<CarePlanTemplateTask>();

// -- Diabetes Tasks (8) --
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'HbA1c blood test order',
    Assigned_Role__c = 'Primary Physician',
    Task_Frequency__c = 'Quarterly',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'Medication review',
    Assigned_Role__c = 'Primary Physician',
    Task_Frequency__c = 'Quarterly',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'Diet counselling session',
    Assigned_Role__c = 'Care Coordinator',
    Task_Frequency__c = 'Monthly',
    Priority = 'Medium'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'Exercise plan review',
    Assigned_Role__c = 'Allied Health',
    Task_Frequency__c = 'Monthly',
    Priority = 'Medium'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'Foot examination',
    Assigned_Role__c = 'Nurse',
    Task_Frequency__c = '6-Monthly',
    Priority = 'Medium'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'Eye screening referral',
    Assigned_Role__c = 'Primary Physician',
    Task_Frequency__c = 'Annually',
    Priority = 'Medium'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'Diabetes self-management education',
    Assigned_Role__c = 'Care Coordinator',
    Task_Frequency__c = 'Once',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = diabetesTemplate.Id,
    Subject = 'Medisave claim review',
    Assigned_Role__c = 'Admin Staff',
    Task_Frequency__c = 'Quarterly',
    Priority = 'Low'
));

// -- Hypertension Tasks (5) --
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Subject = 'BP measurement',
    Assigned_Role__c = 'Nurse',
    Task_Frequency__c = 'Every Visit',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Subject = 'Medication review',
    Assigned_Role__c = 'Primary Physician',
    Task_Frequency__c = 'Quarterly',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Subject = 'Dietary sodium counselling',
    Assigned_Role__c = 'Care Coordinator',
    Task_Frequency__c = 'Monthly',
    Priority = 'Medium'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Subject = 'Home BP monitoring setup',
    Assigned_Role__c = 'Nurse',
    Task_Frequency__c = 'Once',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = hypertensionTemplate.Id,
    Subject = 'Renal function test',
    Assigned_Role__c = 'Primary Physician',
    Task_Frequency__c = 'Annually',
    Priority = 'Medium'
));

// -- Cardiac Tasks (6) --
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = cardiacTemplate.Id,
    Subject = 'Lipid panel order',
    Assigned_Role__c = 'Primary Physician',
    Task_Frequency__c = 'Quarterly',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = cardiacTemplate.Id,
    Subject = 'Cardiac medication review',
    Assigned_Role__c = 'Primary Physician',
    Task_Frequency__c = 'Quarterly',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = cardiacTemplate.Id,
    Subject = 'Exercise tolerance test',
    Assigned_Role__c = 'Allied Health',
    Task_Frequency__c = '6-Monthly',
    Priority = 'Medium'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = cardiacTemplate.Id,
    Subject = 'Smoking cessation counselling',
    Assigned_Role__c = 'Care Coordinator',
    Task_Frequency__c = 'Monthly',
    Priority = 'Medium'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = cardiacTemplate.Id,
    Subject = 'Cardiac rehab progress review',
    Assigned_Role__c = 'Specialist',
    Task_Frequency__c = 'Quarterly',
    Priority = 'High'
));
allTasks.add(new CarePlanTemplateTask(
    CarePlanTemplateId = cardiacTemplate.Id,
    Subject = 'Weight and BMI check',
    Assigned_Role__c = 'Nurse',
    Task_Frequency__c = 'Monthly',
    Priority = 'Medium'
));

insert allTasks;

System.debug('Created ' + allTasks.size() + ' Care Plan Template Tasks');
System.debug('  Diabetes tasks: 8');
System.debug('  Hypertension tasks: 5');
System.debug('  Cardiac tasks: 6');

// ============================================================================
// SUMMARY
// ============================================================================

System.debug('============================================');
System.debug('Seed Data Creation Complete');
System.debug('============================================');
System.debug('Templates created: ' + templates.size());
System.debug('Goals created:     ' + allGoals.size());
System.debug('Tasks created:     ' + allTasks.size());
System.debug('============================================');
