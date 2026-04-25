# Architecture Decision Record

| Field  | Value                           |
|--------|---------------------------------|
| ADR    | {{adr_number, e.g., ADR-001}}   |
| Title  | {{decision_title}}              |
| Date   | {{date}}                        |
| Status | Proposed / Accepted / Deprecated / Superseded by ADR-{{N}} |

---

## Context

{{Describe the situation that requires a decision. Include:

- What is the technical or architectural issue we are facing?
- What constraints exist (timeline, budget, team expertise, existing systems)?
- What triggered this decision (new requirement, scaling issue, tech debt, incident)?
- What are the forces at play (competing priorities, trade-offs)?

Be specific and factual. Reference relevant PRDs, system design docs, or incidents.}}

---

## Decision

{{State the decision clearly and concisely in 1-3 sentences.

Example: "We will use PostgreSQL as the primary database for the user service, with Redis as a caching layer for session data."

Then elaborate on the key aspects of the decision:
- How will this be implemented?
- What is the migration/adoption plan?
- What is the timeline for implementation?}}

---

## Options Considered

| Option | Description | Pros | Cons | Effort Estimate |
|--------|-------------|------|------|-----------------|
| **{{Option A — chosen}}** | {{brief description}} | {{advantages}} | {{disadvantages}} | {{t-shirt size: S/M/L/XL}} |
| {{Option B}} | {{brief description}} | {{advantages}} | {{disadvantages}} | {{t-shirt size}} |
| {{Option C}} | {{brief description}} | {{advantages}} | {{disadvantages}} | {{t-shirt size}} |
| {{Do nothing}} | {{maintain status quo}} | {{advantages}} | {{disadvantages}} | {{none}} |

### Evaluation Criteria

The options were evaluated against:

1. **{{criterion_1, e.g., Performance}}** — {{weight: high/medium/low}} — {{why this matters}}
2. **{{criterion_2, e.g., Developer Experience}}** — {{weight}} — {{why this matters}}
3. **{{criterion_3, e.g., Operational Complexity}}** — {{weight}} — {{why this matters}}
4. **{{criterion_4, e.g., Cost}}** — {{weight}} — {{why this matters}}
5. **{{criterion_5, e.g., Future Flexibility}}** — {{weight}} — {{why this matters}}

---

## Consequences

### Positive

- {{positive_consequence_1}}
- {{positive_consequence_2}}
- {{positive_consequence_3}}

### Negative

- {{negative_consequence_1 — and how we will mitigate it}}
- {{negative_consequence_2 — and how we will mitigate it}}

### Neutral

- {{neutral_consequence — e.g., team needs to learn new technology}}
- {{neutral_consequence — e.g., requires migration of existing data}}

---

## Compliance

### Security Impact
- {{Does this decision affect the attack surface? How?}}
- {{Are there new authentication/authorization requirements?}}
- {{Does this introduce new data flows that need encryption?}}

### Legal / Regulatory Impact
- {{GDPR implications (data residency, right to deletion)}}
- {{SOC 2 / HIPAA / PCI-DSS implications}}
- {{License implications of chosen technologies}}

### Data Privacy Impact
- {{Does this change how PII is stored or processed?}}
- {{Are there new third-party data processors involved?}}
- {{Data retention changes?}}

---

## References

- {{Link to PRD or feature request}}
- {{Link to system design document}}
- {{Link to relevant research, benchmarks, or RFCs}}
- {{Link to related ADRs (e.g., "Supersedes ADR-003")}}
- {{Link to proof-of-concept or spike results}}

---

## Changelog

| Date | Author | Change |
|------|--------|--------|
| {{date}} | {{author}} | Initial proposal |
| {{date}} | {{author}} | {{update description}} |
