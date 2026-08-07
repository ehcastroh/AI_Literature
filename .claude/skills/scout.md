---
name: scout
description: Find new ArXiv papers via author lineage from the existing corpus. Use when asked to find new papers, discover follow-up work, identify what to read next, or look for papers ahead in time relative to what is already ingested. Distinct from /discover, which mines the internal corpus for gaps — scout goes external.
---

# Scouting New Papers via Author Lineage

This skill does three things in order: synthesizes forward research directions from the existing corpus, searches ArXiv for papers by the corpus's own authors published after the last ingestion date, and presents the top two candidates ranked by author tier and recency.

**This skill does not ingest.** Identification and ingestion are separate operations. Ingestion requires fresh context per paper.

---

## Phase 0 — Identify Forward Research Directions

Read `wiki/index.md` to get the full paper list. Then read the `## Not Stated in Source` and `## Failure Mode / Boundary Conditions` sections across 5-7 notes most central to the corpus's four clusters (retrieval-and-context, prompt-optimization, inference-efficiency, agents-and-memory).

Synthesize **2-3 forward directions** — not gaps in what was written, but where the work naturally points next. Write these down explicitly before continuing. They become the relevance filter in Phase 4.

Examples of the right shape:
- "Adaptive routing that trains intrinsic routing signals rather than using external classifiers"
- "Agent memory architectures that degrade gracefully when the memory store contains irrelevant content"
- "Prompt compression techniques that preserve causal rather than just semantic structure"

Keep them tight. Vague directions produce vague relevance judgments.

---

## Phase 1 — Extract the Author Graph

Parse the author line from each `wiki/wiki/` note. The author line appears immediately after the `#` title heading — it lists full names, institution, venue, and year.

Extract structured author data per paper:

```bash
grep -h "^[A-Z][a-z].*\. arXiv" wiki/wiki/*.md | head -30
```

For each paper, assign:
- **Tier 1**: first-listed author AND last-listed author
- **Tier 2**: all middle authors (everyone between first and last)

Build two deduplicated sets. If an author appears in both, assign Tier 1.

**Cap at 12 unique authors total.** If the corpus has more, prioritize authors who appear in multiple papers — they are more central to the lineage.

---

## Phase 2 — Determine the Cutoff Date

Derive the cutoff from the newest arxiv ID already in the corpus:

```bash
ls raw/papers/ | grep -oE '^[0-9]{4}\.[0-9]+' | sort -t. -k1,1 -k2,2 -n | tail -1
```

The prefix encodes `YYMM`:
- `2604.xxxxx` → April 2026 → cutoff `2026-04-01`
- `2507.xxxxx` → July 2025 → cutoff `2025-07-01`

Search only for papers submitted **strictly after** this date. Papers on or before the cutoff may already be in the corpus.

---

## Phase 3 — Search ArXiv by Author

Use the ArXiv Atom API. Query Tier 1 authors first. Only move to Tier 2 if Tier 1 produces fewer than 4 candidates after the cutoff.

**Query format:**

```
https://export.arxiv.org/api/query?search_query=au:"[First Last]"&sortBy=submittedDate&sortOrder=descending&start=0&max_results=15
```

Use WebFetch for each author query. The response is Atom XML. For each `<entry>` block, extract:
- `<id>` — the arxiv URL; strip to get the ID (e.g., `2601.12345`)
- `<title>` — paper title
- `<published>` — ISO 8601 date
- `<author><name>` — full author list
- `<summary>` — abstract

Keep only entries where `<published>` is after the cutoff date.

Record which Tier the matching author belongs to and which author triggered the match.

**Do not query more than 10 authors.** Stop querying Tier 2 once you have 6+ post-cutoff candidates total.

---

## Phase 4 — Filter for Topical Relevance

Discard papers where the abstract has no overlap with the forward directions from Phase 0 or the core corpus vocabulary.

Core vocabulary signal words (any 2+ in the abstract = pass):
`prompt`, `LLM`, `language model`, `agent`, `memory`, `retrieval`, `routing`, `context`, `inference`, `reasoning`, `token`, `embedding`, `fine-tun`, `alignment`, `RAG`

Papers that match a Phase 0 forward direction receive a **direction-match flag** — this is noted in the presentation but does not change the rank order (Tier and recency determine rank; direction-match is display metadata).

Discard papers that pass none of the signal words — the author has moved to a different subfield and the lineage is not productive here.

Also check whether the arxiv ID is already in `raw/papers/`:

```bash
ls raw/papers/ | grep "[ID]"
```

Discard any paper already in the corpus.

---

## Phase 5 — Rank and Select Top 2

Sort surviving candidates:
1. **Primary**: Tier 1 matches before Tier 2 matches
2. **Secondary**: most recent `<published>` date first within each tier

If a paper's author list includes both Tier 1 and Tier 2 corpus authors, it counts as Tier 1.

Select the top 2 from the sorted list.

---

## Phase 6 — Present Candidates

Display both candidates clearly:

```
CANDIDATE 1
Title: [title]
Authors: [full author list]
Published: [date]  |  ArXiv: [ID]
Matched via: Tier [1/2] — [matched author name]
Direction match: [Yes — "[direction text]" / No]
Abstract: [first 2-3 sentences of <summary>]

CANDIDATE 2
[same format]
```

Then state the research directions identified in Phase 0 so the user can see the reasoning:

```
Forward directions identified from corpus:
1. [direction 1]
2. [direction 2]
[3. direction 3 if present]
```

---

## Phase 7 — Default Execution

**Default behavior:** ingest both candidates and then offer a glossary update. Do not prompt the user to choose — proceed automatically unless told otherwise.

Download both PDFs immediately:
```bash
curl -L "https://arxiv.org/pdf/[ARXIV-ID-1]" -o "raw/papers/[ARXIV-ID-1].pdf"
curl -L "https://arxiv.org/pdf/[ARXIV-ID-2]" -o "raw/papers/[ARXIV-ID-2].pdf"
```

Verify both downloaded correctly (non-empty, starts with `%PDF-`).

**Ingest Candidate 1** by loading and following the `/ingest` skill. One paper per session — ingest Candidate 1 fully, including logging and lint. Do not start Candidate 2 in the same session.

After Candidate 1 is complete, report:

> Candidate 1 ingested: [title]. Candidate 2 ([title], ArXiv: [ID]) is downloaded and queued — start a new session to ingest it (error rates rise mid-run; N4 is a quality guarantee, not a preference).
>
> Would you like to update the glossary before closing this session?

If the user says yes, run `/update-glossary` on the newly ingested paper before ending the session.

**If the user explicitly says they only want one paper or skips ingest entirely**, respect that and ask what they would like instead.

---

## Anti-patterns

| Doing this | Why it fails |
|---|---|
| Searching ArXiv by topic keywords instead of author names | Returns papers outside the lineage; you get the field, not the thread |
| Ingesting both candidates in the same session | Error rate rises; Candidate 2 gets a degraded note. State the ID and stop. |
| Skipping Phase 0 synthesis | Relevance filter in Phase 4 becomes arbitrary; direction-match metadata is meaningless |
| Querying more than 10 authors | API rate limits and diminishing returns; the 10 most central authors dominate the lineage |
| Not checking if the arxiv ID already exists in raw/papers/ | Re-ingesting a paper you already have wastes a session |
| Proceeding past Phase 6 without user confirmation | Ingest costs context; the user must choose |
| Downloading to a path other than raw/papers/ | Breaks the ingest skill's file expectations and the lint check |

---

## Done when

The user has taken both options (in either order), or has explicitly declined one or both. Presenting the candidates is not done — the session closes only when the user has acted or passed on each option.
