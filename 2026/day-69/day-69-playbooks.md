# Day 69: Ansible playbooks and modules

Notes and playbooks from Day 69 of `#90DaysOfDevOps`. All six tasks were run from an Ubuntu control node against three Ubuntu EC2 instances (`web-server`, `app-server`, and `db-server`), so the playbooks use `apt` instead of `yum`, `mysql-client` instead of `mysql`, and `/var/www/html/index.html` as the Nginx web root.

```

`inventory.ini` (replace placeholders with active EC2 public IPs):

```ini
[web]
web-server ansible_host=<WEB_SERVER_PUBLIC_IP>

[app]
app-server ansible_host=<APP_SERVER_PUBLIC_IP>

[db]
db-server ansible_host=<DB_SERVER_PUBLIC_IP>

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/.ssh/id_ed25519
```

`ansible.cfg`:

```ini
[defaults]
inventory = ./inventory.ini
host_key_checking = True
```

## Task 1: First playbook (`install-nginx.yml`)

```yaml
---                                                          # YAML document start
- name: Install and start Nginx on web servers               # PLAY: maps hosts to tasks
  hosts: web                                                 # Target inventory group
  become: true                                               # Escalate privileges via sudo

  tasks:                                                     # Ordered list of tasks
    - name: Install Nginx                                    # TASK 1: package installation
      apt:                                                   # MODULE: Debian/Ubuntu package manager
        name: nginx                                          # Package name
        state: present                                       # Install only if absent
        update_cache: true                                   # Refresh APT index
        cache_valid_time: 3600                               # Skip refresh if updated within 1 hour

    - name: Start and enable Nginx                           # TASK 2: service management
      service:                                               # MODULE: init/systemd service control
        name: nginx
        state: started                                       # Ensure daemon is running
        enabled: true                                        # Start automatically on boot

    - name: Create custom index page                         # TASK 3: deploy web content
      copy:                                                  # MODULE: write content or copy files
        content: "<h1>Deployed by Ansible - TerraWeek Server</h1>\n"
        dest: /var/www/html/index.html
        owner: root
        group: root
        mode: '0644'
```

### Run and verify

```bash
# Validate YAML syntax first
ansible-playbook install-nginx.yml --syntax-check

# First run (applies changes)
ansible-playbook install-nginx.yml

# Second run (proves idempotency)
ansible-playbook install-nginx.yml

# Verify HTTP response (requires inbound TCP port 80 in Security Group)
curl http://<WEB_SERVER_PUBLIC_IP>
```

### Idempotency check

- First run installs Nginx, starts the service, and writes `index.html`, reporting `changed`.
- Second run reports `ok` on every task (`changed=0`) because the server already matches the playbook.
- Re-running the file leaves the working setup untouched.

## Task 2: Playbook structure and Q&A

| Keyword | Role |
|---|---|
| `---` | Marks the start of a YAML document |
| `name` | Label printed in terminal output |
| `hosts` | Inventory group or host the play targets |
| `become` | Runs tasks with `sudo` privileges |
| `tasks` | Ordered steps executed on the target hosts |
| `<module>` | Ansible module (`apt`, `service`, `copy`, etc.) that applies the change |

### Questions and answers

- **Play vs. task:** A play links an inventory group (like `web`) to a list of tasks and play settings. A task is one step inside that play calling a single module.
- **Multiple plays in one file:** Yes. A single playbook can run separate plays for `web`, `app`, and `db` servers in order.
- **`become: true` at play level vs. task level:** At the play level, every task runs with `sudo`. At the task level, only that specific task gets root privileges, keeping permissions tighter.
- **When a task fails:** Ansible stops running remaining tasks on the failed host. Healthy hosts continue unless `any_errors_fatal: true` is set. You can override this with `ignore_errors: true` or handle recovery with `block` and `rescue`.

## Task 3: Essential modules (`essential-modules.yml`)

Create `files/app.conf` on the control node first:

```bash
mkdir -p files
cat << 'EOF' > files/app.conf
APP_NAME=TerraWeek
APP_ENV=staging
APP_PORT=8080
EOF
```

`essential-modules.yml`:

```yaml
---
- name: Demonstrate essential modules across all nodes
  hosts: all
  become: true

  tasks:
    - name: Install baseline CLI packages
      apt:
        name:
          - git
          - curl
          - wget
          - tree
        state: present
        update_cache: true
        cache_valid_time: 3600

    - name: Copy application config to managed nodes
      copy:
        src: files/app.conf
        dest: /etc/app.conf
        owner: root
        group: root
        mode: '0644'

    - name: Create application directory
      file:
        path: /opt/myapp
        state: directory
        owner: ubuntu
        group: ubuntu
        mode: '0755'

    - name: Check disk usage
      command: df -h
      register: disk_output
      changed_when: false

    - name: Print disk usage
      debug:
        var: disk_output.stdout_lines

    - name: Count active processes using a pipe
      shell: ps aux | wc -l
      register: process_count
      changed_when: false

    - name: Display process count
      debug:
        msg: "Total processes: {{ process_count.stdout }}"

    - name: Set timezone variable in /etc/environment
      lineinfile:
        path: /etc/environment
        line: 'TZ=Asia/Kolkata'
        create: true

- name: Verify Nginx service on web tier
  hosts: web
  become: true

  tasks:
    - name: Ensure Nginx is running and enabled
      service:
        name: nginx
        state: started
        enabled: true
```

### Module reference

| Module | Function | Lab example |
|---|---|---|
| `apt` | Installs, upgrades, or removes Debian/Ubuntu packages | Installed `git`, `curl`, `wget`, `tree` |
| `service` | Starts, stops, restarts, or enables services | Kept `nginx` started and enabled |
| `copy` | Copies files or inline text to managed hosts | Deployed `files/app.conf` to `/etc/app.conf` |
| `file` | Manages directories, symlinks, ownership, and permissions | Created `/opt/myapp` (`0755`) |
| `command` | Runs binaries directly without a shell | Executed `df -h` |
| `shell` | Runs commands through `/bin/sh` with pipes and redirects | Executed `ps aux \| wc -l` |
| `lineinfile` | Adds, updates, or removes a single line in a file | Added `TZ=Asia/Kolkata` to `/etc/environment` |

### `command` vs. `shell`

- `command` runs a binary directly without a shell, so pipes (`|`), redirects (`>`), and `$ENV` expansion do not work. Use it by default because it avoids shell-injection risks.
- `shell` passes the command through `/bin/sh`. Use it only when you need pipes, redirects, wildcards, or shell variables.
- Add `changed_when: false` on read-only checks (`df -h`, `ps aux`) so repeated runs do not show false `changed` results.

## Task 4: Handlers (`nginx-config.yml`)

`files/nginx.conf`:

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 768;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        root /var/www/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
```

`nginx-config.yml`:

```yaml
---
- name: Manage Nginx configuration with handlers
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: true
        cache_valid_time: 3600

    - name: Deploy validated Nginx config
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'
        validate: '/usr/sbin/nginx -t -c %s'
      notify: Restart Nginx

    - name: Deploy custom index page with hostname
      copy:
        content: "<h1>Managed by Ansible</h1><p>Server: {{ inventory_hostname }}</p>\n"
        dest: /var/www/html/index.html
        owner: root
        group: root
        mode: '0644'

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

### First run vs. second run

- First run: `Deploy validated Nginx config` replaces `/etc/nginx/nginx.conf` and reports `changed`. That triggers `notify: Restart Nginx`, and the handler runs once after all tasks finish.
- Second run: the file checksum already matches, so the copy task reports `ok`. No notification fires, and Nginx stays up without a restart.

## Task 5: Dry run, diff, verbosity, and host targeting

| Flag | Command example | Purpose |
|---|---|---|
| `--check` (`-C`) | `ansible-playbook install-nginx.yml --check` | Dry-run mode; predicts changes without modifying hosts |
| `--diff` (`-D`) | `ansible-playbook nginx-config.yml --check --diff` | Shows line-by-line before/after diffs for file edits |
| `-v` / `-vv` / `-vvv` | `ansible-playbook install-nginx.yml -vvv` | Increases output detail from task results (`-v`) to SSH debugging (`-vvv`) |
| `--limit` | `ansible-playbook install-nginx.yml --limit web-server` | Restricts execution to specific hosts or subsets |
| `--list-hosts` | `ansible-playbook install-nginx.yml --list-hosts` | Prints targeted hosts without running tasks |
| `--list-tasks` | `ansible-playbook install-nginx.yml --list-tasks` | Lists every task that would run without running it |

### Why `--check --diff` matters in production

- `--check` blocks live edits while `--diff` shows the exact lines being added or removed in config files like `nginx.conf`.
- It exposes manual hotfixes left on a server before a playbook overwrites them.
- Limits to watch out for:
  - `command` and `shell` tasks are skipped in check mode unless `check_mode: false` is set.
  - Add `diff: false` or `no_log: true` on tasks handling credentials so secrets do not print to terminal or CI logs.
  - Pair `--check --diff` with `--limit <host>` on one server to keep output readable, and still test changes in staging first.

## Task 6: Multiple plays in one playbook (`multi-play.yml`)

```yaml
---
- name: Configure web servers
  hosts: web
  become: true
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: true
        cache_valid_time: 3600

    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: true

- name: Configure app servers
  hosts: app
  become: true
  tasks:
    - name: Install build dependencies
      apt:
        name:
          - gcc
          - make
        state: present
        update_cache: true
        cache_valid_time: 3600

    - name: Create app directory
      file:
        path: /opt/app
        state: directory
        mode: '0755'

- name: Configure database servers
  hosts: db
  become: true
  tasks:
    - name: Install MySQL client
      apt:
        name: mysql-client
        state: present
        update_cache: true
        cache_valid_time: 3600

    - name: Create data directory
      file:
        path: /var/lib/appdata
        state: directory
        mode: '0700'
```

### Verify host isolation

```bash
# Run all 3 plays
ansible-playbook multi-play.yml

# Verify Nginx exists only on web-server
ansible all -m command -a "which nginx"

# Verify build tools and /opt/app on app-server
ansible app -m shell -a "gcc --version | head -n 1 && ls -ld /opt/app"

# Verify MySQL client exists only on db-server
ansible all -m command -a "which mysql"
ansible db -b -m command -a "ls -ld /var/lib/appdata"
```

### Host group summary

| Group | Host | Configured state |
|---|---|---|
| `web` | `web-server` | Nginx installed, enabled, and running |
| `app` | `app-server` | `gcc` and `make` installed; `/opt/app` (`0755`) created |
| `db` | `db-server` | `mysql-client` installed; `/var/lib/appdata` (`0700`) created |

## Troubleshooting notes

- `Could not detect which major revision of dnf is in use` on Ubuntu: the playbook used the `yum` module on hosts with `pkg_mgr: apt`. Replace `yum:` with `apt:` and change `mysql` to `mysql-client` (or `default-mysql-client`).
- Stale APT cache or 404 package errors: set `update_cache: true` in `apt` tasks, or refresh the index with `ansible all -b -m apt -a "update_cache=yes"`.
- YAML syntax or indentation errors: use 2 spaces (no tabs) and validate with `ansible-playbook <file>.yml --syntax-check`.
- Permission denied on `/etc` or package tasks: add `become: true` at the play or task level.

## Key takeaways

- Playbooks declare the desired state of a server, and Ansible checks whether any change is needed.
- An idempotent playbook makes zero changes when run a second time on a converged host.
- Handlers keep services steady by restarting them only when a config file changes.
- Running `--syntax-check`, `--check --diff`, and `--limit` catches bad edits before they hit live servers.
- One multi-play file separates `web`, `app`, and `db` tasks cleanly in a single run.

## Screenshots checklist

- [ ] `install-nginx.yml` first run (`changed` tasks) and `curl` output showing the custom HTML page
- [ ] `install-nginx.yml` second run (`ok` tasks, `changed=0`)
- [ ] `nginx-config.yml` first run showing `RUNNING HANDLER [Restart Nginx]`
- [ ] `nginx-config.yml` second run with the handler skipped
- [ ] `multi-play.yml` full `PLAY RECAP` and `which mysql` succeeding only on `db-server`

---

**Challenge:** 90DaysOfDevOps -- Day 69
**Submission path:** `2026/day-69/day-69-playbooks.md`
**Tags:** `#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`
