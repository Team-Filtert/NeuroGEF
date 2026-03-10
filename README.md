# NEURO-SAMA: the Good, the Evil and the Filtered

This is a JRPG dedicated to AITuber Neuro-sama and Vedal made with Godot 4.5.1



## Contribution

### How to start

To start work you need [git](https://git-scm.com/install/) and at least node version 18.19.1

Check if node is installed by running `node --version`

If it's not installed [here's ](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) guied how to do it

After that you need to clone this repository with git

```
git clone https://github.com/lokt02/neuro-jrpg-game
```

Enter the prooject directory and run `npm ci` to install dev dependacies

It's also important to ensure that npm uses bash tu run scripts so you must execute this command:
```
npm config set script-shell "C:\\Program Files\\git\\bin\\bash.exe"
```

If you don't have bash in this directory then you either it's not installed or located somewhere else, paste correct path to bash instead in this case

We are using [Godot 4.5.1](https://godotengine.org/download/archive/4.5.1-stable/) so make sure you are using it as well

### Workflow

After you've chosen task to do, create your own local branch with `git branch <your-branch-name>`

We recommend sticking to [conventional commit names](https://www.conventionalcommits.org/en/v1.0.0/)

After you finish, push your branch to origin and create pull request, it will be merged after code review