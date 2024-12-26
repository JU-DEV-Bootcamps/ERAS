
# ERAS EARLY RISK ASSISTANCE SOLUTION
JALA UNIVERSITY DEV-BOOTCAMP 2024-2025

# Branching strategy = Feature Branching
The Feature Branching Strategy allows developers to work on new features or bug fixes in isolated branches within submodules. This approach helps maintain a stable main branch while enabling parallel development.
Steps to Implement Feature Branching in Submodules
## Manual for Using Feature Branching Strategy in Submodules
### 1. Clone the Main Repository
If you haven't already cloned the main repository that contains the submodule, do so with the following command:
```bash
git clone --recurse-submodules <main-repo-url>
```
This command clones the main repository and initializes its submodules.
### 2. Navigate to the Submodule Directory
Change to the directory of the submodule where you want to create a feature branch:
```bash
cd path/to/submodule
```
### 3. Fetch Latest Changes
Before creating a new feature branch, ensure you have the latest changes from the remote repository:
```bash
git fetch origin
```
### 4. Create a New Feature Branch
Create and switch to a new branch for your feature. Use a descriptive name that reflects the feature or bug fix:
```bash
git checkout -b feature/your-feature-name
```
### 5. Develop Your Feature
Make your changes in the submodule. After making changes, you can check the status of your working directory:
```bash
git status
```
### 6. Stage Your Changes
Once you are satisfied with your changes, stage them for commit:
```bash
git add .
```
You can also specify individual files instead of using . to add all changes.
### 7. Commit Your Changes
Commit your changes with a meaningful commit message:
```bash
git commit -m "Add feature: description of your feature"
```
### 8. Push Your Feature Branch to Remote
Push your newly created feature branch to the remote repository:
```bash
git push origin feature/your-feature-name
```
### 9. Create a Pull Request (PR)
After pushing your branch, go to your remote repository (e.g., GitHub, GitLab) and create a pull request to merge your feature branch into the main branch (usually main or develop). Provide a clear description of what your feature does and any relevant context.
### 10. Review and Merge
Once the pull request is reviewed and approved by your team members, merge it into the main branch. You can do this through the web interface of your Git hosting service.
### 11. Clean Up After Merging
After merging, switch back to the main branch in both the main repository and the submodule, and delete your feature branch if it's no longer needed:

### a. In submodule directory
```bash
git checkout main
git pull origin main  # Update local main branch
```
### b. Delete local feature branch
```bash
git branch -d feature/your-feature-name
```
### c. Optionally delete remote feature branch if needed
```bash
git push origin --delete feature/your-feature-name
```
## Best Practices
- Regularly Sync with Main Branch: Regularly pull changes from the main branch into your feature branch to minimize merge conflicts.
- Descriptive Branch Names: Use clear and descriptive names for branches to make it easier for team members to understand their purpose.
- Frequent Commits: Commit frequently with meaningful messages to document progress and make it easier to track changes.
- Code Review: Encourage code reviews before merging features into the main branch for improved code quality.
