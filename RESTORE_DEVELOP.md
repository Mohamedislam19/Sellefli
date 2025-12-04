# Restore Develop Branch

The `develop` branch was accidentally deleted. Here's the information needed to restore it:

## Commit Information
- **Original Commit SHA**: `287475000849cdcd771c6d492e572520657a40b3`
- **Commit Message**: "Merge remote changes and resolve conflicts"
- **Author**: Beradai Houssameddine Diaelhak (houubeer)
- **Date**: December 3, 2025

## How to Restore the Branch

### Option 1: Using GitHub Web Interface
1. Go to your repository: https://github.com/Mohamedislam19/Sellefli
2. Navigate to the commit: https://github.com/Mohamedislam19/Sellefli/commit/287475000849cdcd771c6d492e572520657a40b3
3. Click on the **Browse files** button on that commit page
4. Click the dropdown where it shows the commit SHA
5. Type `develop` and click "Create branch: develop from '287475...'"

### Option 2: Using Git Command Line
```bash
# Clone or navigate to your repository
cd Sellefli

# Create a new develop branch from the commit
git checkout -b develop 287475000849cdcd771c6d492e572520657a40b3

# Push the restored develop branch
git push origin develop
```

### Option 3: Using GitHub CLI (gh)
```bash
# Create the branch using GitHub API
gh api repos/Mohamedislam19/Sellefli/git/refs -f ref="refs/heads/develop" -f sha="287475000849cdcd771c6d492e572520657a40b3"
```

## Verification
After restoring, verify the branch exists:
- Check branches at: https://github.com/Mohamedislam19/Sellefli/branches
- The `develop` branch should be pointing to the same commit as before deletion

---
*This file can be deleted after the branch is restored.*
