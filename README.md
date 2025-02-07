
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


## How to Run Locally

To set up and run the project locally, you can follow these steps:

### 1. Clone the repository and initialize submodules

Since the main repository (`ERAS`) includes submodules for `ERAS-BE` (backend) and `ERAS-FE` (frontend):

```bash
git clone --recurse-submodules https://github.com/JU-DEV-Bootcamps/ERAS.git
cd ERAS
```
or use the SSH option for cloning

If you have already cloned the repository without submodules, run:

```bash
git submodule update --init --recursive
```

### 2. Set up environment variables

Copy the sample environment file:

```bash
cp .env.sample .env
```

Modify the `.env` file if needed (e.g., change ports or database credentials).

### 3. Run the project using Docker Compose

```bash
docker-compose up --build
```

This will spin up the required services using the environment variables from your `.env` file.

### 4. Updating submodules

If changes are made to `ERAS-BE` or `ERAS-FE` repositories, update them with:

```bash
git submodule update --remote --merge
```

### 5. Access the application

- Backend: [http://localhost:8080](http://localhost:8080)
- Frontend: [http://localhost:4200](http://localhost:4200)

⚠ **Important:** The `.env` file should not be committed to the repository. Use `.env.sample` as a reference for required environment variables.



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
