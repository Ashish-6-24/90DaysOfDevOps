# Day 27 – GitHub Profile Makeover: Building My Developer Identity

## 📌 Overview

Day 27 focused on turning my GitHub account into a more structured and professional technical portfolio.

Instead of treating GitHub only as a place to store repositories, I worked on improving how my technical work is presented so that a recruiter, hiring manager, or engineer can quickly understand my current direction, hands-on work, and areas of development.

The main focus was:

- Reviewing my existing GitHub profile from an external visitor's perspective
- Improving my profile README
- Clarifying my DevOps and Cloud career direction
- Separating learning work from reusable technical resources
- Creating dedicated repositories for shell scripts and DevOps notes
- Improving repository organization and documentation
- Reviewing repositories for stronger portfolio visibility
- Checking the profile for unnecessary visual elements and unclear signals
- Maintaining transparency around learning repositories and external source projects

---

## ✅ Task 1 – Review My Existing GitHub Profile

I reviewed my profile as if I were a recruiter or hiring manager seeing it for the first time.

### What I Found

My profile already communicated an interest in DevOps, Cloud, infrastructure, and automation, but there was room to make the technical story clearer.

The existing profile contained several visual elements, technology icons, statistics, and learning references. These made the profile visually active, but they did not always provide the strongest evidence of my engineering ability.

### Main Improvements Identified

- Make my DevOps career direction immediately clear
- Reduce unnecessary profile widgets and decorative elements
- Separate technologies I am actively practicing from technologies I am only exploring
- Give more attention to hands-on work and troubleshooting
- Improve repository descriptions and organization
- Make important projects easier to discover
- Present my software-development background as part of my engineering progression
- Keep my claims aligned with evidence that exists in my repositories

---

## ✅ Task 2 – Build My GitHub Profile README

I created the special GitHub profile repository:

```text
Ashish-6-24/Ashish-6-24
```

This repository contains the README displayed directly on my GitHub profile.

### Profile README Structure

My updated profile README focuses on:

- Professional introduction
- Early-career DevOps positioning
- Cloud, infrastructure, and automation interests
- Current learning focus
- Selected technical work
- 90 Days of DevOps progress
- Shell scripting work
- DevOps notes and references
- Previous software-development projects
- Target roles
- Contact and LinkedIn information

### Career Positioning

My profile is positioned around:

```text
Early-Career DevOps Engineer
Cloud
Infrastructure
Automation
Reliability
```

### Current Technical Focus

```text
Linux
Bash
Git
GitHub
Networking
Python
Docker
AWS
Terraform
GitHub Actions
Kubernetes
Observability
```

I distinguish between technologies I am actively practicing and technologies I am still developing rather than presenting every technology as an established expertise.

---

## ✅ Task 3 – Organize My Repositories

I reorganized my work so that different repositories have clearer purposes.

### 1. 90 Days of DevOps

My `90DaysOfDevOps` repository remains the chronological record of my hands-on DevOps learning journey.

```text
90DaysOfDevOps/
├── 2026/
│   ├── day-01/
│   ├── day-02/
│   ├── ...
│   └── day-27/
└── README.md
```

Repository:

```text
https://github.com/Ashish-6-24/90DaysOfDevOps
```

The repository contains my daily learning work, experiments, documentation, and troubleshooting exercises.

### Repository Transparency

This repository is a fork of the original:

```text
TrainWithShubham/90DaysOfDevOps
```

I keep that relationship transparent while using the repository to document my own learning, practice, experiments, troubleshooting, and notes.

This distinction is important for maintaining an authentic portfolio.

---

### 2. Shell Scripts

I created a dedicated repository for Bash and shell scripting work from my DevOps learning.

```text
shell-scripts/
├── basics/
├── loops-and-arguments/
├── functions-and-system/
├── server-maintenance/
├── log-analysis/
└── README.md
```

Repository:

```text
https://github.com/Ashish-6-24/shell-scripts
```

### Areas Covered

```text
Bash fundamentals
User input
Conditions
Loops
Command-line arguments
Functions
Strict mode
System checks
Backups
Log rotation
Log analysis
Error reporting
```

The repository is organized by technical purpose rather than only by day number so that individual scripts are easier to find and reuse.

---

### 3. DevOps Notes

I created a separate repository for reusable DevOps knowledge, references, cheat sheets, and command documentation.

```text
devops-notes/
├── shell-scripting/
├── git/
├── linux/
├── python/
├── networking/
├── docker/
├── aws/
├── terraform/
├── kubernetes/
└── README.md
```

Repository:

```text
https://github.com/Ashish-6-24/devops-notes
```

### Current Notes Being Organized

```text
Shell Scripting Cheat Sheet
Git Commands
GitHub CLI Commands
Linux References
Python References
Networking References
Docker References
AWS References
Terraform References
Kubernetes References
```

The purpose of this repository is different from `90DaysOfDevOps`:

```text
90DaysOfDevOps → chronological learning record

devops-notes → reusable technical knowledge base
```

---

## ✅ Task 4 – Improve Repository Visibility

I reviewed the repositories on my account and considered which projects best represent my current engineering direction.

### Portfolio Priorities

The repositories I want visitors to understand first are:

```text
90DaysOfDevOps
shell-scripts
devops-notes
KhelSetu Platform
Multi-Tenant Application
Future DevOps Infrastructure Projects
```

The purpose is to create a portfolio that shows both:

```text
Software Engineering Background
+
DevOps / Cloud Engineering Direction
```

### Why This Combination Matters

My earlier software-development work provides application-development experience, while my current DevOps work shows the direction I am building toward.

This creates a progression:

```text
Application Development
        ↓
Linux & Systems
        ↓
Bash & Automation
        ↓
Git & GitHub
        ↓
Cloud & Infrastructure
        ↓
CI/CD
        ↓
Kubernetes & Reliability
```

---

## ✅ Task 5 – Repository Cleanup and Authenticity

I also reviewed my repositories from a portfolio perspective.

### Cleanup Principles

For repositories that matter to my career direction, I am following these standards:

- Use descriptive repository names
- Keep repository descriptions concise and meaningful
- Provide a useful README
- Organize files into logical directories
- Avoid unnecessary duplicate repositories
- Keep temporary practice projects from dominating the portfolio
- Preserve useful historical work without presenting everything as a primary project

### Authenticity Principles

I want my GitHub profile to accurately represent my current experience.

Therefore:

```text
Learning ≠ Expertise

Practice ≠ Production Experience

Technology Listed ≠ Proven Skill
```

I will only describe work based on what I have actually practiced, built, tested, or documented.

I will also avoid inventing:

```text
Performance metrics
Production incidents
Enterprise experience
Team ownership
Infrastructure scale
Reliability improvements
```

unless those results are supported by real work.

---

## 🔐 Security Review

As part of repository cleanup, I reviewed the importance of keeping sensitive information outside public repositories.

Examples of information that should never be committed:

```text
.env
*.pem
*.key
AWS credentials
API keys
Access tokens
Database passwords
GitHub tokens
Cloud credentials
Terraform secrets
```

Typical protections include:

```gitignore
.env
.env.*
*.pem
*.key
.terraform/
terraform.tfstate
terraform.tfstate.*
node_modules/
__pycache__/
.venv/
```

The goal is to make repository organization and security part of my normal engineering workflow rather than an afterthought.

---

## ✅ Task 6 – Before & After Comparison

I compared my GitHub profile before and after the makeover.

### Before

The original profile contained more decorative elements, technology icons, statistics, and general learning information.

```text
Add screenshot here:

./images/github-profile-before.png
```

### After

The updated profile focuses more heavily on:

```text
Who I am
What I am building
What I am currently learning
What I have actually practiced
Where my technical evidence is
What roles I am targeting
```

```text
Add screenshot here:

./images/github-profile-after.png
```

### Day 27 Folder

```text
day-27/
├── images/
│   ├── github-profile-before.png
│   └── github-profile-after.png
├── README.md
└── day-27-notes.md
```

---

## 🚀 Three Major Improvements

### 1. Clearer DevOps Positioning

I changed the profile from a general technology-focused presentation toward a more specific engineering identity:

```text
Early-Career DevOps Engineer
Cloud
Infrastructure
Automation
Reliability
```

This makes my intended career direction easier to understand.

---

### 2. Better Separation of Technical Work

Instead of keeping every type of learning material in one place, I separated my repositories based on purpose:

```text
90DaysOfDevOps
→ daily learning and experiments

shell-scripts
→ reusable Bash and automation work

devops-notes
→ commands, cheat sheets, and references
```

This makes the portfolio easier to navigate and gives each repository a clear role.

---

### 3. Stronger Evidence-Based Presentation

I shifted the focus away from simply displaying technology names.

My profile now emphasizes:

```text
Build
Break
Troubleshoot
Document
Improve
Automate
```

For example, my Git learning work includes reproducing merge and rebase conflicts, practicing reset/revert recovery, working with stash and cherry-pick, and diagnosing a GitHub Actions CLI issue involving workflow IDs and run IDs.

This provides more meaningful evidence of how I learn and troubleshoot technical problems.

---

## 🧰 Technical Areas Represented

| Category | Current Focus |
|---|---|
| Operating Systems | Linux |
| Scripting | Bash, Python |
| Version Control | Git, GitHub, GitHub CLI |
| Networking | Networking fundamentals and troubleshooting |
| Containers | Docker |
| Cloud | AWS |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Orchestration | Kubernetes |
| Observability | Learning and building practical experience |
| Application Engineering | React, TypeScript, React Native, Expo, Node.js, SQL |

---

## 📚 What I Learned

This makeover helped me understand that a technical portfolio is not simply a list of technologies.

A strong GitHub profile should make it easy for another engineer to determine:

```text
Who is this person?
What are they working toward?
What have they actually built?
What problems have they solved?
How do they document their work?
Where can I verify their claims?
```

I also learned that organization and authenticity are part of technical branding.

A smaller number of clearly explained projects is more useful than a large collection of poorly described repositories.

---

## 🎯 Final Result

After completing the makeover, my GitHub profile is designed to be:

- DevOps-focused
- Easier to scan
- More technically organized
- Evidence-oriented
- Transparent about learning work
- Easier for recruiters and engineers to navigate
- Better aligned with my target career direction

The goal is not to make my GitHub look artificially impressive.

The goal is to make the real work easier to understand.

---

## 💼 Target Roles

I am currently positioning my profile toward:

- Associate DevOps Engineer
- DevOps Engineer I
- Entry-Level Site Reliability Engineer
- Cloud Support Engineer
- Build & Release Engineer

---

## 🔗 My GitHub

```text
https://github.com/Ashish-6-24
```

---

## ✅ Day 27 Completed

**GitHub Profile Makeover — Completed ✅**

> My GitHub profile is becoming a technical portfolio that shows not only what I am learning, but also how I build, troubleshoot, document, and improve my engineering skills.
