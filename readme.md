# Git42 - Effortlessly Manage Multiple Git Identities

## Overview

Git42 is a powerful yet simple tool that helps developers manage multiple Git identities with ease. Designed for users who work across multiple GitHub accounts, Git42 automates the management of SSH keys and Git user configurations, allowing for seamless switching between different identities. Whether you are handling multiple projects with distinct GitHub profiles or managing various SSH keys, Git42 streamlines the process.

## Features

- **One-Line Installation**: Quickly install Git42 with a single command.
- **User Management**: Easily add, remove, edit, and list users from a central database.
- **Multiple Profiles**: Store and manage multiple Git user profiles, each with its own SSH key.
- **Seamless Switching**: Switch between GitHub accounts instantly using a single command.
- **Automated SSH Key Handling**: Simplify authentication by automating SSH key management.
- **Interactive CLI**: Enjoy an intuitive, user-friendly command-line interface for configuration and operations.

## Prerequisites

Before using Git42, ensure you have:

- **Bash Shell**: Available on Linux, macOS, or Git Bash for Windows.
- **Git**: Confirm your installation with `git --version`.
- 

## Installation

Install Git42 automatically by running:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ababdelo/Git42/main/install.sh)
```

## Usage

### Adding a New User

To add a new Git user profile, execute the following command:

```bash
git42 add
```

You will be prompted to enter:

- Git username
- Git email
- SSH key path

Once entered, this user’s information is saved, and you can switch to them without re-entering these details in the future.

### Removing a 

To delete a user profile, use the following command:

```bash
git42 rm <user_id>
```

This will permanently remove the specified user from the database.

### Editing a User

To modify a user’s details, such as username, email, or SSH key, run:

```bash
git42 edit <user_id>
```

### Listing Users

To view all registered users and their details, execute:

```bash
git42 list
```

### Switching to a User

To switch to a different user profile, use:

```bash
git42 setup <user_id>
```

This command:

1. Clears all currently added SSH keys.
2. Adds the selected user's SSH key to the SSH agent.
3. Update the global Git configuration to reflect the chosen user’s details.

### Updating Configuration

To adjust Git42’s configuration settings, run:

```bash
git42 config 
```

You will be prompted to select an option from the available choices, such as:

- user_db <path/to/new_database>

Note: This feature is still in beta and currently only supports updating the database location.

## Example Workflow

1. Add two users:
   ```bash
    git42 add
    # Enter details for the first user
    git42 add
    # Enter details for the second user
   ```
2. Switch between accounts:
   ```bash
    git42 setup user1
    # Work under the first account (e.g., clone a repository, make changes, commit, and push).

    git42 setup user2
    # Work under the second account (e.g., clone a repository, make changes, commit, and push).

   ```
3. Remove a user:
   ```bash
   git42 rm user1
   ```

## Troubleshooting

- **SSH key fails to add**: Ensure the SSH agent is running: `eval \$(ssh-agent -s)`.
- **Cannot find a user**: Run `git42 list` to check stored users.
- **Git credentials incorrect**: Run `git config --global --list` to verify the applied settings.

## License

This project is licensed under the MIT License.

## Author

Developed by **ababdelo** 🚀. Contributions are welcome!
