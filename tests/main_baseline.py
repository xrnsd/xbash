#!/usr/bin/env python3
"""Historical baseline reproductions; run before the staged startup repairs.
Uses temporary HOME and stubs external writes. Does not execute module/test.module.
"""
import json, os, pathlib, subprocess, tempfile

repo=pathlib.Path(__file__).resolve().parents[1]
root=pathlib.Path(tempfile.mkdtemp(prefix='main-audit-'))
bash=os.environ.get('XBASH_TEST_BASH', '/opt/homebrew/bin/bash')
results=[]
def run(name, body, interactive=True, fixture=None):
    home=root/name; home.mkdir()
    env={'PATH':'/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin','HOME':str(home),'USER':'myname','TERM':'dumb','LC_ALL':'C'}
    script=(fixture or '')+'\n'+body
    p=subprocess.run([bash,'--noprofile','--norc']+(['-i'] if interactive else [])+['-c',script],env=env,text=True,capture_output=True,timeout=10)
    results.append({'case':name,'code':p.returncode,'out':p.stdout.strip(),'err':p.stderr.strip()})
    print(json.dumps(results[-1],ensure_ascii=False))

run('real-module-counts',r'''
declare -A counts
launchctl() { ((counts[launchctl]+=1)); }
readlink() { echo /Users/myname/xbash/module/base/bash_input.module; }
source() {
 ((counts["$1"]+=1))
 case "$1" in
 */config/user/*) PROMPT_COMMAND='ftSetBashPs1ByGitBranch;history -a'; return 0;;
 */myname.packaging.module) return 0;;
 esac
 builtin source "$@"
}
source /Users/myname/xbash/module/main.module
for f in common.methods auto/auto.methods git/git.methods; do printf '%s=%s\n' "$f" "${counts[/Users/myname/xbash/module/$f]}"; done
printf 'launchctl=%s\n' "${counts[launchctl]}"
source /Users/myname/xbash/module/main.module
printf 'common_reloaded=%s; launchctl_reloaded=%s\n' "${counts[/Users/myname/xbash/module/common.methods]}" "${counts[launchctl]}"
''')

# Execute the real main control flow with controlled modules, all writes in HOME.
setup=r'''
mkdir -p "$HOME/modules"
for f in auto git user packaging learn; do printf 'echo LOADED_%s\n' "$f" > "$HOME/modules/$f"; done
echo 'ftEcho() { echo FTECHO_READY; }; echo LOADED_common' > "$HOME/modules/common"
echo 'input marker' > "$HOME/modules/input"
source() {
 case "$1" in
 */config/common.config)
   rFilePathXbashModuleCommon="$HOME/modules/common"
   rFilePathXbashModuleAuto="$HOME/modules/auto"
   rFilePathXbashModuleGit="$HOME/modules/git"
   rDirPathXbashModuleUser="$HOME/modules"
   rFilePathXbashModuleUser="$HOME/modules/user"
   rFilePathXbashPackagingUser="$HOME/modules/packaging"
   rFilePathXbashModuleInput="$HOME/modules/input"
   rFilePathXbashModuleLearn="$HOME/modules/learn"
   return 0;;
 */config/user/*) [[ -f "$HOME/user-config" ]] && builtin source "$HOME/user-config"; return 0;;
 esac
 builtin source "$@"
}
'''
run('source-error-is-masked',r'''
echo 'echo COMMON_FAILED; return 23' > "$HOME/modules/common"
source /Users/myname/xbash/module/main.module
printf 'main_status=%s\n' "$?"
''',fixture=setup)
run('inputrc-directory-is-deleted',r'''
mkdir "$HOME/.inputrc"; echo user-data > "$HOME/.inputrc/keep"
source /Users/myname/xbash/module/main.module >/dev/null
[[ -L "$HOME/.inputrc" ]] && echo inputrc_is_link
[[ ! -e "$HOME/.inputrc/keep" ]] && echo user_data_deleted
''',fixture=setup)
run('config-before-functions',r'''
echo 'ftEcho CONFIG_NEEDS_HELPER' > "$HOME/user-config"
source /Users/myname/xbash/module/main.module >/dev/null
printf 'main_status=%s\n' "$?"
''',fixture=setup)
run('path-reload-growth',r'''
source /Users/myname/xbash/module/main.module >/dev/null
source /Users/myname/xbash/module/main.module >/dev/null
count=0; IFS=: read -r -a entries <<< "$PATH"
for entry in "${entries[@]}"; do [[ "$entry" == /Users/myname/.local/bin ]] && ((count+=1)); done
printf 'local_bin_entries=%s\n' "$count"
''',fixture=setup)
run('missing-core-returns-success',r'''
rm "$HOME/modules/common"
source /Users/myname/xbash/module/main.module
printf 'main_status=%s\n' "$?"
''',fixture=setup)
run('noninteractive-skips-everything',r'''
source /Users/myname/xbash/module/main.module
printf 'path_variable=%s\n' "${dirPathHomeXbash-unset}"
''',interactive=False)
run('path-item-splitting',r'''
PATH='/usr/bin:/Applications/Android SDK/bin:/bin'
newList=($(echo "$PATH" | sed 's?:? ?g'))
printf 'count=%s\n' "${#newList[@]}"
printf '<%s>\n' "${newList[@]}"
''',interactive=False)
run('prompt-waits-for-git',r'''
source /Users/myname/xbash/module/git/git.methods
isUseCustomPS1=true; isLoadGitCompletion=1
git() { sleep 0.3; echo '* demo'; }
start=$EPOCHREALTIME
ftSetBashPs1ByGitBranch >/dev/null
printf '%s %s\n' "$start" "$EPOCHREALTIME"
''',interactive=False)

expected=[['common.methods=2','auto/auto.methods=2','git/git.methods=2','launchctl=3','common_reloaded=4; launchctl_reloaded=6'],['COMMON_FAILED','LOADED_auto','LOADED_user','LOADED_learn','main_status=0'],['inputrc_is_link','user_data_deleted'],['main_status=0'],['local_bin_entries=2'],['main_status=0'],['path_variable=unset'],['count=4','<SDK/bin>']]
for case,terms in zip(results,expected):
    assert case['code']==0,case
    for term in terms: assert term in case['out'],(case,term)
assert 'ftEcho: command not found' in results[3]['err'],results[3]
assert 'LOADED_auto' not in results[5]['out'],results[5]
start,end=map(float,results[-1]['out'].split())
assert end-start >= .29
results[-1]['elapsed_seconds']=round(end-start,3)
(root/'results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2))
print('Evidence directory:', root)
print('PASS: 9 main-specific cases, all evidence assertions passed')
