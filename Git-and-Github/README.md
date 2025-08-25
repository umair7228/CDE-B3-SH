# Git & GitHub Complete Guide

### STEP 1: Configure Git (One Time)
```bash
git config --global user.name "Your Name"      # Set your name
git config --global user.email "your-email@example.com"  # Set your email
git config --list                              # Verify configuration
```

## TWO WAYS TO START A PROJECT

### METHOD 1: Start from an Existing Repo (CLONING)

```bash
git clone <repository-url>          # Clone the remote repository
cd <repo-name>                      # Navigate into project folder
git status                          # Check current status
git add <filename>                  # Add a specific file
git add .                           # OR add all files
git commit -m "Your commit message" # Commit your changes
git push -u origin main             # Push changes to GitHub
```

### METHOD 2: Start from Scratch and Push to GitHub

```bash
mkdir local-copy                                # Create a local folder
cd local-copy                                   # Go inside the folder
git init                                        # Initialize Git (creates .git folder)
echo "this is a readme file" >> README.md       # Create README file
echo "# this is a python file" >> day1.py       # Create a Python file
git status                                      # Check status
git remote add origin <repository-url>          # Add remote repository
git add .                                       # Add all files to staging
git commit -m "First commit"                    # Commit changes
git branch -M main                              # Rename branch to main
git push -u origin main                         # Push to GitHub
```

## WORKING WITH BRANCHES

```bash
git branch feature-branch                       # Create a new branch
git checkout feature-branch                     # Switch to the new branch
# OR create and switch in one step
git checkout -b feature-branch
```
```bash
git add .                                       # Stage changes
git commit -m "Added new feature"               # Commit changes
git checkout main                               # Switch back to main branch
git merge feature-branch                        # Merge feature branch into main
git branch -d feature-branch                    # Delete the feature branch
git branch                                      # List all branches
git branch -r                                   # List remote branches
```

## UNDO & FIX MISTAKES
```bash
git reset <filename>                            # Remove file from staging
git reset                                       # Remove all staged files
git reset --soft HEAD~1                         # Undo last commit, keep changes
git reset --hard HEAD~1                         # Undo last commit and delete changes
```

## REMOVE OR RENAME FILES
```bash
git rm <filename>                               # Remove file from Git & disk
git rm --cached <filename>                      # Remove file only from Git
git mv oldname newname                          # Rename file
```

## VIEW DIFFERENCES
```bash
git diff                                        # Show unstaged changes
git diff --staged                               # Show staged changes
```

# PULL CHANGES
```bash
git pull                                        # Pull latest changes with rebase
```
