# Agent Instructions

<!--
  This file is the cross-tool instruction file. Cursor, Codex, and other coding
  agents read AGENTS.md; Claude Code reads it too, directly, from v2.1.277.

  How Claude Code resolves the two files:

  - AGENTS.md and no CLAUDE.md anywhere above the working directory: Claude reads
    AGENTS.md.
  - Both present: Claude reads the CLAUDE.md files only, and ignores AGENTS.md.
  - A CLAUDE.md containing `@AGENTS.md`: Claude reads CLAUDE.md with AGENTS.md
    pulled in through the import.

  This repository ships `.claude/CLAUDE.md`, so by default Claude reads that and
  not this file. Pick one of these:

  1. ONE FILE FOR EVERY TOOL. Put your instructions here and make CLAUDE.md a
     one-line import. Use this on versions before v2.1.277, and in sessions that
     cannot read AGENTS.md directly: a third-party provider such as Amazon
     Bedrock, telemetry disabled, or hooks disabled. It is also the portable
     alternative to symlinking CLAUDE.md to AGENTS.md, since creating a symlink
     on Windows needs Administrator rights or Developer Mode:

         @AGENTS.md

  2. CLAUDE.md ONLY. Delete this file. Nothing else to do.

  3. BOTH, READ TOGETHER. Set Project instructions to `claude-md-and-agents-md`
     in /config. Each directory's CLAUDE.md is read first, then its AGENTS.md.

  Note that `.claude/rules/` and your `~/.claude/CLAUDE.md` keep loading either
  way. They do not affect which of the two files above Claude reads.
-->

Replace this file's contents with your project instructions, or delete it.

See `.claude/CLAUDE.md` for the template and the guidance on what belongs in it.
