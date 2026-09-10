# Day 06 – Linux Fundamentals: Read and Write Text Files

**Goal:** Practice basic file creation, writing, appending, and reading commands in Linux.

## Commands & Output

| Command | Action |
|---|---|
| `touch notes.txt` | Creates an empty file |
| `echo "Learning Linux" > notes.txt` | Writes the first line and overwrites existing content |
| `echo "Practicing file commands" >> notes.txt` | Appends a second line |
| `echo "DevOps journey Day 06" \| tee -a notes.txt` | Appends a third line and prints it to the terminal |

**Resulting `notes.txt`:**
```text
Learning Linux
Practicing file commands
DevOps journey Day 06
```
## Reading Parts of a File
` head -n 2 notes.txt` — prints the first 2 lines
```
Learning Linux
Practicing file commands
```
` tail -n 2 notes.txt` — prints the last 2 lines
```
Practicing file commands
DevOps journey Day 06
```
`cat notes.txt` — prints the complete file
```
Learning Linux
Practicing file commands
DevOps journey Day 06
```
# Key Takeaways
`>` → overwrite the file

`>>` → append to the file

`|` → pass output from one command to another

`tee -a` → append and display output at the same time

`cat` → read the complete file

`head` → read the beginning of a file

`tail` → read the end of a file

## Output Screenshot


