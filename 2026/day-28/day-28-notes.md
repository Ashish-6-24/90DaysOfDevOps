# Day 28 – Revision Day: Everything from Day 1 to Day 27

## Overview

Day 28 was dedicated to revision rather than learning a new tool. I reviewed the DevOps foundations, Linux and AWS practice, storage management, networking, Bash scripting, Git and GitHub, GitHub CLI, and profile organization documented during Days 1–27.

The purpose of this revision is to strengthen recall, revisit the commands and workflows already documented, and check whether I can explain both the command and its result. The examples below reflect the work recorded in my daily notes, scripts, and cheat sheets. 

---

## Task 1: Self-Assessment Checklist

### Linux and Cloud

- [x] Navigate the filesystem and create, copy, move, rename, and delete files and directories.
- [x] Inspect processes and review process/resource information.
- [x] Check systemd service status, service enablement, and running services; inspect service and kernel logs.
- [x] Read, write, and edit text files using the file commands and editors practised.
- [x] Troubleshoot CPU, memory, disk capacity, and disk I/O using `top`, `htop`, `ps`, `free`, `df`, `du`, and `iostat`.
- [x] Explain common Linux paths such as `/`, `/etc`, `/home`, `/var/log`, `/tmp`, `/usr`, `/dev`, and `/proc`.
- [x] Create users and groups, set passwords, and check group membership.
- [x] Set and interpret numeric file permissions with `chmod`; review symbolic execute-permission changes.
- [x] Change file ownership and group ownership with `chown` and `chgrp`.
- [x] Create, format, mount, inspect, and extend an LVM logical volume in the documented lab.
- [x] Check network connectivity with `ping`, `curl`, and `traceroute`.
- [x] Inspect listening sockets with `ss`, practise `netstat`, check local ports with `nc`, and inspect DNS with `dig`.
- [x] Explain DNS records, private IPv4 ranges, CIDR/subnets, TCP/UDP, and common service ports.
- [x] Deploy and check Nginx on AWS EC2; inspect UFW rules and Nginx access logs.

### Shell Scripting

- [x] Write Bash scripts using a shebang, variables, quoted expansions, user input, and command-line arguments.
- [x] Use `if`, `elif`, `else`, file tests such as `-f`, and `case` statements.
- [x] Practise `for`, `while`, and `until` loops.
- [x] Define functions, use local variables, pass arguments, and check return statuses.
- [x] Process text using `grep`, `awk`, `sed`, `sort`, and `uniq`.
- [x] Validate script arguments and check that files or directories exist.
- [x] Review `set -e`, `set -u`, `set -o pipefail`, `set -x`, and `trap` from the shell cheat sheet and scripts.
- [x] Schedule script execution with `crontab`.
- [x] Review the log rotation, backup, maintenance, and log-analysis scripts from Days 19–20.

### Git, GitHub, and GitHub CLI

- [x] Initialize or clone a repository; check status, stage files, commit, and view history.
- [x] Inspect changes with `git diff` and `git diff --staged`.
- [x] Create and switch branches, push branches, and merge changes.
- [x] Explain clone versus fork, and `origin` versus `upstream`.
- [x] Explain `git fetch` versus `git pull`.
- [x] Understand fast-forward merge, merge commit, and merge conflict resolution.
- [x] Practise rebase, stash, cherry-pick, and squash merge.
- [x] Explain `git reset --soft`, `--mixed`, and `--hard`, compare reset with revert, and review `git reflog`.
- [x] Compare GitFlow, GitHub Flow, and Trunk-Based Development.
- [x] Use GitHub CLI (`gh`) for authentication, repositories, issues, pull requests, and PR checks.
- [x] Review the Git command reference, shell scripting cheat sheet, GitHub profile README, and repository organization.

---

## Task 2: Revisit My Weak Spots

I selected five areas for focused revision based on the commands and practical tasks documented in my Days 1–27 repository. The sections below are grouped by topic and use command examples already recorded in those notes and scripts. I will practise these in a lab and verify each result before considering the topic confident.

### Linux

#### 1. Create and Manage LVM Volumes 

**Goal:** Understand the complete LVM flow and practise inspecting, creating, formatting, mounting, and extending a logical volume.

The Day 13 lab used a separate 12 GiB EBS disk identified as `/dev/nvme2n1`. That device name is specific to the documented lab and must not be copied blindly to another machine.

**Commands**

```bash
lsblk
fdisk -l
pvs
vgs
lvs
df -h

pvcreate /dev/nvme2n1
vgcreate devops-vg /dev/nvme2n1
lvcreate -L 500M -n app-data devops-vg
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
```

**Storage flow to remember:**

```text
Disk
  ↓
Physical Volume (PV)
  ↓
Volume Group (VG)
  ↓
Logical Volume (LV)
  ↓
Filesystem
  ↓
Mount Point
```

**What I am revising:**

- Identify the correct disk before creating a physical volume.
- Explain the purpose of a PV, VG, and LV.
- Format the logical volume with ext4 and mount it at `/mnt/app-data`.
- Verify the mount and available filesystem space with `df -h`.
- Extend the LV and then resize the ext4 filesystem.

**Safety:** `pvcreate` and `mkfs.ext4` can destroy existing data on the selected device. Inspect the devices first and use only a confirmed disposable lab disk. Never assume `/dev/nvme2n1` exists or is unused on another machine.

#### 2. File Permissions with `chmod` 

**Goal:** Read permission strings and apply numeric and symbolic permissions to a file or script.

**Numeric-permission commands documented in Day 10:**

```bash
touch devops.txt
echo "Hello this is my notes files" > notes.txt
vim script.sh
chmod 774 script.sh
chmod 444 devops.txt
chmod 640 notes.txt
chmod 755 project
chmod 644 script.sh
ls -l
```

The shell scripting cheat sheet also practised adding execute permission symbolically:

```bash
chmod +x script.sh
./script.sh
```

**Numeric permissions to revise:**

| Mode | Owner | Group | Others |
|---|---|---|---|
| `774` | `rwx` | `rwx` | `r--` |
| `444` | `r--` | `r--` | `r--` |
| `640` | `rw-` | `r--` | `---` |
| `755` | `rwx` | `r-x` | `r-x` |
| `644` | `rw-` | `r--` | `r--` |

**What I am revising:**

- Convert the numeric digits into owner, group, and others permissions.
- Understand `r = 4`, `w = 2`, and `x = 1`.
- Recognize that `chmod +x script.sh` adds execute permission and `./script.sh` runs the script.
- Check the result with `ls -l` rather than assuming a permission change worked.
- Choose the minimum permissions needed; do not use broad permissions as a shortcut for fixing access errors.

#### 3. Change File Ownership with `chown` and `chgrp` 

**Goal:** Distinguish the file owner from its group owner and practise changing either one or both.

**Commands documented in Day 11:**

```bash
touch devops-file.txt
ls -l devops-file.txt
sudo chown tokyo devops-file.txt
sudo chown berlin devops-file.txt

touch team-notes.txt
sudo groupadd heist-team
sudo chgrp heist-team team-notes.txt
ls -l team-notes.txt

touch project-config.yaml
mkdir app-logs
sudo chown professor:heist-team project-config.yaml
sudo chown berlin:heist-team app-logs

mkdir -p heist-project/vault
mkdir -p heist-project/plans
touch heist-project/vault/gold.txt
touch heist-project/plans/strategy.conf
sudo groupadd planners
sudo chown -R professor:planners heist-project/
ls -lR heist-project/
```

**What I am revising:**

- `chown USER file` changes the owner.
- `chgrp GROUP file` changes the group owner.
- `chown USER:GROUP file` changes the owner and group together.
- `chown -R USER:GROUP directory/` applies ownership recursively to the directory tree.
- Use `ls -l` or `ls -lR` to verify the owner and group after a change.

**Safety:** Confirm the account names, group names, and target path before making changes. Recursive ownership changes can affect many files, so use them only when the whole tree should share the same ownership.

### Shell Scripting

#### 4. Text Processing with `grep`, `awk`, `sed`, `sort`, and `uniq` — Days 20–21

**Goal:** Find relevant log entries, extract fields, transform text, and count repeated messages using pipelines.

**Commands and patterns documented in my Day 20 solution and Day 21 cheat sheet:**

```bash
grep -Eic "ERROR|Failed" "$log_file" || true
grep -n "CRITICAL" "$log_file"
grep -i "error" "$log_file" | sort | uniq -c | sort -nr | head -5

awk '{print $1}' access.log
awk -F: '{print $1}' /etc/passwd

df / | awk 'NR==2 {print $5}' | tr -d '%'

sed 's/old/new/g' file.txt
sed '/ERROR/d' app.log

sort names.txt | uniq
sort names.txt | uniq -c
wc -l app.log
```

**How I use these commands:**

- `grep -Eic "ERROR|Failed"` counts case-insensitive matches for either pattern. `|| true` is used in the logged script so a no-match exit status does not stop that operation under strict-mode handling.
- `grep -n "CRITICAL"` searches for critical entries and includes their line numbers.
- `grep -i "error" ... | sort | uniq -c | sort -nr | head -5` finds repeated error lines, counts duplicates, sorts by count, and displays the first five.
- `awk '{print $1}'` extracts the first whitespace-separated field; `awk -F:` uses a colon delimiter for files such as `/etc/passwd`.
- `sed 's/old/new/g'` replaces matching text in the output; `sed '/ERROR/d'` filters out lines matching `ERROR` from the output. Without `-i`, these examples do not edit the original file in place.
- `sort names.txt | uniq` removes adjacent duplicate lines after sorting; `uniq -c` counts repeated adjacent lines.
- `wc -l app.log` counts the log's lines.

**What I am revising:**

- Choose the right command for searching, extracting, replacing, sorting, or counting text.
- Understand why `sort` is used before `uniq` when counting repeated lines.
- Read each stage of a pipeline and explain how its output becomes the next command's input.
- Keep variables quoted in scripts, and check the input file exists before processing it.

#### 5. Scheduling Scripts with `crontab` 

**Goal:** Inspect the current user's scheduled jobs and understand how the five cron fields determine when a script runs.

**Commands documented in Day 19:**

```bash
crontab -l
crontab -e
```

The Day 19 notes included these example entries:

```cron
0 2 * * * /path/to/log_rotation.sh /var/log/myapp
0 3 * * 0 /path/to/backup.sh /path/to/source /path/to/backups
*/5 * * * * /path/to/health_check.sh
0 1 * * * /path/to/maintenance.sh
```

**Cron field order:**

```text
minute  hour  day-of-month  month  day-of-week  command
```

**What I am revising:**

- Use `crontab -l` to inspect the current user's scheduled jobs.
- Use `crontab -e` to edit the current user's crontab.
- Read the five schedule fields before the command path.
- Use a valid absolute path and confirm that the script can run in cron's limited environment.
- Check the script's permissions, arguments, and output handling before scheduling it.

**Day 28 quick-fire example:** A daily schedule at 3 AM is `0 3 * * * /home/ubuntu/script.sh`. This is included for the Day 28 question; the documented Day 19 practice entries above include other schedules. Replace the example path with the real script path in the lab.

---

## Task 3: Quick-Fire Questions

Try answering from memory before reading each answer.

### 1. What does `chmod 755 script.sh` do?

- **Owner:** read, write, execute (`rwx`).
- **Group:** read and execute (`r-x`).
- **Others:** read and execute (`r-x`).

### 2. What is the difference between a process and a service?

A process is a running instance of a program. A service is a background workload or capability commonly managed by systemd; a service can involve one or more processes.

### 3. How do you find which process is using port 8080?

The repository practised `ss -tulpn`; filtering the output for the port is the Day 28 quick-fire example:

```bash
sudo ss -tulpn | grep 8080
```

Check the result and make sure it refers to the intended listening socket.

### 4. What does `set -euo pipefail` do in a Bash script?

- `-e` generally exits after an unhandled command failure, subject to Bash's conditional and compound-command rules.
- `-u` treats many uses of unset variables as errors.
- `-o pipefail` makes a pipeline return a failure status if a command in that pipeline fails.

These options help catch problems but do not replace input validation or explicit handling of expected errors.

### 5. What is the difference between `git reset --hard` and `git revert`?

`git reset --hard` moves the current branch reference and resets the index and working tree, potentially discarding local changes. `git revert` creates a new commit that reverses an earlier commit's changes. Revert is usually safer for shared work.

### 6. What branching strategy fits a team of five developers shipping weekly?

GitHub Flow is a practical starting point: short-lived feature branches, pull requests, review, checks, and integration into `main`. The team should adapt the workflow to its release process and testing requirements.

### 7. What does `git stash` do and when would you use it?

It temporarily stores uncommitted changes so work can switch context without creating an incomplete commit. Use `git stash list` to inspect saved entries and `git stash pop` to reapply the latest one; resolve conflicts if they occur.

### 8. How do you schedule a script to run every day at 3 AM?

Open the crontab with `crontab -e` and add the Day 28 quick-fire schedule, using the real absolute path to the script:

```cron
0 3 * * * /home/ubuntu/script.sh
```

This exact daily 3 AM schedule is included to answer the Day 28 question. Ensure the script is executable and remember that cron uses the system's configured timezone and a limited environment.

### 9. What is the difference between `git fetch` and `git pull`?

`git fetch` downloads remote updates and updates remote-tracking references without integrating them into the current branch. `git pull` fetches and then integrates changes, usually by merge or rebase depending on configuration and options.

### 10. What is LVM and why use it instead of regular partitions?

Logical Volume Management adds a flexible storage layer between physical devices and filesystems. Physical volumes contribute storage to a volume group, and logical volumes are allocated from that pool. LVM can make storage allocation and resizing more flexible, but it does not replace backups or careful disk identification.

---

## Task 4: Organize My Work

- [x] Review the documented day folders and the notes/scripts kept from Day 1 through Day 27.
- [x] Review `2026/day-21/shell_scripting_cheatsheet.md`.
- [x] Review `2026/day-22/Git-Practice/git-commands.md` and `2026/day-26/git-commands.md`.
- [x] Review the Day 27 profile README and repository organization.
- [ ] Confirm locally that all intended Day 1–27 changes are committed and pushed.
- [ ] Add this file to `2026/day-28/day-28-notes.md`, review the staged diff, and push the Day 28 submission.

Commands used in the existing Git practice and suitable for checking and submitting the revision:

```bash
git status
git diff
git add 2026/day-28/day-28-notes.md
git diff --staged
git commit -m "docs: add Day 28 revision notes"
git push
```

---

## Task 5: Teach It Back Linux File Permissions

- Linux permissions control who can **read**, **change**, or **execute** files and directories.
- There are three permission classes:
  - **Owner**
  - **Group**
  - **Others**
- The basic permission symbols are:
  - `r` → read
  - `w` → write
  - `x` → execute
- Numeric permissions use:
  - `4` → read
  - `2` → write
  - `1` → execute
- Example: `chmod 755 script.sh`
  - The owner gets full permissions (`rwx`).
  - The group and others get read and execute permissions (`r-x`).
- `chmod +x script.sh`, used in the shell cheat sheet, adds execute permission.
- Permissions and file ownership are different, so `chmod` does not replace `chown` or `chgrp`.

---

## Day 28 Summary

Day 28 connected the work documented across Days 1–27: DevOps and cloud basics, Linux administration, EC2 and Nginx deployment, users and permissions, LVM, networking, Bash scripting and automation, Git workflows, GitHub CLI, and developer profile organization.

The key lesson from this revision is to explain the purpose of a command, understand its likely result, and verify the outcome. Storage operations, recursive permission or ownership changes, firewall changes, repository deletion, and destructive Git commands require extra care.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
