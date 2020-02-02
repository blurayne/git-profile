# GIT Profiles

This is currently is alpha-grade quality. Be careful when using it!

## Abstract

GIT Profiles solve the issue of GIT having problems on handling multiple user accounts:

- It is not possible to distinguish between a private and company account using *github.com* or *gitlab.com*:
  - GIT uses git-bash for SSH and authenticates always by SSH user `git` and the SSH public key assigned to an account
  - So selecting the right SSH key by host-name only is NOT possible!
  - 
- You often end up having wrongg `user.name` and `user.email` set up
- The [IfInclude](<https://git-scm.com/docs/git-config#_includes>) config directive does only provide a partly solution here

We solve that problems by introducing the concept of *profiles* and let them:

- match by remote repository
- match by local working path (extending `includeIf`)

We wrap communication with remote repositories to a `GIT_SSH`-*wrapper*.

- Using a *profile* we can enforce a single SSH-key for mapping agains git-bash.
- We add global profile configurations that we link to local repositories by using global commit-hooks and git config *include*-directory.

## Usage Example

```bash
 usage: git-profile <COMMAND> [<argument>,…]
```

```bash
# default configuration
git profile init
git profile config default user.name "John Doe"
git profile config default user.email "jane@doe.xyz"

# add profile for your company
git profile add my-company "ACME"
git profile config my-company user.name "John Doe"
git profile config my-company user.email "john.doe@my-company.com"
git profile add-ssh-identity my-company ~/.config/ssh/my-company
git profile add-local-match my-company "~/Projects/My Company/*"
git profile add-remote-match my-company "gitlab.com:my-company/*"

# add your private project
git profile add dark-project "FOSS"
git profile config dark-project uInstallationser.name "H4xx0r John"
git profile config dark-project user.email "user@hashmail.com"
git profile add-remote-match dark-project "gitlab.com:h4xx0r.john/*"
git profile add-ssh-identity dark-project  ~/.config/ssh/personal
```

## Installation

### Automatic

Currently in *alpha*. Use the `Makefile` provided:

```bash
make install
```

### Manual 

1. Put everything inside .`./bin`to `~/.local/bin/*` and make `git-profile*` executable.

2. Install the git commit hooks to `~/.config/git/hooks` and make them executable (merge with existing files!)

3. Ensure you environment variable `GIT_SSH`    ``~/.profile`` 

   ```bash
   export GIT_SSH="${HOME}/.local/bin/git-profile-ssh-wrapper"`
   ```

## Commit Hooks

### post-checkout

- get remote repositories
- get include pathes from remote repositories
- check if includes are already included (using includeif pathes)
- if not included in config include it 

### pre-commit / pre-receive

- same as post-checkout
- if config did change abort

### pre-commit

- show which 

## Commands

```
  add <profile-id> <profile-full-name>
      Add a New Profile to Registry and Create Profile Config to Include
      (/home/ctang/.config/git/profile/<profile-name>)

  add-local-match <repo-path>
      Add a Local Pathy Matching Wildcard 
      Pathes always have to start widrwxr-xr-x  ctang  ctang      -   2 hours ago     🗁  hooks/
th slash ('/'') 

  add-remote-match <profile> <repo-path>
      Add a Remote Repository Matching Wildcard 
      Defaults to SSH unless protocol is specified.
      <protocol>://<host>:<repo-path> forceful)
        e.g. "gitlab.com:my-company/group/supgroup/repo"
        e.g. "gitlab.com:my-company/group/supgroup/repo"
      Wildcards with extended globbing are supported (see http://man7.org/linux/man-pages/man7/glob.7.html)

  auto-select <true|false>
      Use Profile Auto-Selection?

  config <profile-id> [options] <object-path> <value>
  config <profile-id> [options] <object-path> 
      Wrapper to git config -f <profile-config>

  edit [<profile-id>]
      Edit Profiles or Locally Included Config

  init
      Add and Set Default Profile ID to 'default'
      Set 'core.profile-auto-select' Profile to true

  get-default
      Get Default Profile ID

  list-ids
      List Profile IDs

  get-by-local <path>
      Get Profile ID Auto-Selection by a Local Path

  get-by-remote <host:path>
      Get Profile ID Auto-Selection by Remote Repository URL

  get-config-file <profile-id>drwxr-xr-x  ctang  ctang      -   2 hours ago     🗁  hooks/

      Get Profile Config File to Include in Local Repo's Git Config

  get-name <profile-id>
      Get a Profile's Full Name

  remove <profile-id>
  rm <profile-id>
      Remove a Profile

  set-default <profile-id>
      Set Default Profile ID

  test-remote <profile-id> <remote-host>
      Test Remote with git@<remote-host>!

      Note:
        git often points to GIT bash on host, user auth  is done
        by SSH key matching. Use SSH config for extended SSH config!

  help
      Display Command Usage / Help

```

## TODO

- [ ] HTTP(S) support
- [ ] First time init has a bug with wrong display
## Trackback
- [Git Hooks documentation](https://git-scm.com/docs/githooks)

