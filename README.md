# dotfiles

My personal dotfiles managed with **GNU Stow** for package configuration management and synchronization.

## What are dotfiles？

Dotfiles are configuration files that store settings for various packages and tools. They are named with a dot (`.`) prefix and therefore called as "dotfiles". The dotfiles are seen as hidden files in Unix-like system.

## What is [GNU Stow](https://www.gnu.org/software/stow)？

GNU Stow (or briefly called Stow) is a symlink (symbolic link) farm manager which is originally designed to takes distinct packages of software and/or data located in separate directories on the file system and makes them appear to be installed in the same place.

Although modern software packages are typically managed by advanced package managers like rpm, dpkg, apt and pacman, it is still useful for users to manage their configuration files (i.e. dotfiles) with Stow.

For more information about Stow, please refer to [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html).

## What is symbolic links?

Symbolic links, or symlinks, are a type of file that points to another file or directory by its path. It contains the path to the target file or directory, not the actual contents of the target.

### Creating symbolic links

In Unix-like systems, you can create symbolic links by using the `ln` command with the `-s` option.

```bash
ln -s [target file or directory] [symlink name]
```

For example, if you want to create a symbolic link named `link_to_file.txt` for `file.txt`, you can run the following command:

```bash
ln -s file.txt link_to_file.txt
```

### Checking symbolic links

We can use the `ls -l` command to check the status of symbolic links. For example:

```bash
ls -l link_to_file.txt
```

The output will be something like this:

```bash
lrwxrwxrwx 1 user group 123 Jul 11 12:34 link_to_file.txt -> file.txt
```

This indicates that the `link_to_file.txt` is symlink and it points to the `file.txt` file.

## Managing dotfiles with Stow

The idea of managing dotfiles with Stow is simple. It is used to manage dotfiles by creating symbolic links (symlinks) from a central repository (like `$HOME/dotfiles`) to their appropriate locations in your `$HOME` directory. This allows you to keep your dotfiles organized and version-controlled.

The following sections will describe how to manage dotfiles with Stow in detail.

### Organizing dotfiles

We first create a dotfiles directory in our `$HOME` directory (i.e. `$HOME/dotfiles`). Inside it we create subdirectories for each package whose configuration files we want to manage.
Say that we want to manage dotfiles for Zsh and Zellij, we can create the following subdirectories called **package directories** in `$HOME/dotfiles`: `zsh` and `zellij`.

> You can actually have any name for the dotfiles directory. I use `dotfiles` in the example.

The folder structure of `$HOME/dotfiles` will look like the following:

```plaintext
Home
├── dotfiles/
│   ├── zsh
│   └── zellij
└── ...
```

Inside each subdirectory, we place the configuration files appropriately, maintaining the same directory structure for those dotfiles as they are in the `$HOME` directory. We called this **installation image**, which is the layout of dotfiles and folders required by a package. For example, inside `zsh` folder, we can directly create (or move in) `.zshrc` which holds the configurations for Zsh since the `.zshrc` file is always located in `$HOME/.zshrc`. For Zellij, the configuration files are located in `$HOME/.config/zellij/config.kdl` hence it must be placed in `zellij` folder like this: `$HOME/dotfiles/zellij/.config/zellij/config.kdl`.

Now the folder structure of `$HOME/dotfiles` will look like the following:

```plaintext
Home
├── dotfiles/
│   ├── zsh/
│   │   └── .zshrc
│   └── zellij/
│        └── .config/
│           └── zellij/
│               └── .config.kdl
└── ...
```

### Creating symlinks of dotfiles via Stow (stow dotfiles)

With the appropriate structure, Stow can understand these setting files and create symlinks in the appropriate locations. The Stow command for adding symlinks is:

```bash
stow package
```

Where `package` is the directory name of the package whose dotfiles are to be managed. In this example, it is `zsh` or `zellij`. We can now run the command under the `$HOME/dotfiles` directory:

```bash
cd ~/dotfiles
stow zsh
stow zellij
```

When the Stow command is run, it will create symlink in the `$HOME` directory pointing to the corresponding dotfiles of the packages in `$HOME/dotfiles` directory. For example, `$HOME/.zshrc` will be created as a symlink to `$HOME/dotfiles/zsh/.zshrc`. We can verify that `.zshrc` symlink via the `ls -l` command:

```bash
ls -l ~/.zshrc
```

The output will be something like this:

```bash
lrwxr-xr-x 1 fenglin fenglin 19 Apr  2 23:01 /Users/fenglin/.zshrc -> dotfiles/zsh/.zshrc
```

For the `zellij` package, the creation of the symlink will vary depending on whether `$HOME/.config/` exists. Stow attempts to create as few symlinks as possible. If there is no `$HOME/.config/` directory, Stow will create a `.config` symlink under `$HOME` directory that points to `$HOME/dotfiles/zellij/.config/`. This is called **tree folding**, since an entire subdirectory tree is folded into a single symlink.

On the other hand, if the `$HOME/.config/` directory is present (and there is no `zellij` subdirectory in `$HOME/.config/`), Stow will create a `zellij` symlink under `$HOME/.config/` directory that points to `$HOME/dotfiles/zellij/.config/zellij/`. It is best practice to create symlinks for dotfiles within `$HOME/.config/` rather than making `$HOME/.config` itself a symlink. Make sure you have a `.config` directory in your `$HOME` directory before you "stow" packages.

You can verify that the `$HOME/.config/zellij` symlink exists via the `ls -l` command:

```bash
ls -l ~/.config/zellij
```

You can see a `zellij` symlink pointing to `$HOME/dotfiles/zellij/.config/zellij/`:

```bash
lrwxr-xr-x 1 fenglin fenglin 33 Mar 27 00:04 /Users/fenglin/.config/zellij -> ../dotfiles/zellij/.config/zellij
```

The final `$HOME` directory structure will look like the following:

```plaintext
.
├── dotfiles/
│   ├── zsh/
│   │   └── .zshrc
│   └── zellij/
│       └── .config/
│           └── zellij/
│               └── .config.kdl
├── .zshrc
├── .config/
│   ├── zellij/
│   │   └── .config.kdl
│   └── ...
└── ...
```

### Stow directory and target directory

A **stow directory** is the root directory in which dotfiles of packages are stored. **Package directories** containing their dotfiles must reside in the stow directory. Default value of stow directory is the value of the environment variable `STOW_DIR` if set, or the current directory otherwise. In the example above, we ran the Stow command in `$HOME/dotfiles`,so the stow directory is defaults to `$HOME/dotfiles`. We can set the stow directory when running the Stow command using the `--dir` or `-d` option:

```bash
stow -d stow_dir package
```

Where `stow_dir` is the name of the stow directory.

The **target directory** is the root directory in which dotfiles wish to be symlinked. Default value of target directory is _the parent of the stow directory_. In the previous example, the target directory is `$HOME` since we ran the Stow command in `$HOME/dotfiles` and the stow directory defaults to `$HOME/dotfiles`. We can set the target directory when running the Stow command using the `--target` or `-t` option:

```bash
stow -t target_dir package
```

Where `target_dir` is the name of the target directory.

While you can specify the stow and target directories each time you run the Stow command, it is recommended to place your dotfiles repository in the `$HOME` directory and run the Stow command from within dotfiles repository. This way, the stow and target directories default to the dotfiles repository and `$HOME` directory, respectively, without needing to set them explicitly.

### Deleting symlinks of dotfiles created by Stow (unstow dotfiles)

Stow can also be used to remove symlinks that it has created. The command is shown below:

```bash
stow -D package
```

Where `-D` stands for "delete".

### Conflicts

When the Stow command is running, if a file or symlink exists in the target directory and has the same name as something Stow needs to create, and if the existing name is not a folded directory that can be split open, then a conflict will occur.

> The concept of splitting open is related to **tree unfolding**. For more details, please refer to [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html#Tree-unfolding).

Since version 2.0, Stow uses a two-phase algorithm that first scans for conflicts before performing any operations. If conflicts are found, they are displayed and Stow terminates without modifying the file system.

### Storing dotfiles in Git

Now, with Stow, managing dotfiles in a version control system is much easier. We can use Git to keep our dotfiles in sync with the repository.

## Prerequisite

- Install Stow: The easiest way to install Stow is through a package for your OS. For example:

  - MacOS: `brew install stow`.
  - Ubuntu: `sudo apt install stow`.

- Install packages (and their dependencies) related to the dotfiles:

  - [WezTerm](https://wezfurlong.org/wezterm/index.html): Install [wezterm](https://wezfurlong.org/wezterm/installation.html)
  - [Zsh](https://zsh.sourceforge.io): Built-in on MacOS/Linux. The configuration files of Zsh is `.zshrc`. Many packages add scripts to `.zshrc` for configuring their settings, including those I installed: [powerlevel10k](https://github.com/romkatv/powerlevel10k), [fzf](https://github.com/junegunn/fzf), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [tree](https://oldmanprogrammer.net/source.php?dir=projects/tree), [zoxide](https://github.com/ajeetdsouza/zoxide), [pyenv](https://github.com/pyenv/pyenv), and [nvm](https://github.com/nvm-sh/nvm).
  - [Vim](https://www.vim.org): Built-in on MacOS/Linux
  - [Zellij](https://zellij.dev): install [zellij](https://github.com/zellij-org/zellij/blob/main/docs/THIRD_PARTY_INSTALL.md)
  - [Zim](https://zimfw.sh/#install): Install [zim](https://github.com/zimfw/zimfw?tab=readme-ov-file#installation)
  - [Neovim](https://neovim.io): Install [neovim](https://github.com/neovim/neovim/blob/master/INSTALL.md), [ripgrep](https://github.com/BurntSushi/ripgrep), [fd](https://github.com/sharkdp/fd), and [lazygit](https://github.com/jesseduffield/lazygit)

## Usage (For me)

1. Clone this repository to `$HOME` directory:

   ```bash
   cd $HOME // or cd ~
   git clone https://github.com/fenglinchang996/dotfiles.git
   ```

   > We can actually clone the repository to any directory. However, it is recommended to clone to `$HOME` directory for simplicity.

2. Stow packages' dotfiles:

   ```bash
   cd $HOME/dotfiles
   stow nvim vim wezterm zellij zim zsh
   ```

   The conflicts may occur if the target directory contains a file or symlink with the same name as the dotfile being stowed. Resolve the conflicts and then re-run the Stow command.

3. Some packages require additional actions to apply the changes:
   - Zsh: Run `$SHELL` in the terminal to reload the `.zshrc`.
   - Zim: Run `zimfw update` to install Zim modules added in the `.zimrc`.
