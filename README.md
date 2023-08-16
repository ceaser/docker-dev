# `docker-dev`: Dockerized Development Environment

Welcome to `docker-dev`! This repository houses my software development environment encapsulated within a Docker container.

## Getting Started

### 1. **Start the container**

#### Using `make`:

```bash
make run
```

#### Without GNU `make`:

```bash
docker run -d --rm --name dev docker-dev:latest
```

### 2. **Setting Up User Password**

If you wish to change the default user password, follow these steps:

1. Launch a shell inside the container:
    ```bash
    docker exec -it dev bash
    ```
2. Change the password for `clarry`:
    ```bash
    passwd clarry
    ```
3. Exit the shell.

### 3. **Executing Commands as a User**

To run a shell program as the user `clarry`, use:

```bash
docker exec -it --user clarry:clarry dev bash
```

### 4. **Generate a Github Personal Authentication Token**

A Github personal authentication token is required to install the dotfiles using YADM.

- Navigate to Github and log into your account.
- Click on your profile photo (top right) and go to `Settings`.
- On the left sidebar, click on `Developer settings`.
- Click on `Personal access tokens`, then `Generate new token`.
- Provide a descriptive name for the token and select the required scopes.
- Click `Generate token`.
- Copy the generated token and use it as a password when prompted by `git`

### 5. **Integrating Dotfiles**

Add my configurations from the Dotfiles repository.

```bash
yadm clone https://github.com/ceaser/dotfiles.git
```

When prompted to run the bootstrap process, enter `y`.
