# Health Cloud Implementation Guides

> **Document Version:** 1.0 | **Last Updated:** February 2026
> **Reference Documents:** [Implementation Guide](../healthcloud-implementation-guide.md) | [User Stories](../docs/healthcloud-user-stories.md)

---

## How to Use These Guides

Each guide provides a detailed implementation blueprint for a single user story. Guides are organised by phase and should be implemented in order, as later phases build on earlier ones.

**Reading Order:**
1. Start with Phase 1 guides sequentially (Epic 1.1 → 1.6)
2. Complete all Phase 1 before starting Phase 2
3. Within each epic, follow the user story numbering order

**Each Guide Contains:**
- Overview & business value
- Prerequisites & dependencies
- Salesforce configuration steps
- Data model (objects, fields, relationships)
- Automation & flows
- Security & access configuration
- Testing strategy
- Deployment checklist
- Acceptance criteria verification

---

## Phase 1: Foundation / MVP (10-14 Weeks)

### Epic 1.1: Patient 360
| ID | Guide | Estimate |
|---|---|---|
| US-1.1.1 | [Patient Profile Setup](phase-1-mvp/US-1.1.1-patient-profile-setup.md) | M |
| US-1.1.2 | [Patient 360 FlexCard](phase-1-mvp/US-1.1.2-patient-360-flexcard.md) | S |
| US-1.1.3 | [Patient Timeline](phase-1-mvp/US-1.1.3-patient-timeline.md) | S |
| US-1.1.4 | [Patient Search & Duplicate Detection](phase-1-mvp/US-1.1.4-patient-search-duplicate-detection.md) | S |

### Epic 1.2: Basic Care Management
| ID | Guide | Estimate |
|---|---|---|
| US-1.2.1 | [Care Plan Templates](phase-1-mvp/US-1.2.1-care-plan-templates.md) | M |
| US-1.2.2 | [Care Plan Creation & Assignment](phase-1-mvp/US-1.2.2-care-plan-creation-assignment.md) | M |
| US-1.2.3 | [Care Team Assignment](phase-1-mvp/US-1.2.3-care-team-assignment.md) | S |
| US-1.2.4 | [Goal Tracking & Progress](phase-1-mvp/US-1.2.4-goal-tracking-progress.md) | S |
| US-1.2.5 | [Task Management](phase-1-mvp/US-1.2.5-task-management.md) | S |

### Epic 1.3: Provider Management
| ID | Guide | Estimate |
|---|---|---|
| US-1.3.1 | [Provider Directory](phase-1-mvp/US-1.3.1-provider-directory.md) | S |
| US-1.3.2 | [Internal Referral Workflow](phase-1-mvp/US-1.3.2-internal-referral-workflow.md) | M |

### Epic 1.4: Reports & Dashboards
| ID | Guide | Estimate |
|---|---|---|
| US-1.4.1 | [Clinical Operations Dashboard](phase-1-mvp/US-1.4.1-clinical-operations-dashboard.md) | S |
| US-1.4.2 | [Patient Care Reports](phase-1-mvp/US-1.4.2-patient-care-reports.md) | S |

### Epic 1.5: Data Migration
| ID | Guide | Estimate |
|---|---|---|
| US-1.5.1 | [Patient Data Migration](phase-1-mvp/US-1.5.1-patient-data-migration.md) | L |
| US-1.5.2 | [Provider Data Migration](phase-1-mvp/US-1.5.2-provider-data-migration.md) | S |

### Epic 1.6: PDPA Consent & Security
| ID | Guide | Estimate |
|---|---|---|
| US-1.6.1 | [Digital Consent Capture](phase-1-mvp/US-1.6.1-digital-consent-capture.md) | M |
| US-1.6.2 | [Role-Based Access Controls](phase-1-mvp/US-1.6.2-role-based-access-controls.md) | M |

---

## Phase 2: Care Coordination Platform (16-22 Weeks)

### Epic 2.1: Advanced Care Plans
| ID | Guide | Estimate |
|---|---|---|
| US-2.1.1 | [Clinical Protocol Pathways](phase-2-care-coordination/US-2.1.1-clinical-protocol-pathways.md) | L |
| US-2.1.2 | [Care Plan Escalation Rules](phase-2-care-coordination/US-2.1.2-care-plan-escalation-rules.md) | M |

### Epic 2.2: EHR Integration (FHIR R4)
| ID | Guide | Estimate |
|---|---|---|
| US-2.2.1 | [FHIR R4 Patient Sync](phase-2-care-coordination/US-2.2.1-fhir-r4-patient-sync.md) | L |
| US-2.2.2 | [Lab Results Integration](phase-2-care-coordination/US-2.2.2-lab-results-integration.md) | L |
| US-2.2.3 | [Clinical Orders Integration](phase-2-care-coordination/US-2.2.3-clinical-orders-integration.md) | L |

### Epic 2.3: Patient Engagement
| ID | Guide | Estimate |
|---|---|---|
| US-2.3.1 | [Appointment Reminders (SMS)](phase-2-care-coordination/US-2.3.1-appointment-reminders-sms.md) | M |
| US-2.3.2 | [WhatsApp Medication Reminders](phase-2-care-coordination/US-2.3.2-whatsapp-medication-reminders.md) | M |
| US-2.3.3 | [Patient Portal - Home Readings](phase-2-care-coordination/US-2.3.3-patient-portal-home-readings.md) | M |
| US-2.3.4 | [Health Education Content Delivery](phase-2-care-coordination/US-2.3.4-health-education-content-delivery.md) | S |

### Epic 2.4: SDOH & Population Health
| ID | Guide | Estimate |
|---|---|---|
| US-2.4.1 | [Social Determinants of Health Tracking](phase-2-care-coordination/US-2.4.1-sdoh-tracking.md) | S |
| US-2.4.2 | [Population Health Dashboard](phase-2-care-coordination/US-2.4.2-population-health-dashboard.md) | M |

### Epic 2.5: Cross-Facility Coordination
| ID | Guide | Estimate |
|---|---|---|
| US-2.5.1 | [Cross-Facility Referral Workflow](phase-2-care-coordination/US-2.5.1-cross-facility-referral-workflow.md) | M |
| US-2.5.2 | [Shared Care Plan Visibility](phase-2-care-coordination/US-2.5.2-shared-care-plan-visibility.md) | S |

---

## Phase 3: Enterprise Digital Transformation (28-40 Weeks)

### Epic 3.1: Utilisation Management
| ID | Guide | Estimate |
|---|---|---|
| US-3.1.1 | [Prior Authorisation Workflow](phase-3-enterprise/US-3.1.1-prior-authorisation-workflow.md) | L |
| US-3.1.2 | [Concurrent Review](phase-3-enterprise/US-3.1.2-concurrent-review.md) | M |

### Epic 3.2: Multi-Channel Patient Engagement
| ID | Guide | Estimate |
|---|---|---|
| US-3.2.1 | [Patient Mobile App Integration](phase-3-enterprise/US-3.2.1-patient-mobile-app.md) | L |
| US-3.2.2 | [Chatbot for Patient Triage](phase-3-enterprise/US-3.2.2-chatbot-patient-triage.md) | L |
| US-3.2.3 | [No-Show Prediction & Prevention](phase-3-enterprise/US-3.2.3-no-show-prediction.md) | M |

### Epic 3.3: Agentforce AI
| ID | Guide | Estimate |
|---|---|---|
| US-3.3.1 | [AI-Powered Patient Scheduling Agent](phase-3-enterprise/US-3.3.1-ai-scheduling-agent.md) | M |
| US-3.3.2 | [AI Care Summary Generation](phase-3-enterprise/US-3.3.2-ai-care-summary.md) | M |

### Epic 3.4: Data Cloud & Advanced Analytics
| ID | Guide | Estimate |
|---|---|---|
| US-3.4.1 | [Unified Patient Profile (Data Cloud)](phase-3-enterprise/US-3.4.1-unified-patient-profile-data-cloud.md) | L |
| US-3.4.2 | [AI Risk Stratification](phase-3-enterprise/US-3.4.2-ai-risk-stratification.md) | L |
| US-3.4.3 | [Predictive Readmission Model](phase-3-enterprise/US-3.4.3-predictive-readmission-model.md) | L |

### Epic 3.5: Advanced Integrations
| ID | Guide | Estimate |
|---|---|---|
| US-3.5.1 | [Billing System Integration (SAP)](phase-3-enterprise/US-3.5.1-billing-integration-sap.md) | L |
| US-3.5.2 | [Wearable Device Data Integration](phase-3-enterprise/US-3.5.2-wearable-device-integration.md) | M |

### Epic 3.6: NEHR & Regulatory Compliance
| ID | Guide | Estimate |
|---|---|---|
| US-3.6.1 | [NEHR Data Submission](phase-3-enterprise/US-3.6.1-nehr-data-submission.md) | L |
| US-3.6.2 | [Breach Detection & Response Workflow](phase-3-enterprise/US-3.6.2-breach-detection-response.md) | M |

---

## T-Shirt Size Legend

| Size | Effort | Duration |
|---|---|---|
| **XS** | < 1 day | Quick config change |
| **S** | 1-3 days | Standard feature |
| **M** | 1-2 weeks | Multi-component feature |
| **L** | 2+ weeks | Complex integration (consider splitting) |

---

> **Total:** 17 epics | 44 user stories | 3 progressive phases
