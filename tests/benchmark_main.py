#!/usr/bin/env python3
"""Isolated main/prompt timing; user options and external writes are stubbed."""
import json, os, pathlib, statistics, subprocess, tempfile
repo = pathlib.Path(__file__).resolve().parents[1]
bash = os.environ.get('XBASH_TEST_BASH', '/opt/homebrew/bin/bash')
samples=[]
with tempfile.TemporaryDirectory(prefix='xbash-benchmark-') as home:
    for _ in range(7):
        script = r'''
launchctl() { echo launchctl >> "$BENCH_EVENTS"; }
readlink() { printf '%s/module/base/bash_input.module\n' "$BENCH_REPO"; }
git() {
 echo git >> "$BENCH_EVENTS"
 case "$1" in
 branch) echo '* benchmark';;
 symbolic-ref) echo benchmark;;
 rev-parse) echo abc1234;;
 -v|--version) echo 'git version 2.39.0';;
 esac
}
source() {
 printf "source:%s\n" "$1" >> "$BENCH_EVENTS"
 case "$1" in
 */config/user/*) isUseCustomPS1=true; PROMPT_COMMAND='ftSetBashPs1ByGitBranch;history -a'; return 0;;
 */user/*.packaging.module) return 0;;
 esac
 builtin source "$@"
}
start=$EPOCHREALTIME
source "$BENCH_REPO/module/main.module" >/dev/null
status=$?
loaded=$EPOCHREALTIME
ftSetBashPs1ByGitBranch >/dev/null
first=$EPOCHREALTIME
ftSetBashPs1ByGitBranch >/dev/null
printf '%s %s %s %s %s\n' "$status" "$start" "$loaded" "$first" "$EPOCHREALTIME"
'''
        env={'PATH':'/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin','HOME':home,'USER':os.environ.get('USER','myname'),'TERM':'dumb','LC_ALL':'C','BENCH_REPO':str(repo),'BENCH_EVENTS':str(pathlib.Path(home)/f'events-{_}')}
        p=subprocess.run([bash,'--noprofile','--norc','-ic',script],env=env,cwd=repo,text=True,capture_output=True,timeout=15)
        values=p.stdout.strip().splitlines()[-1].split()
        assert values[0]=='0',p.stderr
        t=list(map(float,values[1:]))
        samples.append(dict(zip(['source_ms','first_prompt_ms','steady_prompt_ms'],[round((t[i+1]-t[i])*1000,3) for i in range(3)])))
        events=pathlib.Path(env['BENCH_EVENTS']).read_text().splitlines()
counts={'common_definition_loads':sum(line=='source:'+str(repo/'module/common.methods') for line in events),'git_queries':events.count('git'),'session_writes':events.count('launchctl')}
summary={k:{'median':round(statistics.median(s[k] for s in samples),3),'max':max(s[k] for s in samples)} for k in samples[0]}
print(json.dumps({'runs':len(samples),'summary':summary,'counts_per_run':counts,'samples':samples},indent=2))
