# Brainstorming – Version 2

Refactor using extended `includeIf` [conditional-includes](https://git-scm.com/docs/git-config) only.

- A global config we derive from instead if attaching config locally
- Global git config should include a `profiles` file
- Which in return again includes the profiles

```
; include if $GIT_DIR is /path/to/foo/.git
[includeIf "match-local:~/Projects/my-company"]
	path = profile/my-company
[includeIf "match-remote:gitlab.com/my-company"]
	path = profile/my-domain
	
[includeIf "match-local:~/Projects/my-domain"]
	path = profile/my-domain
[includeIf "match-remote:gitlab.com/john.doe"]
	path = profile/my-domain
```

- Then we probably only would need to maintain 

```bash
##
# Match string by glob expression
# Mind extglob and nullglob options!
#
# arg1: string  glob expression 
# arg2: string  text to test against
globmatch () { 
	case "${2}" in 
		${1}) return 0;; 
	esac
	return 1
}

### does already include config?
get_gitdir_includeif() {
   local working_path="$1"
   working_path="${working_path%/}/"
   while read match; do
     dir="${match#includeif.gitdir:}"
     dir="${dir%.path}"
     current_path="$(realpath "${key}" 2>/dev/null|| true)"
     if [[ -z "$current_path" ]] || [[ ! -d "$current_path" ]]; then
        >&2 echo "$current_path is does not exist or is no directory. please fix!"
        continue
     fi
     if globmatch "$current_path/*" "${working_path}"; then
       config="$(git config -f x --get "${match}")"
       if [[ ! -e "$config" ]]; then
          >&2 echo "$config is does not exist or is no directory. please fix!"
          continue
       fi
	   echo $config
       return 0
     fi
   done <  <(git config -f x -l --name-only | grep -E '^includeif.gitdir:.+\.path$' | tail -r)
}

config_includeif="$(get_gitdir_includeif "$PWD")"
if [[ -z "$config_includeif" ]]; then
   >&2 echo "using $config_includeif"
fi

local ssh_cmd=("$(which ssh)")
ssh_key="$(git config -f config --get 'ssh-identity' 2>/dev/null || true)"
if [[ -n "${ssh_key}" ]]; then
		ssh_cmd+=( \
			-o IdentitiesOnly=yes -o "IdentityFile=${only_ssh_key}" \
			-i "${only_ssh_key}" \
		)
	fi

	log "GIT_SSH using profile (${profile_id}): ${ssh_cmd[@]} ${@}"	
	"${ssh_cmd[@]}" "${@}"
}
```

