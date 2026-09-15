# Day 08: Cloud Deployment with Nginx

## 🎯 Objective
Today I worked on deploying a web server using AWS EC2. I set up an instance with Ubuntu as the operating system. Installed Nginx to serve web content. I used SSH to connect to the server and configure it properly. I also managed firewall rules to allow necessary traffic like HTTP and HTTPS. Checking Nginx logs helped me monitor how the server was handling requests. This whole process gave me hands-on experience with server operations, in a cloud environment.

---

# 🖥️ Environment

- **Cloud Platform:** AWS EC2
- **Operating System:** Ubuntu
- **Web Server:** Nginx
- **Access Method:** SSH
- **Firewall:** AWS Security Group + UFW

---
## 🚀 What I Did

### 1. Connected to EC2

```bash
ssh -i "devops-ai-powered.pem" ubuntu@<EC2-Public-IP>
```

Connected to my Ubuntu server through SSH.

### 2. Updated the Server

```bash
sudo apt update
```

Updated the available package information.

### 3. Installed Nginx

```bash
sudo apt install nginx -y
```

Installed Nginx on the EC2 instance.

### 4. Checked Nginx

```bash
systemctl status nginx
```

Checked whether the Nginx service was running.

### 5. Changed the Web Page

```bash
cd /var/www/html
sudo nano index.nginx-debian.html
```

Modified the default Nginx webpage.

I first faced a **Permission Denied** error because the web files are protected system files. Using `sudo` solved the issue.

### 6. Tested the Website

Opened the EC2 public IP in my browser:

```text
http://<EC2-Public-IP>
```

The Nginx page loaded successfully.

### 7. Collected Nginx Logs

```bash
cat /var/log/nginx/access.log > ~/nginx-logs.txt
```

Created a separate file containing the Nginx access logs.

### 8. Copied the Log to My Local Machine

```bash
scp -i "devops-ai-powered.pem" ubuntu@<EC2-Public-IP>:~/nginx-logs.txt .
```

I initially got an error because my private key was not in the current local folder. After moving to the correct folder, the file was downloaded successfully.

## 📚 What I Learned

- How to deploy Nginx on an AWS EC2 server.
- How SSH is used to manage remote Linux servers.
- Why `sudo` is needed for protected system files.
- Where Nginx access logs are stored.
- How `scp` can transfer files between a server and local machine.

# ❌ Challenges Faced

## 1. Permission Denied

While editing the Nginx webpage, I received a `Permission Denied` error.

The problem was that `/var/www/html` contains protected system files.

I solved it using:

```bash
sudo nano /var/www/html/index.nginx-debian.html
```

---

## 2. Website Was Not Opening

At one point, the website was not opening from the EC2 Public IP.

I checked Nginx:

```bash
sudo systemctl status nginx
```

Then checked port 80:

```bash
sudo ss -lntp | grep ':80'
```

I also checked UFW:

```bash
sudo ufw status
```

I made sure HTTP was allowed:

```bash
sudo ufw allow 80/tcp
```

I also checked the AWS Security Group and made sure port `80` was allowed.

After checking these layers, I tested the website again:

```text
http://<EC2-Public-IP>
```

The website was working.

---

## 3. Duplicate UFW Rules

While configuring UFW, I created some duplicate Nginx rules.

I checked them using:

```bash
sudo ufw status numbered
```

This showed the rules with numbers.

I could remove an unnecessary rule using:

```bash
sudo ufw delete <rule-number>
```

This helped me understand why it is better to keep firewall rules simple.

---

## 4. SCP Problem

When downloading `nginx-logs.txt`, my first `scp` command did not work.

I checked that the file existed on the EC2 server:

```bash
ls -lh /home/ubuntu/nginx-logs.txt
```

I also checked its full path:

```bash
realpath nginx-logs.txt
```

The result was:

```text
/home/ubuntu/nginx-logs.txt
```

I then made sure that I was running `scp` from my local machine and that my `.pem` key was available there.

---

# 🔍 Simple Troubleshooting Flow

Today I started understanding how I can troubleshoot a web server instead of just trying random commands.

The flow I practiced was:

```text
Website not working
        ↓
Check Nginx status
        ↓
Check port 80
        ↓
Check firewall
        ↓
Test Nginx configuration
        ↓
Check access log
        ↓
Check error log
        ↓
Check systemd journal
        ↓
Fix the problem
        ↓
Verify again
```

---

# 📁 Files Created

- `day-08-cloud-deployment.md`
- `nginx-logs.txt`


---

# 📸 Screenshots Captured

- SSH connection to the EC2 instance
- Nginx service running
- Nginx webpage opened using the EC2 Public IP
- Nginx access logs
- Nginx systemd journal logs
- Downloaded `nginx-logs.txt`

---

# 📚 What I Learned

- How to connect to an AWS EC2 server using SSH.
- How to install and manage Nginx.
- How to serve a webpage from a cloud server.
- How Linux permissions affect system files.
- How AWS Security Groups and UFW control network access.
- How to check Nginx access and error logs.
- How to use `journalctl` to check service events.
- How to start, stop, restart and reload Nginx.
- How to transfer files using `scp`.

---

# 💭 What I Understood

The biggest thing I understood today was that deploying a website is not only about making the webpage appear in the browser.

There are different parts working together:

```text
AWS
 ↓
Ubuntu
 ↓
Firewall
 ↓
Nginx
 ↓
Website
 ↓
Logs
```

When something goes wrong, I can check each part one by one. It is more about understanding what is happening and knowing where to look next.

---

# ✅ Conclusion

Today I deployed Nginx on an AWS EC2 instance and served my own webpage from the cloud.

I also practiced checking the Nginx service, working with permissions, checking port 80, configuring the firewall, viewing real HTTP requests, generating service logs, and downloading log files using SCP.

The troubleshooting flow that made the most sense to me was:

```text
Observe → Check → Understand → Fix → Verify
```

This was a small step, but it helped me understand how a real web server is managed on a cloud machine.
