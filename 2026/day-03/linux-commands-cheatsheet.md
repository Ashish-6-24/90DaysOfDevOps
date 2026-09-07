# 🐧Day 03 – Linux Commands Practice

**Goal:** Build Linux command confidence  focus on process management, filesystem, networking troubleshooting.
* * *
## Types of Key Pairs in the AWS
1. RSA ( Default Type )
2. ED25519 ( Doesnot Support for Windows Instances and only available in .pem format  )

**It have two private key file format they are :**
1) .pem ( Compatible Key for the Linux, MacOS or waste distrubutions )
2) .ppk ( Compatible Key for the Windows Operating System )
  
* * *
### Terminal 
Terminal is an application that allows you to run the shell commands . 
* * *
## File Management Commands 

| Command                       | What it does                                                                                                         |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `pwd`                         | Show your current working directory **“Where am I?”**                                                              |
| `ls`                          | List files in the current directory; `-l` shows details such as permissions, owner, size; `-a` includes hidden files |
| `chgrp GROUP file`            | Change the group ownership of a file or directory                                                                    |
| `mkdir -p parent/child`       | Create `parent` and, inside it, `child`; `-p` creates missing parent directories                                     |
| `rm file.txt`                 | Delete a file; `rm -rf dir/` recursively deletes a directory and its contents                                        |
| `cp SRC DEST`                 | Copy a file; `cp -r dir1 dir2` copies a directory and its contents                                                   |
| `mv SRC DEST`                 | Move a file/directory or rename it                                                                                   |
| `cat file.txt`                | Print file contents directly to the terminal                                                                         |
| `chmod 755 script.sh`         | Set permissions: owner `rwx`, group `r-x`, others `r-x` (`4=read`, `2=write`, `1=execute`)                           |
| `grep -r "Hello" .`           | Search for `Hello` in the current directory and subdirectories; use `wc -l` to count matching lines                  |
| `find /path -name "file.txt"` | Search for files or directories by name, type, size, time, etc.                                                      |
| `chown user:group file`       | Change the file's owner and group; `-c` reports only when a change is made                                           |
| `tail -n 50 file.log`         | Show the last 50 lines; `-f` continuously watches for new log entries                                                |
| `df -h`                       | Show filesystem disk usage in human-readable format (`K`, `M`, `G`)                                                  |
| `du -sh folder/`              | Show the total size of a folder in human-readable format (`K`, `M`, `G`)                                             |
| `rsync -avz SRC/ DEST/`       | Transfer and synchronize files/directories, commonly between servers. eg: rsync -avz /app/ ubuntu@server:/backup/app/                                                |
* * *
## Process Management Commands
| Command        | What it does                                                                                                                                                                |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ps aux`       | List running processes with CPU and memory information; useful for resource troubleshooting                                                                                 |
| `ps -ef`       | List processes with detailed information, including **PPID (Parent Process ID)** to see which process started another process                                               |
| `htop`          | Show a real-time view of CPU, memory, load, and running processes                                                                                                           |
| `kill -9 2343` | Force-kill process with PID `2343`. Signal reference: `15` graceful stop (default), `9` force kill (can't be ignored), `2` interrupt (like Ctrl+C), `19` pause, `18` resume |
* * *
## Network Troubleshooting 
| Command                   | What it does                                                                                                                                                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ip addr`                 | Displays information for all active and inactive network interfaces on your system                                                                            |
| `ip route`                | Show the routing table and default gateway                                                                                                                    |
| `ping google.com`         | Test connectivity to a host                                                                                                                                   |
| `ss -tulnp`               | Show listening TCP/UDP ports and the processes using them. For example: `tcp 0.0.0.0:80 LISTEN 1234/nginx` means **nginx (PID 1234) is listening on port 80** |
| `dig google.com`          | Query DNS and inspect how a domain resolves to IP addresses                                                                                                   |
| `curl https://google.com` | Test web endpoints, inspect HTTP headers with `-I`, and verify API responses                                                                                  |





