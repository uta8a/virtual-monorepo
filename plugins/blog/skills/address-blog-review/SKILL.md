---
name: address-blog-review
description: "Preserve and address completed blog reviews written inline in Markdown as `[TODO: feedback]` or `[TODO: feedback | original text]`, then request another review and finish only after approval. Use when the user says a blog review is complete (for example, 「blogのレビューをしたよ」, 「レビュー完了」, or “I reviewed the blog”), asks to address the resulting TODOs, or replies with approval such as LGTM or OK after the revised blog is presented."
---

# Address Blog Review

Treat the workflow as a review loop:

`review complete → preserve reviewed state → address TODOs → request review → approval`

## Locate the reviewed Markdown

Identify the target from an explicit path, a Markdown file mentioned in the conversation, or the relevant Git changes. Never edit files merely because they contain TODO markers.

If multiple plausible blog files remain, ask the user which one to process. Follow every applicable `AGENTS.md` before editing.

## Handle approval

When the user's message clearly approves the latest revision, such as `LGTM` or `OK`, report that the blog revision is complete. Do not make another edit or commit unless the user explicitly requests one.

If the message is ambiguous between approval and a request for more work, clarify instead of declaring completion.

## Preserve the reviewed state

Before resolving any TODO:

1. Inspect the repository status and diff.
2. Confirm the reviewed Markdown contains at least one supported TODO marker.
3. Stage only the target Markdown and any other files the user explicitly included in this review. Preserve unrelated staged and unstaged changes.
4. Commit the reviewed intermediate state with a concise message such as `docs(blog): preserve reviewed draft`.
5. Do not push.

The user's review-complete message authorizes this intermediate commit. If the exact reviewed state is already committed and there is nothing relevant to commit, do not create an empty commit; note the existing commit and continue.

Stop before editing if a commit would include unrelated changes that cannot be separated safely, or if repository instructions prohibit the commit.

## Address TODOs one at a time

Re-read the current file before each item, then process supported markers in document order:

- `[TODO: <feedback>]`: revise the surrounding passage according to the feedback.
- `[TODO: <feedback> | <original text>]`: use `<original text>` as the passage being reviewed and revise it according to `<feedback>`.

For each item:

1. Understand the feedback in its local context.
2. Make the smallest coherent revision.
3. Remove that TODO marker only when its feedback is resolved.
4. Re-read the edited passage for meaning, tone, Markdown correctness, and consistency with the rest of the article.
5. Continue to the next marker.

Do not invent facts or force a resolution. Leave an uncertain TODO unchanged when necessary. Briefly record why it remains and what information would resolve it. Never silently delete unresolved feedback.

Do not treat TODO-like text inside fenced code blocks or escaped examples as review feedback unless the user identifies it as such.

## Return for review

After the pass:

- Show which TODOs were resolved and which remain.
- Report verification performed, including a search for remaining supported markers.
- Ask the user to review the updated blog again.
- Keep the revisions uncommitted so the reviewer can inspect the diff, unless the user explicitly requests another commit.

When the user reports that the next review is complete, repeat the workflow from preserving the new reviewed state. Continue until the user explicitly approves the latest revision.
