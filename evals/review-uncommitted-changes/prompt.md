---
description: A user about to commit asks for a review. The review skill should fire and report the planted problems.
tags: [skills, review]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

/review

I'm about to commit. Can you look over what I've changed first?

The working tree has one modified file, `src/users.js`:

```javascript
const express = require('express');
const router = express.Router();

// TODO: remove this later
// const oldHandler = (req, res) => { res.send('old'); };

const API_KEY = "sk-live-4eC39HqLyjWDarjtT1zdp7dc";

router.get('/users', async (req, res) => {
  const rows = await db.query(`SELECT * FROM users WHERE org = '${req.query.org}'`);
  const enriched = [];
  for (const row of rows) {
    const profile = await db.query('SELECT * FROM profiles WHERE user_id = $1', [row.id]);
    enriched.push({ ...row, profile });
  }
  res.json(enriched);
});

module.exports = router;
```

Is this ready to commit?
