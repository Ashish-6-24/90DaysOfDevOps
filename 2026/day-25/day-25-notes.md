# 📘 Day 25 Git Reset vs Revert & Branching Strategies

Today I practiced how to undo Git changes and learned three common branching strategies.

---

## 🔄 1. Git Reset

`git reset` moves the current branch back to another commit.

| Command | Result |
|---|---|
| `git reset --soft HEAD~1` | Commit removed, changes stay **staged** |
| `git reset --mixed HEAD~1` | Commit removed, changes stay **unstaged** |
| `git reset --hard HEAD~1` | Commit and local changes are **discarded** |

```text
A → B → C

--soft  → B + C changes staged
--mixed → B + C changes unstaged
--hard  → B + C changes discarded
```

⚠️ `--hard` is destructive because local changes can be lost.

### When to use

- `--soft` → redo the commit
- `--mixed` → redo/review the changes
- `--hard` → throw away unwanted local changes

🚫 Avoid resetting commits already pushed to a shared branch because it rewrites history.

🛟 Useful recovery command:

```bash
git reflog
```

---

## ↩️ 2. Git Revert

`git revert` creates a **new commit** that reverses an older commit.

```text
X → Y → Z

Revert Y

X → Y → Z → Revert Y
```

✅ `Y` is still in `git log`.

I also got a conflict while reverting a middle commit. After fixing the file:

```bash
git add notes.txt
git revert --continue
```

To cancel:

```bash
git revert --abort
```

### Reset vs Revert

| | `git reset` | `git revert` |
|---|---|---|
| History | Rewrites/moves it | Keeps it |
| Old commit | Removed from current branch history | Still visible |
| Shared branch | ⚠️ Avoid | ✅ Safer |
| Best for | Local mistakes | Shared/pushed changes |

---

# 🌿 3. Branching Strategies

## 1. GitFlow

```text
feature → develop → release → main
                         ↑
                    hotfix → main
```

Uses `main`, `develop`, `feature`, `release`, and `hotfix`.

**Best for:** versioned software, multiple supported versions, scheduled releases.

✅ Clear release process  
❌ More branches and merge overhead

---

## 2. GitHub Flow

```text
main → feature → PR → review/tests → main
```

**Best for:** web apps, SaaS, frequent releases.

✅ Simple and fast  
❌ Less suitable for managing many old versions

---

## 3. Trunk-Based Development

```text
short branch ──→
main ─────────────────→
```

Developers integrate into `main` frequently. Branches are very short-lived.

Usually needs:

```text
CI/CD + automated tests + feature flags
```

**Best for:** fast delivery and mature DevOps teams.

✅ Fast feedback, less branch drift  
❌ Needs strong automation and discipline

---

# 🎯 4. My Choices

### 🚀 Startup shipping fast
**GitHub Flow** simple, low overhead, fast releases.

### 🏢 Large team with scheduled releases
**GitFlow** structured release and version management.

### ☸️ Open-source example
**Kubernetes** main-based PR workflow with release-specific branches/processes; a practical hybrid approach.

---

# 🧠 Final Takeaway

```text
Local mistake      → reset
Shared/pushed work → revert

Versioned releases → GitFlow
Simple PR workflow → GitHub Flow
Fast CI/CD         → Trunk-Based
```

There is no single best workflow. Pick the one that fits the product, release model, team, and CI/CD maturity.

---

## ✅ Day 25 Checklist

- [x] Reset: soft / mixed / hard
- [x] Revert + conflict handling
- [x] Reset vs Revert comparison
- [x] GitFlow
- [x] GitHub Flow
- [x] Trunk-Based Development
- [x] Strategy selection
- [x] `git reflog`
- [x] `git-commands.md` topics reviewed
