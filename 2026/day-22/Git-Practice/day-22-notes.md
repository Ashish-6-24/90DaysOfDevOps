# 📚 Day 22 Introduction to Git

> **90 Days of DevOps | Git Fundamentals**

Today I started working with Git.

Instead of only reading about version control, I created a repository, made changes, staged them, committed them, and checked the history.

The main thing I wanted to understand was simple:

**How does a change in a file become part of Git history?**

---

## 🎯 Today's Goal

By the end of this exercise, I wanted to be comfortable with:

- ⚙️ Installing and configuring Git
- 📁 Creating a Git repository
- 🔎 Reading `git status`
- 📝 Writing my own Git command reference
- 📦 Understanding the staging area
- 💾 Creating meaningful commits
- 🕘 Reading commit history

---

## 🧰 Git Setup

Before creating the repository, I checked that Git was available and configured my identity.

```bash
git --version

git config --global user.name "Your Name"
git config --global user.email "your@email.com"

git config --list
```

### Why the configuration matters

Git records an author with every commit.

So before making commits, Git needs to know who is creating them.

---

## 📁 Creating My First Repository

I created a separate practice directory for the Git exercises.

```bash
mkdir devops-git-practice
cd devops-git-practice

git init
git status
```

After running `git init`, Git created a hidden directory:

```text
.git/
```

That directory is what gives this folder its Git repository structure.

---

## 🔍 Looking Inside `.git`

I also explored the hidden Git directory instead of treating it like a black box.

```bash
ls -la
ls -la .git
```

The `.git` directory contains Git's internal information, including repository objects, references, configuration, and other metadata.

### ⚠️ Important

The `.git` directory is not something I normally edit manually.

Deleting it would remove the local Git history and repository information from the project.

---

## 📝 My Git Command Reference

One part of today's work was creating a file that I can keep updating as I learn more Git.

```text
git-commands.md
```

I organized the commands into three practical sections.

### ⚙️ Setup & Config

| Command | What I use it for |
|---|---|
| `git --version` | Check the installed Git version |
| `git config` | View or change Git settings |

### 🔄 Basic Workflow

| Command | What I use it for |
|---|---|
| `git init` | Start a Git repository |
| `git status` | Check the current repository state |
| `git add` | Put selected changes into the staging area |
| `git commit` | Save the staged changes as a commit |

### 🔎 Viewing Changes & History

| Command | What I use it for |
|---|---|
| `git diff` | See changes that are not staged |
| `git diff --staged` | See changes that are staged |
| `git log` | Read commit history |
| `git log --oneline` | Read commit history in a compact format |

This file will continue growing during the next Git lessons.

---

## 🔄 The Workflow I Practiced

The most useful idea from today was understanding that Git has different stages.

```text
📝 Working Directory
        │
        │ git add
        ▼
📦 Staging Area
        │
        │ git commit
        ▼
🗃️ Repository History
```

### In simple words

**Working Directory**

This is where I edit my files.

**Staging Area**

This is where I choose which changes should go into the next commit.

**Repository**

This is where Git keeps the committed snapshots and history.

---

## 🧠 What Finally Became Clear

### `git add` and `git commit` are not the same thing

I think of it like this:

```text
git add
→ "I want this change in my next snapshot."

git commit
→ "Record that staged snapshot in Git history."
```

That small distinction makes the Git workflow much easier to understand.

---

## 📦 Why the Staging Area Matters

Suppose I change three files:

```text
README.md
git-commands.md
notes.txt
```

But I only want to commit:

```text
git-commands.md
```

I can stage only that file:

```bash
git add git-commands.md
```

This gives me control over what goes into the next commit.

---

## 💡 Key Lessons

### 1. Git watches changes

`git status` quickly tells me what is happening in the repository.

### 2. Staging gives me control

I don't have to commit every change I make.

### 3. Commits create checkpoints

Each commit gives me a saved point in the project's history.

### 4. Good commit messages matter

A useful commit message makes the history easier to understand later.

### 5. Git is more than a backup

It gives me a structured way to track how a project changes over time.

---

## 🚀 What I Practiced Today

```text
✅ Installed / verified Git
✅ Configured Git identity
✅ Created a local repository
✅ Explored .git/
✅ Created git-commands.md
✅ Used the staging area
✅ Created multiple commits
✅ Inspected changes with git diff
✅ Inspected staged changes
✅ Viewed commit history
```

---

## 📂 Day 22 Files

```text
2026/
└── day-22/
    ├── git-commands.md
    ├── day-22-notes.md
    └── README.md
```
---

### 🏷️ 90 Days of DevOps

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
