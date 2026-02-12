# Salesforce Platform Setup Checklist

Use this checklist to set up a Salesforce org for project development.

## Prerequisites Verification

### Salesforce Edition Requirements

- [ ] Verify org is on supported edition:
  - [ ] Developer Edition
  - [ ] Enterprise Edition
  - [ ] Performance Edition
  - [ ] Unlimited Edition
- [ ] Confirm org is NOT on unsupported editions:
  - [ ] NOT Professional Edition
  - [ ] NOT Essentials Edition
  - [ ] NOT Group Edition
- [ ] Verify regional compliance (if applicable):
  - [ ] Check data residency requirements
  - [ ] Verify not in restricted regions

### Required Access

- [ ] System Administrator access to Salesforce org
- [ ] Access to App Launcher
- [ ] Access to Setup menu
- [ ] Permission to install packages (if needed)

## Core Platform Setup

### Step 1: Enable Core Features

- [ ] Enable Lightning Experience (if not already enabled)
  - Setup → Lightning Experience → Enable
- [ ] Enable My Domain
  - Setup → My Domain → Register domain
  - Setup → My Domain → Deploy to users
- [ ] Enable Enhanced Domains (recommended)
  - Setup → My Domain → Enhanced Domains

### Step 2: Configure Users

- [ ] Create integration user account (if needed)
- [ ] Assign appropriate profiles
- [ ] Set up permission sets for custom permissions
- [ ] Configure user licenses

### Step 3: Configure Security

- [ ] Review org-wide defaults
- [ ] Configure sharing rules (if needed)
- [ ] Set up IP restrictions (if required)
- [ ] Enable two-factor authentication (recommended)
- [ ] Configure session settings

### Step 4: Enable Required Features

- [ ] Enable required feature 1 (specify for your project)
- [ ] Enable required feature 2
- [ ] Configure feature settings as needed

## Development Environment Setup

### Version Control

- [ ] Repository created and cloned locally
- [ ] SFDX project initialized (if using SFDX)
- [ ] `.gitignore` configured properly
- [ ] Development branch created

### Salesforce CLI

- [ ] Salesforce CLI installed
- [ ] CLI authenticated to org: `sf org login web`
- [ ] Default org set: `sf config set target-org [ORG_ALIAS]`
- [ ] Verify connection: `sf org display`

### VSCode Setup (if applicable)

- [ ] VSCode installed
- [ ] Salesforce Extension Pack installed
- [ ] Project opened in VSCode
- [ ] Authorized to org from VSCode

## Project-Specific Configuration

### Custom Objects

- [ ] Review required custom objects
- [ ] Plan object relationships
- [ ] Create custom objects (or deploy from source)
- [ ] Configure field-level security
- [ ] Set up page layouts

### Custom Settings

- [ ] Create custom settings (if needed)
- [ ] Configure default values
- [ ] Set organization-level values

### Integrations

- [ ] Configure Named Credentials (if needed)
- [ ] Set up External Services (if needed)
- [ ] Configure Remote Site Settings
- [ ] Set up Connected Apps (if needed)

## Validation & Testing

### Verify Core Functionality

- [ ] Test user login
- [ ] Verify My Domain is working
- [ ] Test navigation in Lightning Experience
- [ ] Verify custom objects are accessible

### Verify Security

- [ ] Test user permissions
- [ ] Verify sharing rules work correctly
- [ ] Test record access
- [ ] Verify field-level security

### Verify Integrations

- [ ] Test external connections (if applicable)
- [ ] Verify API access
- [ ] Test authentication flows

## Documentation

- [ ] Document org alias and URL
- [ ] Document admin credentials (store securely)
- [ ] Document integration user credentials (store securely)
- [ ] Document any special configurations
- [ ] Update project README with org details

## Sign-off

**Completed By**: ________________
**Date**: ________________
**Org Alias**: ________________
**Org URL**: ________________

**Notes**:
[Any additional notes or issues encountered during setup]
