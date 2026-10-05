# Git Commands Cheat Sheet 🚀

A quick-reference guide for the Git commands I practiced during my DevOps learning journey.

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

## 📌 Day 23 – Git Branching & GitHub

### 🌿 Branch Management

| # | Command | Description |
|---|---|---|
| 18 | `git branch` | Lists all local branches. |
| 19 | `git branch feature-1` | Creates a new branch called `feature-1`. |
| 20 | `git switch feature-1` | Switches to an existing branch. |
| 21 | `git switch -c feature-2` | Creates a new branch and switches to it in one command. |
| 22 | `git checkout main` | Switches to the `main` branch using the older checkout command. |
| 23 | `git checkout -b feature-1` | Creates a new branch and switches to it in one command. |
| 24 | `git switch main` | Switches back to the `main` branch. |
| 25 | `git branch -d feature-2` | Deletes a local branch that is no longer needed. |

---

### 🔄 `git switch` vs `git checkout`

| Command | Description |
|---|---|
| `git switch <branch>` | Switches to an existing branch. |
| `git switch -c <branch>` | Creates and switches to a new branch. |
| `git checkout <branch>` | Older command used to switch branches. |
| `git checkout -b <branch>` | Older command that creates and switches to a new branch. |

---

### ☁️ GitHub & Remote Repository

| # | Command | Description |
|---|---|---|
| 26 | `git remote -v` | Shows the remote repositories connected to the local repository. |
| 27 | `git remote add origin <github-repo-url>` | Connects the local repository to a GitHub remote named `origin`. |
| 28 | `git branch -M main` | Renames the current branch to `main`. |
| 29 | `git push -u origin main` | Pushes the local `main` branch to GitHub and sets its upstream tracking branch. |
| 30 | `git push -u origin feature-1` | Pushes the `feature-1` branch to GitHub and sets its upstream tracking branch. |

---

### 🔗 `origin` vs `upstream`

**`origin`** → Usually points to my own GitHub repository or personal fork, where I have read and write access.

**`upstream`** → Usually points to the original repository, which I use to get the latest changes and keep my fork updated.

```text
upstream → Original Repository
                ↓
              Fork
                ↓
origin → My GitHub Repository
```

| # | Command | Description |
|---|---|---|
| 31 | `git remote add upstream <original-repo-url>` | Adds the original repository as a remote named `upstream`. |
| 32 | `git fetch upstream` | Downloads the latest changes and branch information from the original repository. |
| 33 | `git merge upstream/main` | Merges the latest `main` changes from `upstream` into the current branch. |

---

### 🔄 Fetch & Pull

| # | Command | Description |
|---|---|---|
| 34 | `git fetch origin` | Downloads changes from the remote without merging them into the current branch. |
| 35 | `git pull origin main` | Downloads changes from GitHub and integrates them into the current branch. |

---

### 📦 Clone

| # | Command | Description |
|---|---|---|
| 36 | `git clone <repository-url>` | Copies a remote repository from GitHub to the local machine. |

> 💡 **Fork** is a GitHub feature, not a Git command. It creates your own copy of another repository on GitHub.

---

# 📌 Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry-Pick

## 🔀 Merge

| # | Command | Description |
|---|---|---|
| 37 | `git merge <branch>` | Merges the specified branch into the branch I am currently on. |
| 38 | `git merge --squash <branch>` | Combines the changes from the feature branch into the current branch without creating the source branch's individual commits; I create the final commit separately. |

---

## ⚠️ Merge Conflict Resolution

| # | Command | Description |
|---|---|---|
| 39 | `git merge <branch>` | Starts the merge and may stop when Git finds conflicting changes. |
| 40 | `git add <filename>` | Marks a manually resolved conflicted file as resolved. |
| 41 | `git commit -m "<message>"` | Completes the merge after all conflicts have been resolved and staged. |

---

## 🧭 Rebase

| # | Command | Description |
|---|---|---|
| 42 | `git rebase <branch>` | Replays the current branch's commits on top of the specified branch. |


## 🧹 Squash Merge

| # | Command | Description |
|---|---|---|
| 43 | `git merge --squash <branch>` | Collects all changes from the feature branch into the working tree/staging area without creating the final commit automatically. |
| 44 | `git commit -m "<message>"` | Creates the single final commit after a squash merge. |


## 📦 Git Stash

| # | Command | Description |
|---|---|---|
| 45 | `git stash push -m "<message>"` | Temporarily saves tracked uncommitted changes and labels the stash with a message. |
| 46 | `git stash list` | Lists all saved stash entries. |
| 47 | `git stash pop` | Restores the latest stash and normally removes that stash entry after successful application. |
| 48 | `git stash apply stash@{N}` | Restores a specific stash while keeping that stash entry in the stash list. |


### 🧠 `pop` vs `apply`

| Command | Restores changes | Keeps stash entry |
|---|---:|---:|
| `git stash pop` | ✅ | ❌ Normally removed after success |
| `git stash apply stash@{N}` | ✅ | ✅ |

> 💡 The stash numbering starts at `0`, so `stash@{0}` is normally the newest entry.

---

## 🍒 Cherry-Pick

| # | Command | Description |
|---|---|---|
| 49 | `git cherry-pick <commit-hash>` | Applies the changes introduced by one specific commit to the current branch as a new commit. |

