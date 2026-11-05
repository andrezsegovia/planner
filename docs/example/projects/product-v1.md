---
type: project
status: active
outcome: v1 is deployed to staging and 10 beta users have created an account
deadline: 2026-12-18
created: 2026-10-01
---
# Product v1

## Milestones
- [x] M1 — Signup and login work on staging #milestone due:2026-11-04
- [ ] M2 — Create, save, and reopen a document #milestone due:2026-11-20
- [ ] M3 — Invite 10 beta users and collect feedback #milestone due:2026-12-11
- [ ] M4 — Public beta #milestone due:2026-12-18

## Current milestone
M2 — create, save and reopen a document

### Next action
- [ ] Save the document body to Postgres through the auth session #product due:2026-11-06

### Tasks
- [ ] Write the integration test that saves and reopens #product due:2026-11-06
- [ ] Load a saved document on open #product due:2026-11-10
- [ ] Wait for staging domain approval #product @waiting

## Later
- Password reset
- Billing
- Mobile layout

## Log
- 2026-11-02 chose session cookies over JWT
- 2026-11-04 login route works end to end on staging
- 2026-11-05 save endpoint stores a document; reload still reads stale data
