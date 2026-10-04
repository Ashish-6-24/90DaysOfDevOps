# 📚 Day 23: Git Branching & Working with GitHub

Today I learned how to create and manage Git branches, work with GitHub, and understand `fetch`, `pull`, `clone`, and `fork`.

---

## 🌿 1. Understanding Branches

### What is a branch?

A branch is a separate line of development. It lets us work on features or changes without directly affecting `main`.

### Why use branches?

Branches keep new or unfinished work separate from the stable `main` branch.

### What is `HEAD`?

`HEAD` points to the branch or commit I am currently working on.

### What happens when switching branches?

Git updates the working files to match the selected branch.

---

## 🔀 2. Branch Commands

```bash
git branch
git branch feature-1
git switch feature-1
git switch -c feature-2
git switch main
git branch -d feature-2
```

### `git switch` vs `git checkout`

* `git switch <branch>` → Switches to an existing branch.
* `git switch -c <branch>` → Creates and switches to a new branch.
* `git checkout <branch>` → Older command used to switch branches.
* `git checkout -b <branch>` → Creates and switches to a new branch.

---

## 🌱 3. Feature Branch Commit

Changes committed on `feature-1` stay on that branch until they are merged.

```bash
git switch feature-1
git add .
git commit -m "feat: add feature-1 changes"

git switch main
git log --oneline
```

The commit made on `feature-1` is not part of `main` until the branches are merged.

---

## ☁️ 4. Working with GitHub

Connect the local repository using SSH:

```bash
git remote add origin git@github.com:USERNAME/devops-git-practice.git
```

Push the branches:

```bash
git push -u origin main
git push -u origin feature-1
```

### 🔗 `origin` vs `upstream`

`origin` points to your own GitHub repository or personal fork. You normally have read and write access, so you can push your changes there.

`upstream` points to the original repository owned by another user or organization. You usually use it to fetch the latest changes and keep your fork updated.

```text
upstream → Original Repository
                ↓
              Fork
                ↓
origin → Your GitHub Repository
```

Example:

```bash
git fetch upstream
git push origin main
```

* `git fetch upstream` → Gets the latest changes from the original repository.
* `git push origin main` → Pushes your changes to your own repository.

---

## 🔄 5. Fetch vs Pull

```bash
git fetch origin
git pull origin main
```

* `git fetch` → Downloads changes without merging them.
* `git pull` → Downloads changes and integrates them into the current branch.

---

## 📦 6. Clone vs Fork

### Clone

A clone copies a repository from GitHub to your local machine.

```bash
git clone <repository-url>
```

### Fork

A fork creates your own copy of another user's repository on GitHub.

```text
Original Repository
        ↓
       Fork
        ↓
 Your GitHub Repository
        ↓
      Clone
        ↓
  Local Machine
```

* Clone → Use when you want a repository on your computer.
* Fork → Use when you want your own GitHub copy, especially when contributing without direct write access.

---

## 🔄 Keep a Fork Updated

```bash
git remote add upstream <original-repo-url>
git fetch upstream
git switch main
git merge upstream/main
git push origin main
```

---

## 🧠 Key Learning

* Create and switch between branches.
* Use branches to keep feature work separate from `main`.
* Understand `HEAD`.
* Push branches to GitHub.
* Understand `origin` and `upstream`.
* Understand `git fetch` and `git pull`.
* Understand clone vs fork.
* Keep a fork synchronized with the original repository.

---

## ✅ Day 23 Completed 🚀

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
