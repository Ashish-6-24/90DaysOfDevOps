# Day 68: Introduction to Ansible and inventory setup

## 1. Introduction to Ansible

Ansible is an open-source automation and configuration-management tool. It can install software, configure services, manage users, copy files, deploy applications, and keep servers in a defined state.

Ansible is agentless for Linux hosts. The control node connects to managed nodes over SSH and runs tasks remotely. The managed nodes do not need an Ansible agent. They do need a working SSH account and a supported Python interpreter for most Ansible modules.

### Why configuration management is needed

Configuration management helps keep servers consistent as an environment grows. It can be used to:

- Install and update software packages.
- Create users and manage permissions.
- Configure and restart services.
- Deploy application files.
- Apply operating-system settings.
- Repeat the same configuration across several servers.

Without automation, an administrator has to repeat these steps manually on each server. That takes longer and makes configuration drift more likely.

### Ansible compared with other configuration-management tools

| Tool | Common architecture | How it communicates |
|---|---|---|
| Ansible | Agentless for Linux managed nodes | SSH; WinRM is commonly used for Windows |
| Chef | Client/server | Chef Infra Client communicates with the Chef server |
| Puppet | Usually agent-based | Puppet agent communicates with a Puppet server |
| Salt | Master/minion or agentless SSH mode | Salt Minion, or SSH when using Salt SSH |

Ansible uses YAML playbooks and remote connections. Chef, Puppet, and Salt have different client, server, and execution models; the best fit depends on the environment and the team's operating model.

## 2. Ansible architecture

The lab uses the following components:

### Control node

The control node is the machine where Ansible is installed and where commands and playbooks are run. In this lab, an Ubuntu EC2 instance is used as the control node.

### Managed nodes

Managed nodes are the remote servers Ansible configures. The lab uses three EC2 instances with web, application, and database roles. The environment includes Ubuntu and Red Hat Enterprise Linux (RHEL) images, so each host must use the correct SSH login name.

### Inventory

The inventory lists the managed hosts and organizes them into groups. It can also store connection details such as the host address and SSH user.

### Modules

Modules are units of work that Ansible runs on managed nodes. Examples include:

- `ping`: check Ansible connectivity and remote Python execution.
- `apt`: manage packages on Debian and Ubuntu.
- `dnf` or `yum`: manage packages on supported Red Hat-family systems.
- `package`: use the package manager detected on the target host.
- `copy`: copy a file to a managed node.
- `command`: run a command without shell parsing.
- `service`: manage services.

### Playbooks

Playbooks are YAML files that describe tasks and the hosts on which Ansible should run them. They make multi-step automation easier to review, reuse, and run again.

### Architecture flow

```text
                    CONTROL NODE
                 Ubuntu EC2 instance
                         |
                    Ansible CLI
                         |
                      Inventory
                         |
                    SSH (TCP 22)
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
      WEB SERVER     APP SERVER      DB SERVER
       EC2 node       EC2 node       EC2 node
          |              |              |
          +--------------+--------------+
                         |
                  Ansible modules
                         |
                Configured server state
```

## 3. AWS lab environment

The lab design has one Ubuntu EC2 control node and three EC2 managed nodes. The managed nodes are grouped by role: web, app, and db.

### Infrastructure details

| Component | Lab detail |
|---|---|
| Cloud provider | AWS |
| Control node OS | Ubuntu |
| Control node | Ubuntu EC2 instance |
| Managed nodes | Three EC2 instances |
| Managed-node operating systems | Ubuntu and RHEL; confirm the OS of each host in the EC2 console |
| Instance size | `t2.micro` was the lab target; verify the actual instance type in EC2 |
| Connection method | SSH |
| SSH port | TCP 22 |
| Authentication | EC2 SSH key pair |
| AWS Region | `ap-southeast-2` was visible in the supplied EC2 hostname; verify the region of every instance |

### Server roles and addresses

The addresses below are intentionally redacted. Put the current addresses in your local inventory file and keep them out of a public README where possible.

| Inventory host | Role | Address to use in the local inventory | Operating system / SSH user |
|---|---|---|---|
| `web-server` | Web server | `<WEB_PUBLIC_IP_OR_REACHABLE_PRIVATE_IP>` | Ubuntu: `ubuntu`; RHEL: `ec2-user` |
| `app-server` | Application server | `<APP_PUBLIC_IP_OR_REACHABLE_PRIVATE_IP>` | Ubuntu: `ubuntu`; RHEL: `ec2-user` |
| `db-server` | Database server | `<DB_PUBLIC_IP_OR_REACHABLE_PRIVATE_IP>` | Ubuntu: `ubuntu`; RHEL: `ec2-user` |

Use public IPs when the control node connects over the internet. If the control node and managed nodes are in the same VPC, private IPs are usually preferable, provided routing and security-group rules allow the connection.

EC2 public IPv4 addresses can change after a stop and start unless an Elastic IP is attached. Recheck the addresses before running Ansible after an instance restart.

### Security group rules

The managed nodes must allow inbound SSH from the control node. When all instances are in the same VPC, a security-group reference to the control node's security group is usually preferable. An alternative is to allow the control node's private IP with a `/32` source rule.

| Direction | Protocol | Port | Source / destination |
|---|---|---:|---|
| Inbound on managed nodes | TCP | 22 | Control node security group or its private IP `/32` |

Do not expose SSH to `0.0.0.0/0` for this lab. Also confirm that the control node has outbound access to the managed nodes on TCP 22.

## 4. Installing Ansible on the control node

Ansible is installed on the control node. The managed nodes do not need an Ansible agent.

Update the Ubuntu package index:

```bash
sudo apt update
```

Install Ansible:

```bash
sudo apt install ansible -y
```

Check the installation:

```bash
ansible --version
```

The output includes the Ansible version, active configuration file, Python version, and executable location. Record the actual version shown by your control node:

- Ansible version: `<RECORD_ACTUAL_VERSION>`
- Python version: `<RECORD_ACTUAL_VERSION>`
- Configuration file: `<RECORD_PATH>`

Ansible runs from the control node and connects to managed nodes over SSH. Installing Ansible on every managed node is unnecessary.

## 5. SSH authentication setup

Ansible uses SSH to connect to the Linux managed nodes. The private key must be present on the control node, and the matching public key must be authorized on each EC2 instance.

### Check the SSH directory

```bash
cd ~/.ssh
ls -la
```

The key file used in this lab was named:

```text
/home/ubuntu/.ssh/day68-ansible-key
```

The directory may also contain files such as:

```text
known_hosts
known_hosts.old
```

Common SSH files:

- `day68-ansible-key`: private key used by the SSH client.
- The matching public key: installed in the remote account's `~/.ssh/authorized_keys` file.
- `known_hosts`: server host keys accepted by this SSH client.
- `authorized_keys`: public keys allowed to log in to a particular account.

The private key and the remote server's host key serve different purposes. The private key authenticates the user; the host key helps the client verify the server's identity.

### Set private-key permissions

```bash
chmod 400 /home/ubuntu/.ssh/day68-ansible-key
```

Keep the private key outside the Git repository. Never commit it or paste its contents into an issue, README, or chat.

### Use the correct SSH username

The username depends on the target AMI:

| EC2 operating system | Common default SSH user |
|---|---|
| Ubuntu | `ubuntu` |
| Red Hat Enterprise Linux | `ec2-user` |
| Amazon Linux | `ec2-user` |

Check the AMI for each instance in the EC2 console. Do not set one global `ansible_user` if the inventory contains both Ubuntu and RHEL hosts. Set `ansible_user` on each host instead.

### Test SSH manually

Use the key explicitly when testing a host. For an Ubuntu node:

```bash
ssh -i /home/ubuntu/.ssh/day68-ansible-key ubuntu@<UBUNTU_NODE_IP>
```

For a RHEL node:

```bash
ssh -i /home/ubuntu/.ssh/day68-ansible-key ec2-user@<RHEL_NODE_IP>
```

Repeat for each managed node. The connection should open a shell. Exit with:

```bash
exit
```

On the first connection, SSH may ask whether to trust the server's host fingerprint. Verify the fingerprint through a trusted channel before accepting it.

## 6. Creating the Ansible project and inventory

Create the project directory on the control node:

```bash
mkdir -p ~/ansible-practice
cd ~/ansible-practice
```

Create the inventory file:

```bash
nano inventory.ini
```

### Inventory configuration

Use the following as a template. Replace the address placeholders with the current addresses and set the SSH user on each host according to that host's AMI. The example uses Ubuntu for `web-server` and `app-server`, and RHEL for `db-server`; change the usernames if your OS mapping is different.

```ini
[web]
web-server ansible_host=<WEB_PUBLIC_IP_OR_PRIVATE_IP> ansible_user=ubuntu

[app]
app-server ansible_host=<APP_PUBLIC_IP_OR_PRIVATE_IP> ansible_user=ubuntu

[db]
db-server ansible_host=<DB_PUBLIC_IP_OR_PRIVATE_IP> ansible_user=ec2-user

[all:vars]
ansible_ssh_private_key_file=/home/ubuntu/.ssh/day68-ansible-key
```

If `db-server` is Ubuntu, change its `ansible_user` to `ubuntu`. If the web or app host is RHEL, set that host's `ansible_user` to `ec2-user`. Keep the key path consistent with the location of the private key on your control node.

### What the inventory entries mean

- `[web]`, `[app]`, and `[db]` define inventory groups.
- `web-server`, `app-server`, and `db-server` are inventory aliases.
- `ansible_host` provides the actual IP address or DNS name used for the SSH connection.
- `ansible_user` sets the SSH login user for that specific host.
- `ansible_ssh_private_key_file` sets the private key used for SSH authentication.
- `[all:vars]` applies the key-path variable to every host in the inventory.

### Inspect the inventory

Show the inventory as a graph:

```bash
ansible-inventory -i inventory.ini --graph
```

Show the inventory in JSON format:

```bash
ansible-inventory -i inventory.ini --list
```

These commands confirm that Ansible can parse the inventory. They do not test SSH connectivity.

## 7. Troubleshooting SSH host-key verification

### Error encountered

The first Ansible ping attempt returned an error similar to:

```text
UNREACHABLE!
Task failed to connect to the host via ssh:
Host key verification failed.
```

### What the error means

SSH keeps a record of remote server host keys in `~/.ssh/known_hosts`. When a host is new, its key has not yet been recorded. If a saved key no longer matches the server, SSH may also reject the connection. This can happen when an EC2 instance is replaced and reuses an address.

Host-key verification is separate from private-key authentication. Accepting a server fingerprint does not prove that the EC2 login username or private key is correct.

### Check for a saved host key

```bash
ssh-keygen -F <MANAGED_NODE_IP>
```

### Remove a stale entry only when appropriate

If the instance was replaced or its host key changed, first verify the new fingerprint through a trusted channel. Then remove the old entry for that host:

```bash
ssh-keygen -R <MANAGED_NODE_IP>
```

If the command reports that the host was not found, there was no matching entry for that exact name or address in the current user's `known_hosts` file.

### Connect manually and verify the fingerprint

For an Ubuntu host:

```bash
ssh -i /home/ubuntu/.ssh/day68-ansible-key ubuntu@<UBUNTU_NODE_IP>
```

For a RHEL host:

```bash
ssh -i /home/ubuntu/.ssh/day68-ansible-key ec2-user@<RHEL_NODE_IP>
```

Check the displayed fingerprint against a trusted value before typing `yes`. After the connection succeeds, exit the remote shell. SSH stores the accepted host key in `known_hosts`.

During troubleshooting, a separate attempt to connect without `-i` returned `Permission denied (publickey,...)`. That error concerns user authentication. Retest with the correct private key and the username for the target AMI.

### Temporary lab-only alternative

For a short-lived test session, host-key checking can be disabled in the current shell:

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```

This bypasses SSH server identity checks for Ansible in that shell. Use verified host keys for normal work; disabling this check reduces protection against man-in-the-middle attacks.

## 8. Testing Ansible connectivity

The Ansible `ping` module checks whether Ansible can connect to a managed node and execute a small module using the remote Python environment. It is not an ICMP network ping.

Run the test against every inventory host:

```bash
ansible all -i inventory.ini -m ping
```

A successful response for each host looks like this:

```text
web-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

app-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}

db-server | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Replace this example with the actual terminal output when recording lab evidence. A `pong` response from all three hosts confirms that inventory parsing, SSH access, authentication, and remote module execution are working.

If a host is unreachable, check its address, security-group rule, SSH username, private-key path, host fingerprint, and remote Python installation.

## 9. Running Ansible ad-hoc commands

Ad-hoc commands run one task against selected inventory hosts without a playbook. Run these after all intended hosts pass the Ansible ping test.

### 1. Check uptime on all servers

```bash
ansible all -i inventory.ini -m command -a "uptime"
```

This returns the uptime and load averages for each managed node.

### 2. Check memory on the web group

```bash
ansible web -i inventory.ini -m command -a "free -h"
```

This runs only on hosts in the `web` group.

### 3. Check disk space on all servers

```bash
ansible all -i inventory.ini -m command -a "df -h"
```

This reports mounted filesystems and their space usage.

### 4. Install Git

The generic `package` module selects the package manager available on the managed host:

```bash
ansible web -i inventory.ini -m package -a "name=git state=present" --become
```

For an Ubuntu host, the equivalent package-specific command is:

```bash
ansible web -i inventory.ini -m apt -a "name=git state=present update_cache=yes" --become
```

For a supported RHEL host, use `dnf` on current releases or `yum` on older releases. For example:

```bash
ansible db -i inventory.ini -m dnf -a "name=git state=present" --become
```

Use the command that matches the operating system and package manager on the target host. If the task is intended to install Git on every server, target the appropriate groups or use `all` with the generic `package` module.

`--become` asks Ansible to use privilege escalation, normally `sudo`. It is needed for package installation and other administrative changes. The remote account must be allowed to use sudo.

Verify the installation on the target group:

```bash
ansible web -i inventory.ini -m command -a "git --version"
```

### 5. Copy a file to all servers

Create the source file on the control node:

```bash
echo "Hello from Ansible" > hello.txt
```

Copy it to `/tmp` on every managed node:

```bash
ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```

### 6. Verify the copied file

```bash
ansible all -i inventory.ini -m command -a "cat /tmp/hello.txt"
```

Each host should print:

```text
Hello from Ansible
```

### `command` compared with `shell`

| Module | Behaviour | Example use |
|---|---|---|
| `command` | Runs a command directly. It does not interpret pipes, redirects, wildcard expansion, or shell variables. | `ansible all -m command -a "uptime"` |
| `shell` | Runs the command through a shell and supports shell features such as pipes and redirection. | `ansible all -m shell -a "df -h | grep /dev"` |

Use `command` for ordinary commands. Use `shell` only when the task needs shell syntax, and quote the command carefully. For file creation or copying, Ansible modules such as `copy` are usually easier to manage than shell redirection.

Record the actual command output in your lab notes or screenshots. Do not use expected output as evidence of a completed run.

## 10. Exploring inventory groups and patterns

Ansible can group hosts by role and combine groups into parent groups. This helps target several servers with one command.

### Create parent groups

Add the following sections to the end of `inventory.ini`:

```ini
[application:children]
web
app

[all_servers:children]
application
db
```

`application` contains the `web` and `app` groups. `all_servers` contains `application` and `db`, so it includes all three managed nodes.

### Test the groups

Run a ping against the application group:

```bash
ansible application -i inventory.ini -m ping
```

This targets the web and app servers.

Test the database group:

```bash
ansible db -i inventory.ini -m ping
```

This targets only the database server.

Test all servers through the parent group:

```bash
ansible all_servers -i inventory.ini -m ping
```

### Use host patterns

The OR pattern selects hosts from either group:

```bash
ansible 'web:app' -i inventory.ini -m ping
```

The exclusion pattern selects every host except the database group:

```bash
ansible 'all:!db' -i inventory.ini -m ping
```

In these patterns, `:` combines selections and `!` excludes a selection. Quote patterns that contain special characters so the shell passes them to Ansible unchanged.

## 11. Creating `ansible.cfg`

Ansible can read project defaults from an `ansible.cfg` file. This avoids repeating the inventory and SSH key options in every command.

Create the file in the `ansible-practice` directory:

```bash
nano ansible.cfg
```

Add:

```ini
[defaults]
inventory = ./inventory.ini
private_key_file = /home/ubuntu/.ssh/day68-ansible-key
host_key_checking = True
```

The SSH user remains defined per host in `inventory.ini`, because this lab has both Ubuntu and RHEL nodes. If all hosts used the same operating system, a single `remote_user` setting could be suitable.

Keep host-key checking enabled and verify the server fingerprints before connecting. The project-level `ansible.cfg` is used when Ansible runs from this project directory, unless a higher-priority configuration setting such as `ANSIBLE_CONFIG` overrides it.

### Verify the active configuration

```bash
ansible --version
```

Check that the output shows the project file, for example:

```text
config file = /home/ubuntu/ansible-practice/ansible.cfg
```

### Run Ansible without `-i`

From inside `~/ansible-practice`, run:

```bash
ansible all -m ping
```

Ansible should use `./inventory.ini` from the configuration file.

## 12. Ansible command reference

| Command | Purpose |
|---|---|
| `ansible --version` | Display the installed Ansible version and active configuration file |
| `ansible-inventory -i inventory.ini --graph` | Display inventory groups and hosts as a graph |
| `ansible-inventory -i inventory.ini --list` | Display inventory data in JSON format |
| `ansible all -i inventory.ini -m ping` | Test all managed nodes |
| `ansible web -i inventory.ini -m ping` | Test the web group |
| `ansible all -i inventory.ini -m command -a "uptime"` | Check uptime on all hosts |
| `ansible all -i inventory.ini -m command -a "df -h"` | Check filesystem space on all hosts |
| `ansible web -i inventory.ini -m package -a "name=git state=present" --become` | Install Git on the web group |
| `ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"` | Copy a file to all hosts |
| `ansible-config dump --only-changed` | Show Ansible settings that differ from defaults |

After `ansible.cfg` is in place, commands can omit `-i inventory.ini` when run from the project directory.

## 13. Key learnings

During this lab, I worked through these Ansible concepts and tasks:

1. Configuration management and its role in keeping server settings consistent.
2. The differences between Ansible, Chef, Puppet, and Salt.
3. Ansible's agentless SSH connection model for Linux hosts.
4. Installing Ansible on an Ubuntu control node.
5. Creating an inventory with web, app, and db groups.
6. Using host-specific SSH usernames for Ubuntu and RHEL instances.
7. Understanding SSH keys, `known_hosts`, and host-key verification.
8. Troubleshooting SSH connectivity and authentication errors.
9. Running ad-hoc commands against selected hosts.
10. Installing packages and copying files with Ansible modules.
11. Creating parent and child inventory groups.
12. Selecting hosts with OR and exclusion patterns.
13. Setting project defaults in `ansible.cfg`.

Update this list to match the tasks you completed and verified in your own terminal.


## 15. Conclusion

Day 68 covered the first steps in using Ansible to manage EC2 instances. An Ubuntu EC2 instance is used as the control node, while three other EC2 instances are managed over SSH. The inventory groups the servers by role and stores the connection settings for each host.

The lab also covers SSH host-key verification, host-specific usernames for Ubuntu and RHEL, ad-hoc commands, package installation, file copying, inventory patterns, and project-level Ansible settings.

The next step is to write an Ansible playbook in YAML and use it to apply repeatable configuration to one or more managed nodes.

## Submission notes

Before committing this document:

- Replace the operating-system examples with the actual OS for each EC2 host.
- Add the Ansible and Python versions from `ansible --version`.
- Replace expected output with the output you actually received.
- Add screenshots only for commands that you successfully ran.
- Keep public IP addresses redacted if the repository is public.
- Never add the private SSH key to Git.

**Challenge:** Day 68, 90DaysOfDevOps / AI-Powered
**Focus:** Ansible, configuration management, AWS EC2, Ubuntu, RHEL, SSH, inventory, ad-hoc commands, and infrastructure automation.
