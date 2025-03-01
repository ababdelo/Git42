<h1 align="center">
Git42 - Effortlessly Manage Multiple Git Identities
</h1>

<p align="center">
  <img src="https://img.shields.io/github/last-commit/ababdelo/Git42?style=flat-square" /> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/commit-activity/m/ababdelo/Git42?style=flat-square" /> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/followers/ababdelo" /> &nbsp;&nbsp;
  <img src="https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2Fababdelo%2FGit42&label=Repository%20Visits&countColor=%230c7ebe&style=flat&labelStyle=none"/> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/stars/ababdelo/Git42" /> &nbsp;&nbsp;
  <img src="https://img.shields.io/github/contributors/ababdelo/Git42?style=flat-square" />
</p>

## Overview

Git42 is a powerful yet simple tool that helps developers manage multiple Git identities with ease. Designed for users who work across multiple GitHub accounts, Git42 automates the management of SSH keys and Git user configurations, allowing for seamless switching between different identities. Whether you are handling multiple projects with distinct GitHub profiles or managing various SSH keys, Git42 streamlines the process.

## ✨ Features

- 🚀 **One-Line Installation**: Get started quickly with a single command.
- 👥 **User Management**: Easily add, remove, edit, and list users from a central database.
- 🔑 **Multiple Profiles**: Manage several Git user profiles, each with its own SSH key.
- 🔄 **Seamless Switching**: Instantly switch between GitHub accounts with one command.
- 🤖 **Automated SSH Key Handling**: Simplify authentication by automating SSH key management.
- 💻 **Interactive CLI**: Enjoy an intuitive command-line interface for hassle-free configuration.

## Prerequisites

Before using Git42, ensure you have:

- **Bash Shell**: Available on Linux, macOS, or Git Bash for Windows.
- **Git**: Confirm your installation with `git --version`.

## Installation

Install Git42 automatically by running:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ababdelo/Git42/main/install.sh)
```

## Usage

### ➕ Adding a New User

To add a new Git user profile, execute the following command:

```bash
git42 add
```

You will be prompted to enter:

- Git username
- Git email
- SSH key path

Once entered, this user’s information is saved, and you can switch to them without re-entering these details in the future.

### ❌ Removing a User

To delete a user profile, use the following command:

```bash
git42 rm <user_id>
```

This will permanently remove the specified user from the database.

### ✏️ Editing a User

To modify a user’s details, such as username, email, or SSH key, run:

```bash
git42 edit <user_id>
```

### 📑 Listing Users

To view all registered users and their details, execute:

```bash
git42 list
```

### 🔄️ Switching to a User

To switch to a different user profile, use:

```bash
git42 setup <user_id>
```

This command:

1. Clears all currently added SSH keys.
2. Adds the selected user's SSH key to the SSH agent.
3. Update the global Git configuration to reflect the chosen user’s details.

### 🟢 Displaying Active User

To display the currently active Git user, use the following command:

```bash
git42 active
```

This command will show the user that is currently set as the active Git user for your shell session, including their id and associated username. If no active user is configured, it will notify you that there is no active user.

### 🛠️ Updating Configuration

To adjust Git42’s configuration settings, run:

```bash
git42 config 
```

You will be prompted to select an option from the available choices, such as:

- user_db <path/to/new_database>

Note: This feature is still in beta and currently only supports updating the database location.

## ⚠️ IMPORTANT TO KNOW:
Git42 requires an active SSH agent with its environment variables (especially `SSH_AUTH_SOCK`) exported in your current shell. You only need to start the SSH agent once per shell session. Once running, you can use Git42 commands without restarting the agent. However, if you open a new shell, remember to start the SSH agent again by running:

## Troubleshooting

- **SSH key fails to add**: Ensure the SSH agent is running: `eval $(ssh-agent -s)`.
- **Cannot find a user**: Run `git42 list` to check stored users.
- **Git credentials incorrect**: Run `git config --global --list` to verify the applied settings.

## License

This project is licensed under the **ED42 Non-Commercial License v1.0**. See the [LICENSE](license.md) file for more details.

## 🤝 Contributing

Contributions and suggestions to enhance this project are welcome! Please feel free to submit a pull request or open an issue.

##  ☎️ Contact

For any inquiries or collaboration opportunities, please reach out to me at:

<p align="center" style="display: inline;">
    <a href="mailto:ababdelo.ed42@gmail.com"> <img src="https://img.shields.io/badge/Gmail-EA4335?style=flat&logo=gmail&logoColor=white"/></a>&nbsp;&nbsp;
    <a href="https://www.linkedin.com/in/ababdelo"> <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=flat&logo=linkedin&logoColor=white"/></a>&nbsp;&nbsp;
    <a href="https://github.com/ababdelo"> <img src="https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white"/></a>&nbsp;&nbsp;
    <a href="https://www.instagram.com/edunwant42"> <img src="https://img.shields.io/badge/Instagram-E4405F?style=flat&logo=instagram&logoColor=white"/></a>&nbsp;&nbsp;
</p>

<p align="center">Thanks for stopping by and taking a peek at my work!</p>
