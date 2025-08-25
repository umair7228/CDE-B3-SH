# Git & GitHub Complete Guide 🚀

```bash
##############################################
# GIT & GITHUB COMPLETE GUIDE
##############################################

# STEP 1: Configure Git (One Time)
git config --global user.name "Your Name"      # Set your name
git config --global user.email "your-email@example.com"  # Set your email
git config --list                              # Verify configuration

##############################################
# TWO WAYS TO START A PROJECT
##############################################

# ============================================
# 🔹 METHOD 1: Start from an Existing Repo (CLONING)
# ============================================

git clone <repository-url>          # Clone the remote repository
cd <repo-name>                      # Navigate into project folder
git status                          # Check current status
git add <filename>                  # Add a specific file
git add .                           # OR add all files
git commit -m "Your commit message" # Commit your changes
git push -u origin main             # Push changes to GitHub

# ============================================
# 🔹 METHOD 2: Start from Scratch and Push to GitHub
# ============================================

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

##############################################
# ✅ WORKING WITH BRANCHES
##############################################

git branch feature-branch                       # Create a new branch
git checkout feature-branch                     # Switch to the new branch
# OR create and switch in one step
git checkout -b feature-branch

git add .                                       # Stage changes
git commit -m "Added new feature"               # Commit changes
git checkout main                               # Switch back to main branch
git merge feature-branch                        # Merge feature branch into main
git branch -d feature-branch                    # Delete the feature branch
git branch                                      # List all branches
git branch -r                                   # List remote branches

##############################################
# ✅ UNDO & FIX MISTAKES
##############################################

git reset <filename>                            # Remove file from staging
git reset                                       # Remove all staged files
git reset --soft HEAD~1                         # Undo last commit, keep changes
git reset --hard HEAD~1                         # Undo last commit and delete changes

##############################################
# ✅ REMOVE OR RENAME FILES
##############################################

git rm <filename>                               # Remove file from Git & disk
git rm --cached <filename>                      # Remove file only from Git
git mv oldname newname                          # Rename file

##############################################
# ✅ VIEW DIFFERENCES
##############################################

git diff                                        # Show unstaged changes
git diff --staged                               # Show staged changes

##############################################
# ✅ TAGGING (VERSIONS)
##############################################

git tag v1.0                                    # Create a tag
git push --tags                                 # Push tags to GitHub

##############################################
# ✅ STASH (SAVE WORK TEMPORARILY)
##############################################

git stash                                       # Save changes
git stash list                                  # List stashes
git stash apply                                 # Apply last stash
git stash drop                                  # Delete last stash

##############################################
# ✅ PULL WITH REBASE (ADVANCED)
##############################################

git pull --rebase                               # Pull latest changes with rebase

##############################################
# ✅ REMOTE INFO & SPECIFIC CLONE
##############################################

git remote -v                                   # Check remote URL
git clone -b branch-name <repository-url>       # Clone specific branch

##############################################
# ✅ .gitignore EXAMPLE
##############################################

# Create a file named .gitignore and add:
# node_modules/
# *.log
# .env

##############################################
# ✅ BEST PRACTICES
##############################################
# - Commit often with meaningful messages
# - Always pull before you push
# - Use branches for features
# - Add a .gitignore for unnecessary files
##############################################
