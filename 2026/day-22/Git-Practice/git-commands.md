# Git Commands Cheat Sheet 🚀

A quick-reference guide for the Git commands I practiced during **Day 22** of my DevOps learning journey.

---

## 📌 Day 22 – Git Basics

### ⚙️ Setup & Configuration

| # | Command | Description |
|---|---|---|
| 1 | `git --version` | Checks whether Git is installed and shows its version. |
| 2 | `git config --global user.name "username"` | Sets the name Git uses for my commits. |
| 3 | `git config --global user.email "email@example.com"` | Sets the email Git uses for my commits. |
| 4 | `git config --global --list` | Shows my global Git configuration. |

---

### 📁 Repository Setup

| # | Command | Description |
|---|---|---|
| 5 | `git init` | Creates a new Git repository in the current directory. |
| 6 | `git status` | Shows the current state of the repository. |
| 7 | `ls -la` | Shows files and hidden files, including the `.git` directory. |
| 8 | `ls -la .git` | Shows the files and directories inside Git's internal repository directory. |

---

### 📦 Staging & Committing

| # | Command | Description |
|---|---|---|
| 9 | `git add <filename>` | Stages a specific file for the next commit. |
| 10 | `git add .` | Stages all detected changes in the current directory. |
| 11 | `git commit -m "<message>"` | Creates a commit from the changes currently in the staging area. |
| 12 | `git status` | Checks what is staged, unstaged, or untracked before committing. |

---

### 🔎 Viewing Changes

| # | Command | Description |
|---|---|---|
| 13 | `git diff` | Shows changes that have not been staged yet. |
| 14 | `git diff --staged` | Shows changes that are currently staged for the next commit. |

---

### 🕘 Viewing Commit History

| # | Command | Description |
|---|---|---|
| 15 | `git log` | Shows detailed information about previous commits. |
| 16 | `git log --oneline` | Shows commits in a short, one-line format. |
| 17 | `git show` | Shows the details and changes introduced by a specific commit. |

---
