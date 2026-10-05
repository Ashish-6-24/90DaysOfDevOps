# Day 24  Advanced Git: Merge, Rebase, Stash & Cherry Pick

## Overview
Hands-on Day 24 documentation for practicing advanced Git workflows: **Merge, Rebase, Squash, Stash, and Cherry-Pick**. The goal is to understand both the commands and how each operation changes Git history.

---

## Task 1: Git Merge  Hands-On

### Commands & Execution
```bash
# Fast-Forward Merge
git switch main
git switch -c feature-login

echo "Login feature started" > merge-demo.txt
git add merge-demo.txt
git commit -m "feat: start login feature"

echo "Login validation added" >> merge-demo.txt
git add merge-demo.txt
git commit -m "feat: add login validation"

git switch main
git merge feature-login

# Check history
git log --oneline --graph --decorate --all


# Merge Commit (Diverged Branches)
git switch main
git switch -c feature-signup

echo "Signup feature started" >> merge-demo.txt
git add merge-demo.txt
git commit -m "feat: start signup feature"

echo "Signup validation added" >> merge-demo.txt
git add merge-demo.txt
git commit -m "feat: add signup validation"

git switch main
echo "Main branch update" >> merge-demo.txt
git add merge-demo.txt
git commit -m "chore: update main branch"

git merge feature-signup

# Check history
git log --oneline --graph --decorate --all


# Intentional Merge Conflict
echo "Original line" > conflict-demo.txt
git add conflict-demo.txt
git commit -m "chore: add conflict example"

git switch -c feature-conflict
echo "Feature branch version" > conflict-demo.txt
git add conflict-demo.txt
git commit -m "feat: change conflict line on feature"

git switch main
echo "Main branch version" > conflict-demo.txt
git add conflict-demo.txt
git commit -m "feat: change conflict line on main"

git merge feature-conflict

# Resolve the conflict, then:
git add conflict-demo.txt
git commit -m "merge: resolve conflict"
```

### Key Concepts
* **⚡ Fast-Forward Merge:** Happens when `main` has no new commits after the feature branch was created. Git moves the `main` pointer forward without creating another commit.
* **🔀 Merge Commit:** Happens when the branches have diverged. Git combines both histories and creates a new merge commit.
* **⚠️ Merge Conflict:** Happens when Git cannot safely combine changes automatically, commonly because both branches changed the same part of a file differently. The developer must resolve the file manually, stage it, and complete the merge.
* **🔎 History Check:** `git log --oneline --graph --decorate --all` makes branch relationships and merge commits visible.

---

## Task 2: Git Rebase Hands-On

### Commands & Execution
```bash
git switch main
git switch -c feature-dashboard

# Feature commits
echo "# Dashboard" > dashboard.md
git add dashboard.md
git commit -m "feat: add dashboard page"

echo "Dashboard overview" >> dashboard.md
git add dashboard.md
git commit -m "feat: add dashboard overview"

echo "Metrics and statistics" >> dashboard.md
git add dashboard.md
git commit -m "feat: add dashboard metrics"

# Move main ahead
git switch main
echo "# Main Development" > main-update.md
git add main-update.md
git commit -m "chore: update main branch"

# Rebase feature branch onto latest main
git switch feature-dashboard
git rebase main

# Observe history
git log --oneline --graph --decorate --all
```

### Key Concepts
* **🧭 What Rebase Does:** Rebase takes your feature commits and places them **on top of the latest `main` commit**. Git replays the feature changes one by one instead of creating a merge commit.

* ** Example — Before Rebase:**
```text
  A---B---C---D   main
       \
        E---F     feature-dashboard
```
  Here, `main` moved forward with commit `D`, while the feature branch still has commits `E` and `F`.

* ** Example — After Rebase:**
```text
  A---B---C---D---E'---F'
                  ^
                 main
```
  The feature work is now based on `D`. The history looks like one straight line.

* **🔄 Commit IDs Change:** Rebase creates new versions of the feature commits (`E'` and `F'`). The changes are similar, but their commit hashes are different because their parent history changed.

* **⚠️ Never Rebase Public/Shared Commits:** Do **not** rebase commits that you have already pushed and that other people are using. Rebase rewrites commit history and changes commit hashes. Your teammates may still have the old commits, so their branches can become out of sync with yours and may require difficult conflict resolution or history recovery.

```text
  Shared history:
  A---B---C---D

  After you rebase:
  A---B---C---D'---E'

  D and D' are different commits.
  Your teammates may still have D,
  while your branch now uses D'.
```

  ✅ **Safe beginner rule:** Rebase your own **local/private feature branch**.  
  ❌ Avoid rebasing a branch whose commits are already shared with others.

* **⚖️ Rebase vs Merge:** Use **Rebase** when you want to update your private feature branch and keep the history linear. Use **Merge** when preserving the existing shared history is more important.

---

## Task 3: Squash Commit vs Merge Commit

### Commands & Execution
```bash
# Squash Merge
git switch main
git switch -c feature-profile

echo "# User Profile" > profile.md
git add profile.md
git commit -m "feat: add profile page"

echo "User information" >> profile.md
git add profile.md
git commit -m "feat: add user information"

echo "Contact information" >> profile.md
git add profile.md
git commit -m "feat: add contact information"

echo "## Preferences" >> profile.md
git add profile.md
git commit -m "style: format preferences section"

echo "Profile updated successfully" >> profile.md
git add profile.md
git commit -m "fix: improve profile message"

git switch main
git merge --squash feature-profile
git commit -m "feat: add profile feature"

# Check history
git log --oneline --graph --decorate --all


# Regular Merge
git switch main
git switch -c feature-settings

echo "# Application Settings" > settings.md
git add settings.md
git commit -m "feat: add settings page"

echo "Notification settings" >> settings.md
git add settings.md
git commit -m "feat: add notification settings"

echo "Account settings" >> settings.md
git add settings.md
git commit -m "feat: add account settings"

# Move main ahead so the branches diverge
git switch main
echo "Main branch continued development" > main-update.md
git add main-update.md
git commit -m "chore: continue main development"

# Regular merge
git merge feature-settings

# Compare history
git log --oneline --graph --decorate --all
```

### Key Concepts
* **🧹 Squash Merge:** Combines all changes from the feature branch into one new commit on `main`. Example: **5 feature commits → 1 commit on `main`**.
* **🔀 Regular Merge:** Integrates the feature branch while keeping its individual commits visible. When the branches have diverged, Git can also create a merge commit.
* **🎯 When to Squash:** Useful when a branch contains many small, temporary, formatting, typo, or WIP commits and a cleaner `main` history is preferred.
* **🧩 When to Regularly Merge:** Useful when the individual commits and original branch history are valuable for review, debugging, or traceability.
* **⚖️ Trade-Off:** Squashing simplifies history but removes the individual feature commits from `main`'s mainline history.

---

## Task 4: Git Stash  Hands-On

### Commands & Execution
```bash
# Start unfinished work on a tracked file
echo "Temporary work in progress" >> README.md

git status
git diff

# Try switching branches
git switch feature-settings

# Save unfinished work
git stash push -m "WIP settings changes"

# Verify working tree is clean
git status

# Show saved stashes
git stash list

# Switch branch and do other work
git switch main
echo "# Urgent Work" > urgent-fix.md
git add urgent-fix.md
git commit -m "fix: handle urgent issue"

# Return to the feature branch
git switch feature-settings

# Restore latest stash and remove it if applied successfully
git stash pop

# Check restored work
git status
git diff


# Create multiple stashes
echo "First WIP" >> README.md
git stash push -m "WIP: first settings change"

echo "Second WIP" >> README.md
git stash push -m "WIP: second settings change"

echo "Third WIP" >> README.md
git stash push -m "WIP: third settings change"

# List all stashes
git stash list

# Apply one specific stash without removing it
git stash apply stash@{2}

# Check result
git status
git diff
git stash list
```

### Key Concepts
* **📦 What Stash Does:** Temporarily stores uncommitted tracked changes and returns the working tree to a clean state.
* **↔️ `stash pop` vs `stash apply`:** `pop` restores the stash and normally removes that stash entry after successful application. `apply` restores the changes but keeps the stash entry.
* **🔢 Multiple Stashes:** `git stash list` shows entries such as `stash@{0}`, `stash@{1}`, and `stash@{2}`. The numbering starts at `0` and can change after entries are removed.
* **💼 Real-World Use:** Useful when unfinished work must be paused so another branch can be checked out for an urgent bug fix or other high-priority task.
* **📌 Untracked Files:** Normal stash does not include untracked files. Use `git stash push -u -m "message"` when untracked files also need to be saved.

---

## Task 5: Cherry Picking

### Commands & Execution
```bash
git switch main
git switch -c feature-hotfix

# Commit 1
echo "Hotfix change one" > hotfix-one.txt
git add hotfix-one.txt
git commit -m "fix: add hotfix change one"

# Commit 2
echo "Hotfix change two" > hotfix-two.txt
git add hotfix-two.txt
git commit -m "fix: add hotfix change two"

# Commit 3
echo "Hotfix change three" > hotfix-three.txt
git add hotfix-three.txt
git commit -m "fix: add hotfix change three"

# Find the commit hashes
git log --oneline -3

# Switch to main
git switch main

# Apply ONLY the second commit
git cherry-pick <SECOND-COMMIT-HASH>

# Verify
git log --oneline --graph --decorate --all
```

### Key Concepts
* **🍒 What Cherry-Pick Does:** Applies the changes introduced by one selected commit to the current branch as a new commit.
* **🎯 Selective Integration:** It does not merge the whole feature branch. Only the chosen commit's changes are brought over.
* **💼 Real-World Use:** Useful for moving a specific bug fix or isolated change to another branch without taking unfinished work along with it.
* **⚠️ Risks:** Conflicts can occur, and the selected commit may depend on earlier commits that are not present on the target branch.

---

## 📋 Summary of Commands (`git-commands.md` Reference)

| Command | Category | Description |
| :--- | :--- | :--- |
| `git switch <branch>` | Branch | Move to another branch |
| `git switch -c <branch>` | Branch | Create and switch to a new branch |
| `git merge <branch>` | Merge | Integrate another branch into the current branch |
| `git merge --squash <branch>` | Merge | Combine feature changes into one new commit |
| `git rebase <branch>` | Rebase | Replay current branch commits on top of another branch |
| `git rebase --continue` | Rebase | Continue a paused rebase after resolving conflicts |
| `git rebase --abort` | Rebase | Cancel the current rebase |
| `git stash push -m "message"` | Stash | Save tracked uncommitted changes with a label |
| `git stash list` | Stash | List saved stashes |
| `git stash apply stash@{N}` | Stash | Restore a specific stash and keep it |
| `git stash pop` | Stash | Restore the latest stash and normally remove it |
| `git stash push -u -m "message"` | Stash | Include untracked files in the stash |
| `git cherry-pick <hash>` | Cherry-Pick | Apply one selected commit to the current branch |
| `git log --oneline --graph --decorate --all` | History | Visualize commits and branch structure |
| `git status` | Inspection | Show the current repository state |
| `git diff` | Inspection | Show unstaged changes |

---
---

## 🧠 Final Takeaway

```text
🔀 Merge       → Combine branch histories
🧭 Rebase      → Replay commits on a new base
🧹 Squash      → Turn several feature commits into one commit
📦 Stash       → Temporarily store unfinished work
🍒 Cherry-Pick → Apply one selected commit
```
## 🌐 Learn in Public

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
