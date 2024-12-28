
# ERAS EARLY RISK ASSISTANCE SOLUTION
JALA UNIVERSITY DEV-BOOTCAMP 2024-2025
# AGREEMENTS
## Architecture
## Tech stack
For information about different technologies considered and the reasoning behind the decision made in this section, please visit [Tool researchs and proposals](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/Researchs)

### Design
[Figma](https://www.figma.com/)

### Frontend
* Framework: [Angular v19](https://angular.dev/)
* Component Library: [Angular Material](https://material.angular.io/)
* Charts: ???

### Backend
* Framework: [ASP.NET 8.0](https://dotnet.microsoft.com/es-es/apps/aspnet)
* For ORM: [Entity Framework Core](https://learn.microsoft.com/es-es/ef/core/)

### Testing
* API Testing: [PostMan](https://www.postman.com/)
* Frontend Testing: Karma
* Backend Testing: xUnit

### Devops
* Container: [Docker](https://www.docker.com/)
* CI/CD: ???
* CI/CD Libraries: Husky???


## Branching strategy = Submodules -> Feature Branching + Release Branching (on demand)
For a quick manual check our wiki: [Submodules Git manual](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/Submodules-Git-manual)

The Feature Branching Strategy allows developers to work on new features or bug fixes in isolated branches within submodules. This approach helps maintain a stable main branch while enabling parallel development.
Steps to Implement Feature Branching in Submodules
### Name branching
```bash
prefix = release|feature|ci|docs|bugfix|refactor|chore|style
storyNumber = "ERAS-BE #13".specialTrim() // "BE13"
storyTitle = verb + object // "importcosmic"
`${prefix}/${storyNumber}/${storyTitle}`
```
## Story point assignment

## System Design
The system design diagrams can be checked in the wiki: [C4 Model](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/C4-Model)
