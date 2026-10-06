# Day 26 GitHub CLI: Manage GitHub from Your Terminal

> A quick record of what I practiced with the GitHub CLI (`gh`) on Ubuntu.

---

## 📌 Overview

```text
git → local Git work
gh  → GitHub work from the terminal
```

I used `gh` to work with repositories, issues, pull requests, and GitHub Actions.

---

# 1️⃣ Install & Authenticate

### Install GitHub CLI

```bash
sudo apt update
sudo apt install gh -y
```

### Login to GitHub

```bash
gh auth login
```

### Check login and active account

```bash
gh auth status
```

I authenticated successfully with GitHub and used **SSH** for Git operations.

### 🔐 Authentication methods

`gh` supports browser-based login, Personal Access Tokens (PAT), and environment tokens such as `GH_TOKEN`.

### 📸 Screenshot

![GitHub CLI Authentication](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/01_GITHUB_AUTH.png)

---

# 2️⃣ Working with Repositories 📦

### Create a public repository with README

```bash
gh repo create gh-cli-practice --public --add-readme
```

### Clone with GitHub CLI

```bash
gh repo clone gh-cli-practice
```

### View repository details

```bash
gh repo view gh-cli-practice
```

### List repositories

```bash
gh repo list --visibility public
```

### Open repository from terminal

```bash
gh repo view gh-cli-practice --web
```

> 💡 On my headless Ubuntu server, the browser did not open automatically because `xdg-open` was unavailable. `gh` displayed the URL so it could be opened manually.

### Delete the test repository

```bash
gh repo delete gh-cli-practice --yes
```

> ⚠️ Before deleting a repository, always verify the repository name. I also had to refresh the `delete_repo` permission before deletion.

### 📸 Screenshot

![Repository created](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/02_created_repo_using_cli.png)

![Repository deleted](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/03_deleted_repo.png)

---

# 3️⃣ GitHub Issues 

### Create an issue

```bash
gh issue create \
  --title "Test issue from GitHub CLI" \
  --body "This issue was created from the terminal." \
  --label "bug"
```

### List open issues

```bash
gh issue list
```

### View an issue

```bash
gh issue view 1
```

### Close an issue

```bash
gh issue close 1 --reason completed
```

### 💡 Automation use

`gh issue` can be used in scripts to create or update issues automatically when a build, deployment, test, or monitoring check fails.

### 📸 Screenshot

![Issue created](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/04_created_issue.png)

![Issue on GitHub](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/05_issue_github.png)

![Issue closed](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/06_closed_issue.png)

---

# 4️⃣ Pull Requests 

### Create a branch

```bash
git checkout -b test-ghpr
```

### Make a change

```bash
echo "GitHub CLI PR practice" >> gh-cli-practice.txt
```

### Stage and commit

```bash
git add gh-cli-practice.txt
git commit -m "Practice PR with github cli"
```

### Push the branch

```bash
git push -u origin test-ghpr
```

### Create PR from terminal

```bash
gh pr create
```

### List open PRs

```bash
gh pr list
```

### View PR details

```bash
gh pr view
```

### Check PR status/checks

```bash
gh pr checks <PR-number>
```

### View PR changes

```bash
gh pr diff <PR-number>
```

### Merge PR

```bash
gh pr merge
```

###  Merge methods

```text
--merge   → merge commit
--squash  → combine commits into one
--rebase  → replay commits on the base branch
```

### 👀 Review another PR

```bash
gh pr view <PR-number>
gh pr checks <PR-number>
gh pr diff <PR-number>
```

I can then submit a review with:

```bash
gh pr review <PR-number> --approve
gh pr review <PR-number> --comment --body "Looks good."
gh pr review <PR-number> --request-changes --body "Please fix this."
```

### 🧠 PR lesson

The source branch should come from the same Git history as the target branch. Otherwise GitHub may report:

```text
The branch has no history in common with main
```

### 📸 Screenshot 

![PR created](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/07_created_pull_request.png)

![Open PR list](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/08_pull_request_list.png)

![PR merged](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/09_pr_merged.png)

---

# 5️⃣ GitHub Actions & Workflows 

### List workflow runs

```bash
gh run list --repo cli/cli
```

### View a specific run

```bash
gh run view 37432414256 --repo cli/cli
```

### 🧠 Important

```text
gh workflow list
→ lists workflows

gh run list
→ lists workflow runs

gh run view <run-id>
→ views one workflow run
```

I initially used a workflow ID with `gh run view`. That returned `404` because `gh run view` needs the **workflow run ID**, not the workflow ID.

### 💡 CI/CD use

`gh run` and `gh workflow` can help me check pipeline results, inspect failures, monitor runs, and automate CI/CD tasks from the terminal.

### 📸 Proof

![Workflow runs](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/10_workflow%20run.png)

![Specific workflow run](https://raw.githubusercontent.com/Ashish-6-24/90DaysOfDevOps/master/2026/day-26/images/11_status%20of%20a%20specific%20workflow%20run.png)

---

# 6️⃣ Useful `gh` Tricks 

### GitHub API

```bash
gh api user
```

Makes a direct GitHub API request.

### Gist

```bash
gh gist list
gh gist create <file>
```

Creates and manages Gists.

### Release

```bash
gh release list
gh release create <tag>
```

Lists and creates releases.

### Alias

```bash
gh alias list
gh alias set pv "pr view"
```

Creates a shortcut for a commonly used command.

### Search repositories

```bash
gh search repos "devops"
```

Searches GitHub repositories from the terminal.

---

# 🧠 Quick Cheat Sheet

| Command | Purpose |
|---|---|
| `gh auth` | Login and authentication |
| `gh repo` | Repository management |
| `gh issue` | Issue management |
| `gh pr` | Pull request management |
| `gh workflow` | Workflow management |
| `gh run` | Workflow run management |
| `gh api` | GitHub API |
| `gh gist` | Gists |
| `gh release` | Releases |
| `gh alias` | Command shortcuts |
| `gh search repos` | Search repositories |

---

# 🎯 Day 26 Takeaway

```text
git
 ↓
Local repository

gh
 ↓
GitHub from terminal
 ↓
Repos + Issues + PRs + Actions + API
```

The biggest benefit I saw is that GitHub tasks can be done faster from the terminal and can later be connected to **scripts, automation, and CI/CD pipelines**.

---

## ✅ Day 26 Checklist

- [x] Install and authenticate GitHub CLI
- [x] Create, clone, view, list, and delete a repository
- [x] Create, list, view, and close an issue
- [x] Create, inspect, and merge a Pull Request
- [x] Check PR changes and status checks
- [x] List and view GitHub Actions runs
- [x] Explore `gh api`
- [x] Explore `gh gist`
- [x] Explore `gh release`
- [x] Explore `gh alias`
- [x] Explore `gh search repos`
