## Day 07 – Linux File System Hierarchy & Scenario-Based Practice

**Goal:** To understand where things live in Linux and practice troubleshooting like a DevOps engineer.

Divided into two parts:

- Linux File System Hierarchy (the most important directories)
- Practice solving real-world scenarios step by step
* * *
## Part 1: File System Hierarchy
* * *
**Objective**: To understand where different types of data live in Linux and why those locations matter.

### `/` (root)
Everything you can reach through the normal Linux filesystem tree starts somewhere below it.
```
ls -l /
```
**Observation**: I have seen the directories such as bin , etc , home; this is the  top of the Linux filesystem hierarchy because it is the root node of the linux pathname hierarchy. bin, etc, home, var, etc are directories that are directly under it.
* * *
### `/home`
Contains user directories.

```
ls -l /home
```
**Observation**: I saw that there are separate directories for users like ubuntu and Ram . Along with number of hardlink pointing to the directory , owner-name , groups-name , directory size . Therefore /home is used to stored personal directories of users.
* * *
### `/etc`
Central location for system-wide configuration files and configuration directories.
```
ls -l /etc
```
**Observation**: I have seen there files and directories related to the operating system, networking, users , SSH, services and installed applications . I would use it when Linux system or service is not behaving as expected and you need to check its settings (eg: `ls /etc/nginx` , `ls /etc/ssh`)
* * *
### `/var/log`
Contains system logs.

```
ls -l /var/log
```
**Observation**: When I looked in /var/log I saw log files created by the system and its services. This showed me that logs are not just files to read; logs are evidence when something goes wrong.  I can use logs to understand failures find errors connected events with problems and troubleshoot using the evidence instead of just guessing . 
* * *
### `/tmp`
Temporary files directory.
```
ls -l /tmp
```
**Observation:** I came across some files and folders that the system and applications created. This made me realize that Linux needs a shared place for short-lived data. It can be helpful when fixing problems or troublshooting especially when looking for unexpected disk usage or temporary applications files . 
* * *
### `/root`
Home directory of the root user- not the same as / (root filesystem).
/       → root of the whole filesystem

/root   → home directory of the root user
```
ls -l /root
```
**Observation:** It can contain administrator-level files and scripts which is normally protected . It can helps me to work safetly with previleged files ,user onwership , permissions and server administration . 
* * *
### `/bin`
A binary is program that the computer can execute.
```
ls -l /bin
```
**Observation**: Commands like `ls`, `cp`, `mv`, `cat`. Stores the core commands required for normal system operation and needed just to boot the system. 
* * *
### `/usr/bin`
Contains a large number of user-space executable programs (non-critical, non-boot commands).
```
ls -l /usr/bin
```
**Observation:** Commands like `git`, `python`, `curl`. Stores most user-installed or system-installed applications.
* * *
### `/opt`
Used for optional or third-party software .
```
ls -l /opt
```
**Observation:** Folders for custom apps (e.g : google) . This helps me find software that I deployed manaull then I can track how that software connects to its configuration, service definition, permissions, and logs.
* * *
## Extra Practice 
Find the largest log file in `/var/log`:
```
du -sh /var/log/* 2>/dev/null | sort -h | tail -5
```
**Observation**: `/var/log/journal` was the largest at 57 MB — consuming the most space.
 
 **Look at a config file in `/etc`:**
 ```
cat /etc/hostname
```
**Output:** Ashish - Host name of the machine . 

**Check the home directory:**
```
ls -la ~
```
**Observation:** Lists all files, including hidden ones.
* * *
## Part 2: Scenario-Based Practice

### Scenario 1: Service Not Starting
A web application service called `myapp` failed to start after a server reboot. What commands would you run to diagnose the issue?

1. Check whether the service is running:
   ```
   systemctl status myapp
   ```
**Why:** First, I confirm whether the service is actually stopped or failed and look for any immediate error message.

2. Check the logs:
   ```
   journalctl -u myapp -n 50
   ```
**Why:** The logs give me evidence about why the service failed instead of making a guess.

3. Since it's not starting after reboot, check whether it's enabled to auto-start on boot:
   ```
   systemctl is-enabled myapp
   ```
**Why:** Since the problem appeared after reboot, I check whether myapp is configured to start automatically.

4. If not enabled, enable it:
   ```
   systemctl enable myapp
   ```
**Why**: If it is disabled, I enable it so systemd can start the service during future server boots.

5. Restart the service:
   ```
   systemctl restart myapp
   ```
**Why:** After fixing the issue, I restart the service to apply the change and bring the application back up.

6. Verify the result
     ```
   systemctl status myapp
---

---

### Scenario 2: High CPU Usage
Your manager reports the application server is slow. You SSH in what commands identify which process is using high CPU?

1. Get a live view of all processes:
   ```
   top
   ```
**Why:** I first get a live view of the server and see which processes are using the most CPU. 

2. If the output is too messy to parse, sort directly by CPU usage:
   ```
   ps aux --sort=-%cpu | head -10
   ```
**Why:** This quickly shows me the top CPU-consuming processes so I can focus on the main problem.

3. Identify the process
  ```
PID    %CPU    COMMAND
1234   95.0    myapp
  ```

**Why:** I note the PID and process name so I know exactly what is causing the high CPU usage.

4. Investigate before killing
  ```
ps -p 1234 -f
  ```

**Why:** Before stopping anything, I first understand what the process is and what started it.

5. Stop it only when appropriate

  ```kill 1234
  ```

**Why**: I stop the process only after understanding the impact, rather than killing a process blindly.

---
## Scenario 3: Finding Service Logs

Problem: A developer asks: "Where are the logs for the docker service?" It's managed by systemd.

1. Check the service
  ```   
systemctl status docker
  ```

**Why:** I first confirm that Docker is managed by systemd and check its current state.

2. Check the recent logs
  ```
journalctl -u docker -n 50
  ```

**Why:** I use the systemd journal to see the latest Docker events and errors.

3. Watch the logs live
  ```
journalctl -u docker -f
  ```

**Why:** I use -f when I need to watch new Docker log messages as they happen.
* * *
### Scenario 4: File Permissions Issue
*A script at `/home/user/backup.sh` won't execute. Running `./backup.sh` returns "Permission denied."*

1. Grant execute permission:
   ```
   chmod +x backup.sh
   ```
2. Verify the permission change:
   ```
   ls -l /home/user/backup.sh
   ```

Before: `-rw-r--r--` → After: `-rwxr-xr-x` — note the added `x`, confirming execute permission is now granted.









