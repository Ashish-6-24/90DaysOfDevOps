# Day 70: Variables, facts, conditionals, and loops in Ansible

## Overview

In Day 70 of the 90DaysOfDevOps challenge, I updated my Ansible playbooks to adapt to different server roles and environments. Web servers need Nginx, database servers need MySQL, and production hosts need different settings than development hosts. Variables, facts, conditionals, and loops handle those differences without duplicating playbooks.

## Task 1: Variables in playbooks

I created `variables-demo.yml` with reusable parameters in a `vars:` block:

- `app_name`: `terraweek-app`
- `app_port`: `8080`
- `app_dir`: `"/opt/{{ app_name }}"`
- `packages`: `git`, `curl`, and `wget`

Then I overrode the playbook variables from the command line:

```bash
ansible-playbook variables-demo.yml -e "app_name=my-custom-app app_port=9090"
```

Passing `-e` replaced `app_name` and `app_port` at runtime, and `app_dir` resolved to `/opt/my-custom-app` without editing the playbook file.

## Task 2: Group variables and host variables

I moved configuration out of the playbook into `group_vars/` and `host_vars/`:

- `group_vars/all.yml`: Sets `ntp_server`, `app_env`, and `common_packages` (`vim`, `htop`, `tree`) for every host in the inventory.
- `group_vars/web.yml`: Sets `http_port` to 80, `max_connections` to 1000, and `web_packages` to `nginx` for the `web` group.
- `group_vars/db.yml`: Sets `db_port` to 3306 and `db_packages` to `mysql-server` for the `db` group.
- `host_vars/web-server.yml`: Overrides `max_connections` to 2000 and sets a `custom_message` for `web-server` only.

### Variable precedence

When the same variable is defined in multiple places, Ansible resolves conflicts from lowest to highest priority:

1. Role defaults
2. `group_vars/all`
3. `group_vars/<group>` (such as `max_connections: 1000` in `web.yml`)
4. `host_vars/<host>` (such as `max_connections: 2000` in `web-server.yml`)
5. Playbook `vars:`
6. Task `vars:`
7. Extra variables passed via `-e`

## Task 3: Ansible facts

Ansible collects system metadata from managed nodes at the start of a play through the `setup` module. I inspected facts on my EC2 instances with `ansible web-server -m setup` and filtered specific values using `-a "filter=..."`.

Five facts I would use in real playbooks:

1. `ansible_os_family`: Picks the right package manager (`apt` on Debian/Ubuntu vs `yum` or `dnf` on RedHat/Amazon Linux) and service names.
2. `ansible_memtotal_mb`: Verifies available RAM before running memory-heavy services or calculates buffer sizes dynamically.
3. `ansible_default_ipv4.address`: Populates the host's primary private IP address in web server, proxy, or firewall configurations.
4. `ansible_processor_vcpus`: Sets worker counts, such as Nginx `worker_processes`, to match available CPU cores.
5. `ansible_mounts`: Checks free disk space on `/` or `/var` before running backups or pulling large container images.

## Task 4: Conditionals with `when`

In `conditional-demo.yml`, I used `when:` to control which tasks run on each host:

- Installed Nginx only when `'web' in group_names`.
- Installed MySQL only when `'db' in group_names`.
- Printed a memory warning when `ansible_memtotal_mb < 1024`.
- Checked `ansible_distribution` to separate Amazon Linux tasks from Ubuntu tasks.
- Restricted production tasks with `when: app_env == "production"`.
- Combined multiple rules using YAML list items for `AND` logic and `or` for `OR` logic.

Hosts that did not match a condition reported `skipping` rather than failing or making unwanted changes.

<!-- Add your screenshot showing skipped vs executed tasks -->
![Conditional tasks output](./screenshots/conditional-demo.png)

## Task 5: Loops

In `loops-demo.yml`, I used `loop:` with `{{ item }}` to repeat tasks across lists and dictionaries:

- Created the `deploy`, `monitor`, and `appuser` accounts and assigned their groups.
- Created `/opt/app/logs`, `/opt/app/config`, `/opt/app/data`, and `/opt/app/tmp` with mode `0755`.
- Installed `git`, `curl`, `unzip`, and `jq`.
- Printed each created user and group with `debug`.

On Ubuntu EC2 instances, the `wheel` group did not exist, so I changed the sudo user entries to use the `sudo` group.

### `loop` vs. `with_items`

`loop` is the standard syntax introduced in Ansible 2.5 and replaces older `with_*` lookup loops such as `with_items`. Unlike `with_items`, `loop` keeps nested list structures intact unless you explicitly flatten them with a filter, which prevents unexpected list expansion.

<!-- Add your screenshot showing multiple loop iterations -->
![Loop iterations output](./screenshots/loops-demo.png)

## Task 6: `register`, `debug`, and server health report

In `server-report.yml`, I combined facts, shell commands, conditionals, and `register` to collect host status and write a report file:

- Ran `df -h /`, `free -m`, and `systemctl list-units --type=service --state=running | head -20`, saving each result with `register`.
- Printed hostname, OS, IP, total RAM, root disk usage (`disk_result.stdout_lines[1]`), and running service count via `debug`.
- Added a low-disk alert condition using `when:`.
- Wrote the report to `/tmp/server-report-{{ inventory_hostname }}.txt` on each managed node using `copy` and `content:`.

Sample output from `/tmp/server-report-web-server.txt`:

```text
Server: web-server
OS: Ubuntu 24.04
IP: 172.31.xx.xx
RAM: 966MB
Disk:
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G  3.4G   26G  12% /
Checked at: 2026-11-27T14:00:00Z
```

## Summary of concepts

| Concept | Purpose |
| :--- | :--- |
| Playbook `vars` | Stores reusable values inside a playbook |
| `group_vars` | Shares configuration across an inventory group |
| `host_vars` | Overrides settings for an individual server |
| Ansible facts | Gathers OS, hardware, and network data automatically |
| `when` conditionals | Runs or skips tasks based on host facts, groups, or variables |
| `loop` | Repeats a task over a list of strings or dictionaries |
| `register` | Saves task output for use in later tasks or conditionals |
| `debug` | Prints variables, facts, or messages during playbook runs |

## References

- [Ansible Variables](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html)
- [Ansible Facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html)
- [Ansible Conditionals](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)
- [Ansible Loops](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_loops.html)

## Challenge

90DaysOfDevOps – Day 70 

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham #Ansible #DevOps #Automation #AWS #Linux
