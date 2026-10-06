# GitHub CLI (`gh`) Command Reference

A quick reference based on the **commands I actually practiced during Day 26** in my `90DaysOfDevOps` repository.

## 🔐 1. Installation & Authentication

| Command | Use |
|---|---|
| `sudo apt update` | Updates Ubuntu package information so the latest package metadata is available before installation. |
| `sudo apt install gh -y` | Installs GitHub CLI (`gh`) on Ubuntu so GitHub tasks can be handled from the terminal. |
| `gh auth login` | Starts GitHub CLI authentication so the terminal can access your GitHub account. |
| `gh auth status` | Shows the current authentication status and active GitHub account so you can verify the login. |
| `gh auth refresh -h github.com -s delete_repo` | Refreshes GitHub authorization with the `delete_repo` scope when repository deletion needs extra permission. |

### 🔑 Authentication methods I noted

`gh` supports browser-based login, Personal Access Tokens (PAT), and environment tokens such as `GH_TOKEN`.

---

## 📦 2. Repository Management

| Command | Use |
|---|---|
| `gh repo create gh-cli-practice --public --add-readme` | Creates the Day 26 practice repository as a public GitHub repository with a README. |
| `gh repo clone gh-cli-practice` | Clones the practice repository using GitHub CLI instead of `git clone`. |
| `gh repo view gh-cli-practice` | Shows details of the practice repository from the terminal. |
| `gh repo list --visibility public` | Lists public repositories so you can quickly see your public repos. |
| `gh repo view gh-cli-practice --web` | Opens the practice repository in a web browser from the terminal. |
| `gh repo delete gh-cli-practice --yes` | Deletes the temporary practice repository without asking for confirmation. |

> ⚠️ Always check the repository name before using `gh repo delete` because deletion is destructive.

---

## 3. GitHub Issues

| Command | What + Why + When |
|---|---|
| `gh issue create --title "Test issue from GitHub CLI" --body "This issue was created from the terminal." --label "bug"` | Creates a GitHub issue with a title, body, and `bug` label for practicing issue management from the terminal. |
| `gh issue list` | Lists open issues in the current repository so you can see active work. |
| `gh issue view 1` | Displays issue `#1` so you can inspect its details from the terminal. |
| `gh issue close 1 --reason completed` | Closes issue `#1` as completed after the work is finished. |

### 💡 Automation use

`gh issue` can be used in scripts to create or update issues automatically when a build, deployment, test, or monitoring check fails.

---

## 4. Branch & Commit Commands Used for the PR Practice

| Command | Use |
|---|---|
| `git checkout -b test-ghpr` | Creates and switches to the `test-ghpr` branch so the PR work is isolated from `main`. |
| `echo "GitHub CLI PR practice" >> gh-cli-practice.txt` | Adds a small test change to the practice file so there is something to commit and send through a PR. |
| `git add gh-cli-practice.txt` | Stages the changed practice file so it can be included in the next commit. |
| `git commit -m "Practice PR with github cli"` | Creates a commit containing the PR practice change with a clear message. |
| `git push -u origin test-ghpr` | Pushes `test-ghpr` to GitHub and sets its upstream so the branch is connected to the remote branch. |
| `git reset --hard origin/main` | Resets the local practice branch to `origin/main` when the branch histories need to be aligned. **Destructive for uncommitted local changes.** |
| `git push --force-with-lease -u origin test-ghpr` | Force-updates the personal practice branch after rewriting its history while protecting against unexpected remote changes. |
| `git log --oneline --graph --all --decorate` | Shows the commit history and branch relationships so you can verify whether branches share common history. |

> 🧠 **PR lesson from my practice:** the source branch needs a common Git history with the target branch. Otherwise GitHub can report that the branch has no history in common with `main`.

---

## 5. Pull Requests

| Command | Use |
|---|---|
| `gh pr create` | Creates a pull request from the terminal after the feature branch has been pushed. |
| `gh pr list` | Lists open pull requests so you can see active PRs in the repository. |
| `gh pr view` | Shows the pull request connected to the current branch so you can inspect its details. |
| `gh pr checks <PR-number>` | Shows the status checks for a PR so you can confirm whether required checks have passed. |
| `gh pr diff <PR-number>` | Displays the changes in a PR so you can review exactly what will be merged. |
| `gh pr merge` | Merges the current pull request from the terminal after it is ready. |
| `gh pr review <PR-number> --approve` | Approves another person's PR when the changes have been reviewed and look correct. |
| `gh pr review <PR-number> --comment --body "Looks good."` | Leaves a review comment without approving or rejecting the PR. |
| `gh pr review <PR-number> --request-changes --body "Please fix this."` | Requests changes when the PR needs fixes before it should be merged. |

### Merge methods supported by `gh pr merge`

```text
--merge   → merge commit
--squash  → combine commits into one
--rebase  → replay commits on the base branch
```
## 6. GitHub Actions & Workflow Runs

### Commands I practiced

| Command | Use |
|---|---|
| `gh workflow list --repo cli/cli` | Lists the workflows configured in the public `cli/cli` repository so you can see available GitHub Actions workflows. |
| `gh run list --repo cli/cli` | Lists actual workflow runs in `cli/cli` so you can find a specific run ID. |
| `gh run view 37432414256 --repo cli/cli` | Views the specific workflow run I practiced with using its **run ID**. |

### 🧠 Workflow ID vs Run ID

```text
gh workflow list
→ lists workflows

gh run list
→ lists workflow runs

gh run view <run-id>
→ views one workflow run
```

> ⚠️ A workflow ID and a workflow run ID are different. `gh run view` needs the **workflow run ID**.

### 💡 CI/CD use

`gh run` and `gh workflow` can be used to check pipeline results, inspect failures, monitor runs, and automate CI/CD tasks from the terminal.

---

## 🛠️ 7. Useful `gh` Tricks

| Command | Use |
|---|---|
| `gh api user` | Makes a direct GitHub API request so you can work with GitHub data from the terminal. |
| `gh gist list` | Lists your GitHub Gists so you can quickly manage shared snippets. |
| `gh gist create <file>` | Creates a GitHub Gist from a file when you want to share a small piece of code or text. |
| `gh release list` | Lists repository releases so you can inspect published versions. |
| `gh release create <tag>` | Creates a GitHub release for a tag when publishing a version of a project. |
| `gh alias list` | Lists your custom `gh` shortcuts so you can see the aliases already configured. |
| `gh alias set pv "pr view"` | Creates `pv` as a shortcut for `gh pr view` so a frequently used command is faster to type. |
| `gh search repos "devops"` | Searches GitHub repositories from the terminal when looking for projects related to DevOps. |

---



