# 🚀 Day 21 – Shell Scripting Cheat Sheet

> A simple Bash reference made from what I practiced during Days 16–20.

I started with basic Bash commands and slowly moved into scripts for system checks, backups, log rotation, and log analysis.

This cheat sheet is my **quick revision guide**.

---

## ⚡ Quick Reference

| Topic         | Remember                   |
| ------------- | -------------------------- |
| `#!/bin/bash` | Use Bash to run the script |
| `$name`       | Variable                   |
| `read`        | Take user input            |
| `$0`          | Script name                |
| `$1`, `$2`    | Script arguments           |
| `$#`          | Number of arguments        |
| `"$@"`        | All arguments              |
| `$?`          | Last command status        |
| `if`          | Make a decision            |
| `case`        | Handle fixed choices       |
| `for`         | Repeat through items       |
| `while`       | Repeat while true          |
| `until`       | Repeat until true          |
| `break`       | Stop a loop                |
| `continue`    | Skip one iteration         |
| `local`       | Function variable          |
| `return`      | Send status from function  |
| `grep`        | Find text                  |
| `awk`         | Work with columns          |
| `sed`         | Change text                |
| `cut`         | Take fields                |
| `sort`        | Sort data                  |
| `uniq`        | Count/remove duplicates    |
| `tr`          | Change/remove characters   |
| `wc`          | Count                      |
| `head`        | Show beginning             |
| `tail`        | Show end / follow logs     |
| `set -e`      | Stop on error              |
| `set -u`      | Catch unset variables      |
| `pipefail`    | Catch pipeline errors      |
| `set -x`      | Debug commands             |
| `trap`        | Run cleanup                |

---

# 🟢 1. Bash Basics

## 📌 Shebang

The shebang tells Linux which interpreter should run the script.

```bash
#!/bin/bash

echo "Hello, DevOps!"
```

**Remember:** Put it at the top of a Bash script.

---

## ▶️ Run a Script

Give the script permission:

```bash
chmod +x script.sh
```

Run it:

```bash
./script.sh
```

Or:

```bash
bash script.sh
```

---

## 💬 Comments

Use `#` to write a comment.

```bash
# Check server status
echo "Checking..."
```

Comments are there for humans, not Bash.

---

## 📦 Variables

Store a value in a variable.

```bash
NAME="Ashish"
ROLE="DevOps Engineer"

echo "$NAME"
echo "$ROLE"
```

**Important:** No spaces around `=`.

```bash
NAME="Ashish"      # ✅
NAME = "Ashish"    # ❌
```

---

## 🔤 Quotes

```bash
name="DevOps Engineer"

echo "$name"
echo '$name'
```

```text
"$name"   → uses the variable value
'$name'   → prints $name literally
```

**Good habit:** Usually use `"$variable"`.

---

## ⌨️ User Input

Use `read` to take input.

```bash
read -rp "Enter your name: " name

echo "Hello, $name"
```

---

## 🧩 Command Substitution

Use `$(...)` when you want the result of a command.

```bash
today=$(date +%F)

echo "$today"
```

Example from backup scripting:

```bash
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
```

---

# 🟡 2. Script Arguments

Arguments allow us to give information to a script when starting it.

```bash
./greet.sh Ashish
```

Inside the script:

```bash
echo "$0"
echo "$1"
echo "$#"
echo "$@"
```

### 🔑 Common Arguments

| Variable | Meaning             |
| -------- | ------------------- |
| `$0`     | Script name         |
| `$1`     | First argument      |
| `$2`     | Second argument     |
| `$#`     | Number of arguments |
| `"$@"`   | All arguments       |
| `$?`     | Last command status |

---

## ✅ Check Arguments First

```bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source> <destination>"
    exit 1
fi
```

I used this pattern in my backup and log-processing scripts.

---

# 🟠 3. Conditions

Conditions help a script make decisions.

## 🔤 String Comparison

```bash
name="Ashish"

if [ "$name" = "Ashish" ]; then
    echo "Name matched"
fi
```

Useful operators:

```text
=      → equal
!=     → not equal
-z     → empty
-n     → not empty
```

---

## 🔢 Number Comparison

```bash
usage=85

if [ "$usage" -gt 80 ]; then
    echo "Disk usage is high"
fi
```

Useful operators:

```text
-eq    → equal
-ne    → not equal
-lt    → less than
-gt    → greater than
-le    → less/equal
-ge    → greater/equal
```

---

## 📁 File Checks

```bash
if [ -f "$log_file" ]; then
    echo "File exists"
fi
```

Useful checks:

```text
-f    → regular file
-d    → directory
-e    → exists
-r    → readable
-w    → writable
-x    → executable
-s    → not empty
```

---

## 🔀 if / elif / else

```bash
if [ "$usage" -gt 90 ]; then
    echo "Critical"
elif [ "$usage" -gt 80 ]; then
    echo "Warning"
else
    echo "Healthy"
fi
```

---

## 🔗 Logical Operators

```bash
[ "$usage" -gt 80 ] && echo "High usage"
[ "$status" = "failed" ] || echo "Check status"
[ ! -f "$file" ] && echo "File missing"
```

```text
&&    → run second command after success
||    → run second command after failure
!     → NOT
```

---

## 🎯 case

Useful when there are several fixed choices.

```bash
case "$1" in
    start)
        echo "Starting"
        ;;
    stop)
        echo "Stopping"
        ;;
    restart)
        echo "Restarting"
        ;;
    *)
        echo "Invalid option"
        ;;
esac
```

---

# 🔵 4. Loops

Loops help repeat the same work.

## 🔁 for Loop

### List

```bash
for name in Ashish Ram Sita; do
    echo "$name"
done
```

### Array

```bash
packages=("nginx" "curl" "wget")

for package in "${packages[@]}"; do
    echo "$package"
done
```

This is similar to the package-installation script I practiced.

---

## 🔢 C-Style for Loop

```bash
for ((i=1; i<=5; i++)); do
    echo "$i"
done
```

---

## 🔄 while Loop

Runs while the condition is true.

```bash
count=5

while [ "$count" -gt 0 ]; do
    echo "$count"
    count=$((count - 1))
done
```

---

## ⏳ until Loop

Runs until the condition becomes true.

```bash
count=1

until [ "$count" -gt 5 ]; do
    echo "$count"
    count=$((count + 1))
done
```

---

## 🛑 break

Stop the loop completely.

```bash
for i in 1 2 3 4 5; do
    [ "$i" -eq 3 ] && break
    echo "$i"
done
```

---

## ⏭️ continue

Skip the current loop iteration.

```bash
for i in 1 2 3 4 5; do
    [ "$i" -eq 3 ] && continue
    echo "$i"
done
```

---

## 📄 Loop Through Files

```bash
for file in *.log; do
    echo "Processing: $file"
done
```

---

## 📥 Read Output Line by Line

```bash
while IFS= read -r line; do
    echo "$line"
done < server_list.txt
```

A pattern I used in log rotation:

```bash
while IFS= read -r file; do
    gzip "$file"
done < <(
    find "$log_dir" -type f -name "*.log" -mtime +7
)
```

---

## 🧠 Easy Loop Reminder

```text
for     → repeat through a list
while   → repeat while true
until   → repeat until true
break   → stop
continue → skip
```

---

# 🟣 5. Functions

Functions help split a large script into smaller pieces.

## 🧱 Create a Function

```bash
greet() {
    echo "Hello, DevOps!"
}
```

Call it:

```bash
greet
```

---

## 📥 Function Arguments

```bash
greet() {
    echo "Hello, $1"
}

greet "Ashish"
```

---

## 🔒 local

Use `local` for a variable that belongs to the function.

```bash
check_disk() {
    local usage

    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    echo "Disk usage: $usage%"
}
```

---

## ↩️ return

`return` is useful for success or failure.

```bash
check_file() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}
```

Use it like this:

```bash
if check_file "app.log"; then
    echo "File found"
else
    echo "File missing"
fi
```

### Easy way to remember

```text
return → status
echo   → output
```

---

## 🧭 main Function

For larger scripts:

```bash
main() {
    check_source
    create_backup
    show_backup
}

main "$@"
```

This keeps the script flow easier to follow.

---

# 🔴 6. Text Processing

These commands became especially useful during my log-analysis practice.

## 🔎 grep

Find text.

```bash
grep "ERROR" app.log
```

Useful options:

```bash
grep -i "error" app.log
grep -n "ERROR" app.log
grep -c "ERROR" app.log
grep -r "ERROR" /var/log/
grep -v "INFO" app.log
grep -E "ERROR|Failed" app.log
```

```text
-i    → ignore case
-n    → show line number
-c    → count matches
-r    → search recursively
-v    → reverse match
-E    → extended regex
```

---

## 🔍 grep -q

Use `-q` when you only need the exit status.

```bash
dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -q "install ok installed"
```

Useful inside an `if`:

```bash
if grep -q "ERROR" app.log; then
    echo "Error found"
fi
```

---

## 📊 awk

Useful when data is arranged in columns.

### Print a column

```bash
awk '{print $1}' access.log
```

### Change the separator

```bash
awk -F: '{print $1}' /etc/passwd
```

### Use a condition

```bash
awk '$3 > 80 {print $1, $3}' data.txt
```

### Useful awk parts

```text
$1, $2, $3 → columns
-F         → field separator
$0         → full line
```

### Patterns

```bash
awk '$5 > 100 {print $1, $5}' data.txt
```

### BEGIN / END

```bash
awk 'BEGIN {print "Start"} {count++} END {print count}' app.log
```

```text
BEGIN → runs before input
END   → runs after input
```

---

## ✏️ sed

Useful for changing text.

### Replace text

```bash
sed 's/old/new/g' file.txt
```

### Delete matching lines

```bash
sed '/ERROR/d' app.log
```

### Edit the file directly

```bash
sed -i 's/http:/https:/g' config.txt
```

```text
s/old/new/g → replace
d            → delete
-i           → edit file directly
```

---

## ✂️ cut

Take a field from a line.

```bash
cut -d: -f1 /etc/passwd
```

```text
-d → delimiter
-f → field
```

---

## 🔢 sort

Sort data.

```bash
sort names.txt
sort -n numbers.txt
sort -r names.txt
```

Useful options:

```text
-n → numeric
-r → reverse
-u → unique
```

---

## 🧮 uniq

Remove or count repeated lines.

```bash
sort names.txt | uniq
```

Count them:

```bash
sort names.txt | uniq -c
```

**Remember:** `uniq` works best after sorting.

---

## 🔤 tr

Change or remove characters.

Change lowercase to uppercase:

```bash
echo "devops" | tr 'a-z' 'A-Z'
```

Output:

```text
DEVOPS
```

Remove numbers:

```bash
echo "devops123" | tr -d '0-9'
```

---

## 🔢 wc

Count things.

```bash
wc -l app.log
wc -w file.txt
wc -c file.txt
```

```text
-l → lines
-w → words
-c → bytes
```

---

## 👀 head / tail

Show the beginning:

```bash
head -n 10 app.log
```

Show the end:

```bash
tail -n 10 app.log
```

Watch a growing log:

```bash
tail -f app.log
```

---

# 🛠️ 7. Useful DevOps One-Liners

## 💾 Check Disk Usage

```bash
df -h /
```

Get only the usage number:

```bash
df / | awk 'NR==2 {print $5}'
```

Remove `%`:

```bash
df / | awk 'NR==2 {print $5}' | tr -d '%'
```

---

## 🧠 Check Memory

```bash
free -h
```

Get available memory in MB:

```bash
free -m | awk 'NR==2 {print $7}'
```

---

## ⚙️ Find Heavy CPU Processes

```bash
ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu | head -n 6
```

---

## 🟢 Check a Service

```bash
systemctl is-active --quiet nginx \
    && echo "Running" \
    || echo "Stopped"
```

Inside an `if`:

```bash
if systemctl is-active --quiet nginx; then
    echo "nginx is running"
else
    echo "nginx is stopped"
fi
```

---

## 🚨 Find Errors in a Log

```bash
grep -Ei "error|failed" app.log
```

---

## 📊 Count Errors

```bash
grep -Eic "ERROR|Failed" app.log
```

In scripts, I used:

```bash
grep -Eic "ERROR|Failed" "$log_file" || true
```

`grep` can return `1` when there are no matches, so `|| true` prevents that from stopping the script in strict mode.

---

## 🔥 Find Top Errors

```bash
grep -i "error" app.log \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -5
```

---

## 📜 Follow Errors Live

```bash
tail -f app.log | grep --line-buffered -i "error"
```

---

## 🧾 Show Critical Events

```bash
grep -n "CRITICAL" app.log
```

Read line number and message:

```bash
grep -n "CRITICAL" app.log |
while IFS=: read -r line_num log_entry; do
    echo "$line_num: $log_entry"
done
```

---

## 🗑️ Find Old Logs

Check first:

```bash
find /var/log -type f -name "*.log" -mtime +7
```

Delete after checking:

```bash
find /var/log -type f -name "*.log" -mtime +7 -delete
```

---

## 🌐 Check HTTP Status

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://example.com
```

---

# 🛡️ 8. Error Handling

## ✅ Exit Codes

Run a command:

```bash
ls /tmp
```

Check its status:

```bash
echo "$?"
```

Remember:

```text
0     → success
non-0 → failure
```

---

## 🚪 exit 0 / exit 1

Success:

```bash
exit 0
```

Failure:

```bash
exit 1
```

Example:

```bash
if [ ! -f "$file" ]; then
    echo "File not found"
    exit 1
fi
```

---

## 🛑 set -e

Stop when a command fails.

```bash
set -e

mkdir /tmp/myapp
cp app.conf /tmp/myapp/

echo "Done"
```

---

## ⚠️ set -u

Catch variables that were never set.

```bash
set -u

echo "$NAME"
```

---

## 🔗 pipefail

Catch failures inside a pipeline.

```bash
set -o pipefail

cat missing.txt | grep "ERROR"
```

---

## 🚦 Strict Mode

A common combination:

```bash
set -euo pipefail
```

Easy way to remember:

```text
-e        → stop on error
-u        → catch unset variables
pipefail  → catch pipeline errors
```

I used this in my system-check, backup, log-rotation, and log-analysis scripts.

---

## 🐛 set -x

Show commands while Bash runs them.

```bash
set -x

name="DevOps"
echo "$name"

set +x
```

Useful when debugging.

---

## 🧹 trap

Run cleanup when the script exits.

```bash
cleanup() {
    rm -f /tmp/app.lock
}

trap cleanup EXIT
```

Useful for removing temporary files or locks.

---

# 📦 9. Practical Patterns

## 🔐 Check Root User

```bash
if [ "$(id -u)" -ne 0 ]; then
    echo "Run this script as root"
    exit 1
fi
```

This is useful for scripts that run `apt-get`, create system files, or manage services.

---

## 📁 Check a Directory

```bash
if [ ! -d "$source_dir" ]; then
    echo "Directory not found"
    exit 1
fi
```

---

## 📄 Check a File

```bash
if [ ! -f "$log_file" ]; then
    echo "Log file not found"
    exit 1
fi
```

---

## 📂 Create a Directory

```bash
mkdir -p "$backup_dir"
```

`-p` also creates missing parent directories.

---

## 🕒 Create a Timestamp

```bash
timestamp=$(date +%Y-%m-%d-%H-%M-%S)
```

Useful for backups and log files.

---

## 📦 Create a Backup

```bash
archive_path="$backup_dir/backup-$timestamp.tar.gz"

tar -czf "$archive_path" \
    -C "$(dirname "$source_dir")" \
    "$(basename "$source_dir")"
```

---

## 🧹 Remove Old Backups

```bash
find "$backup_dir" \
    -type f \
    -name "backup-*.tar.gz" \
    -mtime +14 \
    -delete
```

---

## 🗜️ Compress Old Logs

```bash
find "$log_dir" \
    -type f \
    -name "*.log" \
    -mtime +7 \
    -exec gzip {} \;
```

---

## 📏 Get Archive Size

```bash
du -h "$archive_path" | cut -f1
```

---

## 📝 Create a Simple Log Report

```bash
total_lines=$(wc -l < "$log_file")

total_errors=$(grep -Eic "ERROR|Failed" "$log_file" || true)

echo "Total lines: $total_lines"
echo "Total errors: $total_errors"
```

---

## 🔥 Get Top 5 Errors

```bash
grep -i "error" "$log_file" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -5
```

---

## 📁 Create a Report File

```bash
{
    echo "Log Report"
    echo "=========="
    echo "Total lines: $total_lines"
    echo "Total errors: $total_errors"
} > "$report_file"
```

---

## 🔄 Move a Processed Log

```bash
mv "$log_file" archive/
```

---

## 📝 Redirect Output to a Log

```bash
./maintenance.sh >> "$LOG_FILE" 2>&1
```

```text
>>       → append output
2>&1     → send errors to the same place
```

---

## 🧩 Process Substitution

Use `< <(...)` when a loop should read command output.

```bash
while IFS= read -r file; do
    gzip "$file"
done < <(
    find "$log_dir" -type f -name "*.log" -mtime +7
)
```

---

# 🧪 10. Small Script Templates

## ✅ Argument Validation

```bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi
```

---

## ✅ File Validation

```bash
if [ ! -f "$1" ]; then
    echo "File not found: $1"
    exit 1
fi
```

---

## ✅ Service Check

```bash
service="nginx"

if systemctl is-active --quiet "$service"; then
    echo "$service is running"
else
    echo "$service is not running"
fi
```

---

## ✅ Disk Alert

```bash
usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$usage" -gt 80 ]; then
    echo "Warning: disk usage is $usage%"
else
    echo "Disk usage is $usage%"
fi
```

---

## ✅ Function + Status

```bash
check_disk() {
    local usage

    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    if [ "$usage" -gt 80 ]; then
        return 1
    fi

    return 0
}

if check_disk; then
    echo "Disk is healthy"
else
    echo "Disk usage is high"
fi
```

---

## ✅ Read Files Line by Line

```bash
while IFS= read -r line; do
    echo "$line"
done < server_list.txt
```

---

# 🧠 11. Quick Revision

```text
BASH
#!/bin/bash       → Bash interpreter
$name             → Variable
"$name"           → Quoted variable
read              → User input
$(command)        → Command output

ARGUMENTS
$0                → Script name
$1, $2            → Arguments
$#                → Argument count
"$@"              → All arguments
$?                → Exit status

CONDITIONS
if                → Decision
elif              → Another condition
else              → Otherwise
case              → Multiple choices

LOOPS
for               → Repeat through items
while             → Repeat while true
until             → Repeat until true
break             → Stop loop
continue          → Skip iteration

FUNCTIONS
name()            → Function
$1, $2            → Function arguments
local             → Local variable
return            → Status
echo              → Output

TEXT
grep              → Search
awk               → Columns
sed               → Change text
cut               → Extract fields
sort              → Sort
uniq              → Count/remove duplicates
tr                → Change/remove characters
wc                → Count
head              → Beginning
tail              → End/live logs

ERROR HANDLING
$?                → Exit status
exit 0            → Success
exit 1            → Failure
set -e            → Stop on error
set -u            → Catch unset variables
pipefail          → Catch pipeline failures
set -x            → Debug
trap              → Cleanup
```

---

# 🎯 Final Takeaway

The main thing I learned from these days is how different Bash features can work together.

I started with simple scripts and then used the same building blocks for:

**system checks → backups → log rotation → log analysis → automation**

That is the Bash foundation I want to carry into the next part of my DevOps journey.

**Day 21 complete. 🚀**

#90DaysOfDevOps #DevOpsKaJosh #TrainWithShubham
