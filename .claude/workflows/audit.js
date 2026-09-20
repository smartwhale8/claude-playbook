/**
 * /audit [what to look for]
 *
 * Fans out one reviewer per source file, then has a second, independent agent
 * try to refute each finding before it is reported.
 *
 * The adversarial second pass is the point. A single reviewer asked to find
 * problems will find some, whether or not they are real, because that is what
 * it was asked to do. A separate agent that sees only the claim and the file,
 * and is asked to disprove it, removes most of the noise.
 *
 * Saved workflows live in .claude/workflows/ (shared with the repository) or
 * ~/.claude/workflows/ (yours alone). Run /reload-skills after editing.
 *
 * Rules the runtime enforces on this file:
 *   - `export const meta` must be the first statement and a plain object
 *     literal. A variable or a function call inside it drops /audit from
 *     autocomplete.
 *   - Each `phases` entry must match a phase() title exactly.
 *   - Date.now(), Math.random(), and new Date() throw here, so that a relaunched
 *     run repeats the same agent calls. Pass a timestamp through `args`.
 *   - No import(). Work needing a library belongs inside an agent's task.
 */

export const meta = {
  name: 'audit',
  description: 'Audit every source file for a given class of problem, verifying each finding adversarially',
  phases: [
    { title: 'Discover', detail: 'List the files in scope' },
    { title: 'Audit', detail: 'One reviewer per file' },
    { title: 'Verify', detail: 'An independent agent tries to refute each finding' },
  ],
}

// `args` is whatever you passed at invocation. It arrives as structured data,
// so it needs no parsing. It is undefined when you pass nothing.
const target =
  typeof args === 'string' && args.trim()
    ? args.trim()
    : 'missing authentication or authorization checks'

phase('Discover')

const discovered = await agent(
  `List every source file in this repository that could plausibly contain ${target}.
   Use Glob and Grep. Return at most 40 paths, most likely first. Do not read them in full.`,
  {
    label: 'discover',
    schema: {
      type: 'object',
      required: ['files'],
      properties: { files: { type: 'array', items: { type: 'string' } } },
    },
  },
)

const files = discovered?.files ?? []

if (files.length === 0) {
  return { target, findings: [], note: 'No candidate files found.' }
}

log(`Auditing ${files.length} files for: ${target}`)

// pipeline() runs the first function per item, and feeds each result into the
// second. A file's findings start verifying while later files are still being
// audited, so no wall-clock time is wasted waiting for the slowest reviewer.
const perFile = await pipeline(
  files,

  file => {
    phase('Audit')
    return agent(
      `Read ${file} and report only instances of: ${target}.
       For each one, give the line number, a one-sentence description, and the
       specific fix. Report nothing speculative and nothing about style.
       Return an empty array when the file is clean.`,
      {
        label: `audit:${file}`,
        schema: {
          type: 'object',
          required: ['findings'],
          properties: {
            findings: {
              type: 'array',
              items: {
                type: 'object',
                required: ['line', 'issue', 'fix'],
                properties: {
                  line: { type: 'number' },
                  issue: { type: 'string' },
                  fix: { type: 'string' },
                },
              },
            },
          },
        },
      },
    ).then(result => ({ file, findings: result?.findings ?? [] }))
  },

  ({ file, findings }) => {
    phase('Verify')
    // parallel() runs a set of tasks at once and waits for all of them.
    return parallel(
      findings.map(finding => () =>
        agent(
          `Read ${file} around line ${finding.line}.
           Another reviewer claims: "${finding.issue}"
           Your job is to REFUTE this claim if you can. It is real only if you
           can trace a concrete path by which it causes incorrect or unsafe
           behaviour. A theoretical concern, a style preference, or a case the
           surrounding code already handles is not real.
           Return your verdict and the reasoning behind it.`,
          {
            label: `verify:${file}:${finding.line}`,
            schema: {
              type: 'object',
              required: ['isReal', 'reasoning'],
              properties: {
                isReal: { type: 'boolean' },
                reasoning: { type: 'string' },
              },
            },
          },
        ).then(verdict => ({ ...finding, file, verdict })),
      ),
    )
  },
)

// An agent() call resolves to null when you stop it, when it hits an
// unrecoverable API error, or when auto mode's classifier blocks it. pipeline()
// keeps those nulls, which is why everything here filters them out.
const all = perFile.flat(2).filter(Boolean)
const confirmed = all.filter(f => f.verdict?.isReal)
const refuted = all.filter(f => f.verdict && !f.verdict.isReal)

return {
  target,
  filesAudited: files.length,
  confirmed: confirmed.map(f => ({
    file: f.file,
    line: f.line,
    issue: f.issue,
    fix: f.fix,
    why: f.verdict.reasoning,
  })),
  refutedCount: refuted.length,
}
