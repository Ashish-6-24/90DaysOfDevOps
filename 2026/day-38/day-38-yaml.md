# Day 38 – YAML Basics

## Objective

Understand YAML syntax, practice representing configuration data, learn how indentation affects structure, and validate YAML files before using them in DevOps automation and CI/CD pipelines.

## `person.yaml`

This file describes a DevOps learner using basic YAML data types, key-value pairs, and lists.

```yaml
---
name: Ashish Subedi
role: Aspiring DevOps Engineer
experience_years: 0
learning: true

tools:
  - Linux
  - Docker
  - Git
  - Terraform
  - GitHub Actions

hobbies: [Shell Scripting, Troubleshooting, Building Projects]
```

The file demonstrates four basic data types and structures:

- `name` and `role` represent string values.
- `experience_years` is a numeric value.
- `learning` is a Boolean.
- `tools` and `hobbies` demonstrate two different list formats.

## YAML Lists

YAML supports two common ways to represent a collection of items.

### Block style

Block-style lists place each item on a separate line. Indentation keeps the items associated with their parent key.

```yaml
devops_tools:
  - Linux
  - Docker
  - Terraform
```

This style is useful when a list contains multiple items and readability is important.

### Flow/inline style

Flow-style lists place the items inside square brackets, separated by commas.

```yaml
learning_topics: [Networking, Automation, Cloud Computing]
```

This format is convenient for short lists that do not need multiple lines.

## `server.yaml`

This file demonstrates nested mappings, server configuration, database credentials, and multi-line strings.

```yaml
---
server:
  name: devops-practice-node
  ip: 10.0.2.15
  port: 3000

database:
  host: localhost
  name: devops-labs
  credentials:
    user: lab_user
    password: change_password 

startup_script_literal: |
  echo "Starting application"
  echo "Checking dependencies"

startup_script_folded: >
  echo "Starting application"
  echo "Checking dependencies"
```

The `server` mapping contains the server's name, IP address, and port. The `database` mapping contains its host, database name, and nested credentials.

The `startup_script` mapping contains two examples of YAML block scalars. The first demonstrates a multi-line shell script; the second demonstrates readable prose written across several lines.

The database password is a placeholder. Real credentials should be stored securely and never committed to a public GitHub repository.

## `|` vs `>`

YAML provides block scalar indicators for storing multi-line strings. The choice between them determines how line breaks are represented in the resulting string.

**How it works:** The commands remain separated by line breaks in the resulting string.

**use case:** This style is appropriate for embedded shell scripts, configuration files, or other content where preserving line separators is important for execution or readability.

For example, the script can be passed to a shell that executes each command on a separate line.

### Folded style (`>`)

The folded block scalar converts most ordinary line breaks into spaces.

```yaml
description: >
  This application configuration contains
  the server settings and database details
  required for the development environment.
```

**How it works:** The wrapped lines become a continuous string, with ordinary line breaks folded into spaces. Blank lines and certain other line-break cases have different folding behavior.

**use case:** This style is suitable for long descriptions, explanatory text, or other strings that should read continuously even though they are wrapped across multiple lines in the YAML editor.

### Comparison

| Feature | Literal (`|`) | Folded (`>`) |
|---|---|---|
| Ordinary line breaks | Preserved | Folded into spaces |
| Typical use | Shell scripts and multi-line configuration | Long descriptions and continuous prose |
| Result | Multi-line string | Usually one continuous line |

Choose `|` when line breaks matter. Choose `>` when line-wrapped text should usually become a continuous string.

## YAML Rules

The following practices help prevent common YAML mistakes:

- **Spaces instead of tabs:** Use spaces for indentation. Tabs must not be used to indent YAML content.
- **Consistent indentation:** Two spaces per level is a widely used convention. Child keys should align consistently beneath their parent.
- **Correct data types:** Use `true` or `false` for Boolean values. Quoting `"true"` makes it a string instead.
- **Clear key-value pairs:** Separate mapping keys and values using a colon and a space, such as `port: 3000`.
- **Consistent list formatting:** Items belonging to the same block-style list should have their dashes aligned.
- **Appropriate quoting:** Quote values when necessary to avoid ambiguity or unintended interpretation of YAML-special characters.

Indentation matters because YAML uses whitespace to describe relationships between mappings and sequences. A formatting mistake can cause a parsing error or change the structure of the data.

## Validation

YAML files should be checked before being used in a pipeline or other automation. A validator or linter can help identify syntax issues, indentation mistakes, and formatting problems.

### Install `yamllint`

On Ubuntu, install the local YAML linter using:

```bash
sudo apt update
sudo apt install -y yamllint
```

Check the installed version:

```bash
yamllint --version
```

### Validate the files

Run these commands from the directory containing the YAML files:

```bash
yamllint person.yaml
yamllint server.yaml
```

You can also validate both files in one command:

```bash
yamllint person.yaml server.yaml
```

A clean run may produce no output. Review any warnings or errors and correct the reported issues. A linter can identify style problems in addition to syntax problems, so not every warning means the YAML cannot be parsed.

An online YAML validator is another option when a local linter is unavailable. Avoid submitting real credentials or other sensitive information to public validation services.

## Spot the Difference

Consider these two YAML examples.

### Block 1 - Correct

```yaml
name: devopstools
tools:
  - docker
  - kubernetes
```

### Block 2 - Broken

```yaml
name: devopstools:
tools:
  - docker
  - kubernetes
```

### What is wrong with Block 2?

The `name` line contains an extra colon after `devopstools`.

In YAML, a colon followed by whitespace or a line break is a mapping indicator. The extra colon at the end of this scalar makes the intended key-value structure invalid and can cause the parser to report a syntax error.

The correct declaration is:

```yaml
name: devopstools
```

The tools list should remain under its own `tools` key, with both list items aligned consistently.

**Important distinction:** An extra colon in a key-value declaration is a different problem from inconsistent list indentation. Both examples help demonstrate why YAML syntax and structure must be checked carefully.

## Key Learnings

1. **YAML relies on whitespace and structure.** Using spaces consistently and aligning nested keys and list items helps produce valid, readable configuration files.
2. **YAML supports multiple data structures.** Key-value pairs, Boolean values, block lists, inline lists, and nested mappings can represent common DevOps configuration requirements.
3. **The `|` and `>` indicators handle line breaks differently.** Literal style preserves ordinary line breaks, while folded style converts most ordinary line breaks into spaces. YAML validation helps detect formatting and syntax problems before configuration is used for automation.

## Conclusion

Day 38 introduced the fundamentals of YAML, including data types, list formats, nested structures, multi-line strings, and validation. These concepts provide a foundation for working with Docker Compose, Kubernetes configuration files, and GitHub Actions workflows in future DevOps projects.
