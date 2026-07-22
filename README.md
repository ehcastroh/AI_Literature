# AI Literature Wiki

A living knowledge base for AI/ML research papers, built on the [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

Instead of re-reading papers every time a question comes up, this wiki compiles knowledge once and keeps it current - cross-referencing concepts, tracking contradictions, and surfacing open questions across the literature.

---

## Structure

```
raw/      - Immutable source PDFs (ArXiv papers). Never modified.
wiki/     - LLM-generated and LLM-maintained synthesis.
  index.md    - Master catalog linking every paper to its summary.
  overview.md - Big-picture themes, recurring architectures, open questions.
  glossary.md - Definitions for terms and concepts across the literature.
  log.md      - Append-only record of every ingest and update.
  papers/     - Per-paper summary pages.
```

---

## Workflow

**Add a paper** - Drop a PDF into `raw/`. The filename is the ArXiv ID.

**Ingest** - Process new papers: extract key contributions, update `index.md`, create or update pages in `wiki/papers/`, integrate findings into `overview.md` and `glossary.md`, log the activity in `log.md`.

**Query** - Ask questions against the wiki. Non-trivial answers become new wiki pages.

**Lint** - Periodically check for stale claims, orphaned pages, missing cross-references, and gaps.

---

## Philosophy

Raw sources are ground truth. The wiki is the compiled understanding. The LLM does the bookkeeping - humans decide what to read and what to ask.
