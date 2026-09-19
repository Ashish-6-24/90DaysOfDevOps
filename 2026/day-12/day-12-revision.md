# 🐧 Day 12 – Revision (Days 01–11)

## 📌 Goal

Today was not about learning a new tool.

I went back through **Days 01–11**, reviewed my notes, and repeated a few commands to see what I still remembered.

The main goal was to make the basics stronger before moving ahead.

---

## 🧠 Mindset & Plan Review

When I started Day 01, my goal was to become a **DevOps Engineer**.

After 11 days of practice, that goal is still the same.

One thing I realized is that I need to get really comfortable with **Linux and troubleshooting first**. So for the next few days, I want to spend more time practicing instead of just reading.

---

## ⚙️ Processes & Services

From Days 04 and 05, I revised the basic troubleshooting flow.

### Commands I repeated

```bash
ps aux | head
```

This gave me a quick look at the running processes.

```bash
systemctl status ssh --no-pager
```

This showed me whether SSH was running properly.

```bash
journalctl -u ssh -n 20 --no-pager
```

This helped me look at the recent SSH logs.

### What I remembered

When a service has a problem, I should not immediately restart it.

First:

```text
Check → Find the clue → Then take action
```

---

## 📁 File Skills

I also refreshed some commands from Days 06, 10 and 11.

```bash
echo "Day 12 revision" >> notes.txt
```

Adds new text without removing the old content.

```bash
chmod 640 notes.txt
```

Changes the file permissions.

```bash
ls -l notes.txt
```

Lets me check the permissions, owner and group.

```bash
sudo chown $USER:$USER notes.txt
```

Changes the owner and group of the file.

---

## 📋 5 Commands I Would Check First

From my Day 03 cheat sheet, these are the commands I would most likely use during a basic incident:

| Command            | Why I would use it                |
| ------------------ | --------------------------------- |
| `systemctl status` | Check if a service is running     |
| `journalctl -u`    | Look for service-related errors   |
| `top`              | Check CPU, memory and processes   |
| `df -h`            | Check if the disk is getting full |
| `ls -l`            | Check permissions and ownership   |

These are simple commands, but they can tell me a lot about what is happening on a server.

---

## 👥 User & Group Check

From Day 09 and Day 11, I revised how users, groups and ownership work together.

```bash
id tokyo
```

Shows the user's ID and group membership.

```bash
ls -l notes.txt
```

Shows who owns the file, which group it belongs to, and its permissions.

The basic idea is still:

```text
User
  ↓
Group
  ↓
Permissions
  ↓
Access
```

---

# ✅ Mini Self-Check

### 1. Which 3 commands save me the most time right now?

**`systemctl status`** – quick service check.

**`journalctl -u`** – useful when I need to understand a service problem.

**`df -h`** – quick way to see if disk space is becoming an issue.

---

### 2. How do I check if a service is healthy?

I would start with:

```bash
systemctl status ssh
systemctl is-enabled ssh
journalctl -u ssh -n 50
```

That gives me the current status, boot setting and recent logs.

---

### 3. How do I safely change ownership and permissions?

First check:

```bash
ls -l app.conf
```

Then change them:

```bash
sudo chown appuser:developers app.conf
chmod 640 app.conf
```

Then check again:

```bash
ls -l app.conf
```

I want to keep this habit:

**Check → Change → Verify**

---

### 4. What will I improve in the next 3 days?

My focus will be:

* Practice Linux commands without depending on notes
* Improve troubleshooting step by step
* Start using Bash for small automation tasks
* Get more comfortable working on remote Linux servers

---

## 🎯 What I Learned From the First 11 Days

The biggest thing I learned is that Linux commands are not just commands to memorize.

They answer questions.

```text
Is the process running?   → ps / top
Is the service running?   → systemctl
Why did it fail?          → journalctl
Is the disk full?         → df / du
Is the network working?   → ss / ping / curl
Who owns this file?       → ls -l
Who can access it?        → chmod
Who owns it?              → chown / chgrp
```

That way of thinking is starting to make Linux much easier for me.

---

## ✅ Day 12 Completed

**Days 01–11 reviewed.
Important commands refreshed.
Ready for the next step. 🚀**

#90DaysOfDevOps
#DevOpsKaJosh
#TrainWithShubham
