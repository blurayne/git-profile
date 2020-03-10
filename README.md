# GIT Profiles

This is currently is alpha-grade quality. Be careful when using it!

## Abstract

GIT Profiles solves the issue of GIT having problems on handling multiple user accounts:

- It is not possible to distinguish between a private and company account using one host like *github.com* or *gitlab.com*:
  - GIT uses git-bash for SSH and authenticates always by SSH user `git` and the SSH public key assigned to an account
  - So selecting the right SSH key by host-name only is NOT possible!
- You often end up having setup the wrong `user.name` and `user.email` 
- The [IfInclude](<https://git-scm.com/docs/git-config#_includes>) config directive does only provide a partly solution here

We solve that problems by introducing the concept of *profiles* and let them match

- by remote repository
- by local working path (extending `includeIf`)

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
git profile add-ssh-identity default ~/.ssh/id_rsa # not required

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
    (~/.config/git/profile/<profile-name>)

add-local-match <repo-path>
    Add a Local Pathy Matching Wildcard 
    Pathes always have to start with slash ('/') 

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

get-config-file <profile-id>
    Get Profile Config File to Include in Local Repo's Git Config

get-name <profile-id>
    Get a Profile's Full Name

remove <profile-id>
rm <profile-id>
    Remove a ProfileGIT_SSH_DEBUG="${GIT_SSH_DEBUG:-0}"

set-default <profile-id>
    Set Default Profile ID

test-remote <profile-id> <remote-host>
    Test Remote with git@<remote-host>!
    Note: git often points to GIT bash on host, user auth  is done
          by SSH key matching. Use SSH config for extended SSH config!

help
    Display Command Usage / Help

```

### Debug

```bash
# git
export GIT_TRACE=1
export GIT_CURL_VERBOSE=1 
export GIT_SSH_COMMAND="ssh -vvv" # attention before replacing git-profile-ssh-wrapper!	

# git-profile: GIT_SSH_DEBUG 2 => "ssh -v"  3 => "-vv"  4 => "-vvv"
export GIT_SSH_DEBUG=1 
```

## TODO

- [ ] HTTP(S) support
## Trackback
- [Git Hooks documentation](https://git-scm.com/docs/githooks)

