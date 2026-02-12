# Deployment Checklist Template

Use this checklist to verify readiness before and after deployment.

## Pre-Deployment Checklist

### Code Quality

- [ ] All code changes reviewed and approved
- [ ] Code review feedback addressed
- [ ] No merge conflicts in deployment branch
- [ ] Code follows project standards and conventions
- [ ] No commented-out code or debug statements

### Testing

- [ ] All unit tests passing (target: 85%+ coverage)
- [ ] Integration tests passing
- [ ] Manual testing completed in sandbox
- [ ] QA sign-off received
- [ ] Performance testing completed (if applicable)
- [ ] No critical or high-priority bugs open

### Documentation

- [ ] DEPLOYMENT.md updated with deployment notes
- [ ] README.md updated (if needed)
- [ ] API documentation updated (if applicable)
- [ ] User documentation updated (if applicable)
- [ ] ClickUp ticket updated with deployment plan

### Dependencies

- [ ] All external dependencies documented
- [ ] Required packages installed in target org
- [ ] Integration endpoints accessible from target org
- [ ] Required credentials configured in target org

### Backup & Rollback

- [ ] Backup of current production state completed
- [ ] Rollback plan documented
- [ ] Rollback tested in sandbox (if applicable)
- [ ] Emergency contact list updated

### Communication

- [ ] Stakeholders notified of deployment time
- [ ] Users notified of expected downtime (if any)
- [ ] Support team briefed on changes
- [ ] Deployment window confirmed with team

### Environment Verification

- [ ] Target org identified correctly
- [ ] CLI authenticated to correct org
- [ ] Deployment user has required permissions
- [ ] Deployment timing confirmed (off-peak hours)

## Deployment Execution

### Pre-Deployment Steps

- [ ] Start deployment window
- [ ] Create backup checkpoint
- [ ] Notify stakeholders deployment is starting
- [ ] Verify no other deployments in progress

### Deployment Steps

- [ ] Run deployment command
- [ ] Monitor deployment progress
- [ ] Check deployment logs for errors
- [ ] Verify deployment completed successfully
- [ ] Note deployment ID: ________________

### Post-Deployment Validation

- [ ] Run smoke tests
- [ ] Verify critical functionality works
- [ ] Check application logs for errors
- [ ] Test key user workflows
- [ ] Verify integrations still working
- [ ] Check data integrity

## Post-Deployment Checklist

### Validation

- [ ] All deployed components are active
- [ ] No errors in deployment logs
- [ ] System health checks passing
- [ ] Monitoring alerts reviewed (no critical alerts)
- [ ] Performance metrics within acceptable range

### User Verification

- [ ] Key users can log in
- [ ] Core functionality accessible
- [ ] No user-reported critical issues
- [ ] Support team has received no critical escalations

### Documentation

- [ ] Deployment completion logged in ClickUp
- [ ] Deployment ID recorded
- [ ] Any issues encountered documented
- [ ] Lessons learned captured
- [ ] DEPLOYMENT.md updated with actual deployment notes

### Communication

- [ ] Stakeholders notified of successful deployment
- [ ] Users notified system is available
- [ ] Support team notified to monitor for issues
- [ ] Deployment window closed

### Monitoring

- [ ] Set up monitoring for new features
- [ ] Configure alerts for new components
- [ ] Monitor error logs for 24-48 hours
- [ ] Track key performance metrics

## Rollback (If Needed)

### Rollback Triggers

Critical issues that require rollback:
- [ ] System unavailable
- [ ] Data corruption detected
- [ ] Critical security vulnerability
- [ ] Major functionality broken
- [ ] Integration failures causing business impact

### Rollback Steps

- [ ] Execute rollback plan from backup
- [ ] Verify rollback completed
- [ ] Test system functionality
- [ ] Notify stakeholders of rollback
- [ ] Document rollback reason
- [ ] Create ticket for issue investigation

## Sign-off

### Deployment Team

**Deployed By**: ________________
**Date**: ________________
**Time**: ________________
**Deployment ID**: ________________

**Status**: ✅ Success / ❌ Rolled Back

### Approval

**QA Sign-off**: ________________ **Date**: ________
**Tech Lead Sign-off**: ________________ **Date**: ________
**Product Owner Sign-off**: ________________ **Date**: ________

**Notes**:
[Any additional notes about the deployment]

---

## Deployment Metrics

- **Deployment Duration**: ______ minutes
- **Downtime**: ______ minutes (if any)
- **Components Deployed**: ______
- **Tests Run**: ______
- **Issues Found**: ______
- **Issues Resolved**: ______
