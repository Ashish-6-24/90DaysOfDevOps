# 🐧 Day 2 – Linux Architecture, Processes & systemd
## 📌 Objective

Today I learned the basic architecture of Linux and how its different parts work together.

---
#  Linux Architecture
#### Linux Architecture is divided into 4 Layers they are : 
```text
Application
     ↓
User Space
     ↓
Linux Kernel
     ↓
Hardware
```
## 1. Kernel

The **Kernel is the heart or core part of Linux**.

It is the main part where the Linux system code runs and it communicates with the hardware.

The kernel mainly handles:

- Process Management
- Memory Management
- Files Management
- Devices Management
- Networking Management 

For example, when a program needs memory or wants to read a file, it asks the kernel to do it.

---

## 2. User Space

**User Space is where our normal programs run.**

For example:

- Git
- Python
- Docker
- Nginx
- Bash

Applications cannot access hardware directly. They communicate with the kernel through system calls.

---

## 3. Shell

The **Shell is a way to talk to Linux using commands**.

For example:

```bash
ls
```
When I type a command, the shell understands it and runs it for me.

Bash is one common shell in Linux.

## 4. systemd

`systemd` is the default init system in most Linux distributions.

It is the first process started by the kernel (**PID 1**) and is responsible for:

* Starting the operating system
* Managing services
* Restarting failed services
* Viewing system logs

Some useful commands:

```bash
systemctl status nginx : Checks whether Nginx is running.
systemctl start nginx : Starts Nginx.
systemctl stop nginx : Stops Nginx.
systemctl restart nginx : Restarts Nginx.
journalctl -u nginx : To check Nginx logs:
```

---
# ⚙️ Linux Processes
A **process** is simply a running program.

Every process has:

* PID (Process ID)
* Parent Process
* Memory usage
* CPU usage

### Common Process States

* Running (R)
* Sleeping (S)
* Stopped (T)
* Zombie (Z)

---
# 💻 Commands I Practiced Today

```bash
pwd             # Know the current directory
top             # Monitor system resources
systemctl       # Manage services
rm              # Removes files/directory
cat             # Shows file content
vim             # To Edit the Content inside the files and wq ( Saves changes and exits ) 
ps aux          # View running processes
```
---
# 📖 Key Takeaways

* The **Kernel** manages hardware and system resources.
* The **Shell** acts as a bridge between the user and the kernel.
* **systemd** is responsible for booting Linux and managing services.
* Every running application is a process with its own PID.
* Understanding these concepts will make Linux troubleshooting much easier.


---



