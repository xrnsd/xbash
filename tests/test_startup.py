#!/usr/bin/env python3
"""Run real startup code with disposable config, HOME and external command stubs."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
BASH = os.environ.get('XBASH_TEST_BASH', shutil.which('bash'))


class StartupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='xbash-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.home = self.root / 'home with spaces'
        self.home.mkdir()
        self.repo = self.root / 'repo with spaces'
        for directory in ['module', 'config']:
            shutil.copytree(REPO / directory, self.repo / directory,
                            ignore=shutil.ignore_patterns('user', '__pycache__', '*.so'))
        (self.repo / 'config/user').mkdir()
        (self.repo / 'module/user').mkdir()
        self.config = self.repo / 'config/user/test.config'
        self.config.write_text('isUseCustomPS1=true\nPROMPT_COMMAND="ftSetBashPs1ByGitBranch;history -a"\n')
        self.user = self.repo / 'module/user/test.module'
        self.user.write_text('''
_ftXbashLoadModule "$rFilePathXbashModuleCommon" || return $?
_ftXbashLoadModule "$rFilePathXbashModuleAuto" || return $?
_ftXbashLoadModule "$rFilePathXbashModuleGit" || return $?
ftAutoConfigOpenAIEnv() { launchctl setenv AUDIT value; }
''')
        (self.repo / 'module/user/test.packaging.module').write_text("alias xdf='ftDf'\n")

    def shell(self, body, interactive=True, env=None, adapter=False):
        environment = dict(PATH='/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin',
                           HOME=str(self.home), USER='test', TERM='dumb', LC_ALL='C',
                           TEST_REPO=str(self.repo), EVENTS=str(self.root / 'events'))
        environment.update(env or {})
        prelude = '''
launchctl() { echo launchctl >> "$EVENTS"; }
sudo() { echo unexpected_sudo >> "$EVENTS"; return 111; }
source() {
    local file="$1"; shift
    case "$file" in
      */config/common.config)
        userName=test
        export dirPathHome="$HOME" dirPathHomeXbash="$TEST_REPO"
        export dirPathHomeTools="$HOME/tools"
        export dirPathHomeXbashConfig="$TEST_REPO/config"
        export dirPathHomeXbashConfigUser="$TEST_REPO/config/user"
        file="$TEST_REPO/config/common.config";;
    esac
    echo "${file#"$TEST_REPO/"}" >> "$EVENTS"
    builtin source "$file" "$@"
}
'''
        if not adapter:
            prelude = '''
launchctl() { echo launchctl >> "$EVENTS"; }
sudo() { echo unexpected_sudo >> "$EVENTS"; return 111; }
source() { local file="$1"; shift; echo "${file#"$TEST_REPO/"}" >> "$EVENTS"; builtin source "$file" "$@"; }
'''
        p = subprocess.run([BASH, '--noprofile', '--norc'] + (['-i'] if interactive else []) + ['-c', prelude + body],
                           env=environment, text=True, capture_output=True, cwd=self.home, timeout=15)
        self.assertEqual(p.returncode, 0, p.stderr + p.stdout)
        return p

    def test_inputrc_preserved(self):
        for kind in ['file', 'directory', 'correct-link', 'other-link', 'broken-link', 'missing']:
            with self.subTest(kind=kind):
                path = self.home / '.inputrc'
                if path.is_symlink() or path.is_file(): path.unlink()
                elif path.is_dir(): shutil.rmtree(path)
                target = self.repo / 'module/base/bash_input.module'
                if kind == 'file': path.write_text('user inputrc')
                elif kind == 'directory': path.mkdir(); (path / 'keep').write_text('user data')
                elif kind == 'correct-link': path.symlink_to(target)
                elif kind == 'other-link': path.symlink_to(self.config)
                elif kind == 'broken-link': path.symlink_to(self.home / 'absent')
                before = os.readlink(path) if path.is_symlink() else None
                self.shell('source "$TEST_REPO/module/main.module"')
                if before is not None: self.assertEqual(os.readlink(path), before)
                elif kind == 'file': self.assertEqual(path.read_text(), 'user inputrc')
                elif kind == 'directory': self.assertEqual((path / 'keep').read_text(), 'user data')
                else: self.assertFalse(path.exists() or path.is_symlink())

    def test_context_and_symlink(self):
        (self.home / '.bashrc').symlink_to(self.repo / 'module/main.module')
        p = self.shell('source "$HOME/.bashrc" >/dev/null; printf "%s\\n" "$dirPathHomeXbash" "$rDirPathXbash" "$rDirPathUserHome" "$rUserName"', env={'SUDO_USER':'someone_else'})
        self.assertEqual(p.stdout.splitlines(), [str(self.repo), str(self.repo), str(self.home), 'test'])

    def test_child_context_is_revalidated(self):
        self.user.write_text('true\n')
        p = self.shell("""source "$TEST_REPO/module/main.module" >/dev/null; export -p | grep -q " rEnvValInited=" && exit 7; "$BASH" --noprofile --norc -ic 'source "$TEST_REPO/module/main.module" >/dev/null; [[ "$rDirPathUserHome" == "$HOME" ]]'""")
        self.assertNotIn('readonly variable', p.stderr)

    def test_noninteractive_skips(self):
        p = self.shell('source "$TEST_REPO/module/main.module"; echo "${dirPathHomeXbash-unset}"', interactive=False)
        self.assertEqual(p.stdout.strip(), 'unset')

    def test_config_has_helpers_and_false_tail_is_compatible(self):
        self.config.write_text('declare -F ftEcho >/dev/null || return 23\n[[ -n "" ]]\n')
        self.shell('source "$TEST_REPO/module/main.module"; [[ $? == 0 ]]')

    def test_required_failures_stop_dependencies(self):
        for contents in ['return 23\n', 'if then\n']:
            with self.subTest(contents=contents):
                (self.repo / 'module/common.methods').write_text(contents)
                p = self.shell('source "$TEST_REPO/module/main.module"; echo "status=$?"')
                self.assertNotIn('status=0', p.stdout)
                events = (self.root / 'events').read_text().splitlines()
                self.assertNotIn('module/auto/auto.methods', events)
        (self.repo / 'module/common.methods').unlink()
        p = self.shell('source "$TEST_REPO/module/main.module"; echo "status=$?"')
        self.assertNotIn('status=0', p.stdout)

    def test_missing_config_is_noninteractive_failure_without_writes(self):
        self.config.unlink()
        p = self.shell('source "$TEST_REPO/module/main.module"; echo "status=$?"')
        self.assertNotIn('status=0', p.stdout)
        self.assertFalse(self.config.exists())

    def test_config_explicit_failure_protocol(self):
        self.config.write_text('xbashConfigStatus=1\nreturn 1\n')
        p = self.shell('source "$TEST_REPO/module/main.module"; echo "status=$?"')
        self.assertIn('status=1', p.stdout)

    def test_missing_optional_module_is_skipped(self):
        self.user.write_text('true\n')
        (self.repo / 'module/auto/auto.methods').unlink()
        self.shell('source "$TEST_REPO/module/main.module"; [[ $? == 0 ]]')

    def test_definitions_load_once_across_refreshes(self):
        self.shell('source "$TEST_REPO/module/main.module"; source "$TEST_REPO/module/main.module"')
        events = (self.root / 'events').read_text().splitlines()
        for file in ['module/common.methods', 'module/auto/auto.methods', 'module/git/git.methods', 'module/learn/common.methods', 'module/user/test.module']:
            self.assertEqual(events.count(file), 1, file)

    def test_cycle_and_failed_module_retry(self):
        extra = self.repo / 'module/cycle.module'
        extra.write_text('_ftXbashLoadModule "${BASH_SOURCE[0]}"\n')
        self.shell('source "$TEST_REPO/module/main.module"; _ftXbashLoadModule "$TEST_REPO/module/cycle.module"; [[ $? != 0 ]] && [[ ${_xbash_module_states[$TEST_REPO/module/cycle.module]} == failed ]]')
        extra.write_text('return 0\n')
        self.shell('source "$TEST_REPO/module/main.module"; _ftXbashLoadModule "$TEST_REPO/module/cycle.module"; [[ ${_xbash_module_states[$TEST_REPO/module/cycle.module]} == loaded ]]')

    def test_path_helpers_preserve_literal_items(self):
        p = self.shell('''source "$TEST_REPO/module/base/environment.module"
PATH=':/a path/bin:*literal:/opt/sdk-cache::'
ftXbashPathAdd '/a path/bin'
ftXbashPathAdd '*literal'
ftXbashPathRemove '/missing'
printf '%s\\n' "$PATH"
ftXbashPathRemove '*literal'
printf '%s\\n' "$PATH"
PATH=''; ftXbashPathAdd '/first'; printf '%s\\n' "$PATH"
''', interactive=False)
        self.assertEqual(p.stdout.splitlines(), [':/a path/bin:*literal:/opt/sdk-cache::', ':/a path/bin:/opt/sdk-cache::', ':/first'])

    def test_environment_refresh_removes_only_owned_paths(self):
        self.config.write_text('''ftXbashApplyUserEnvironment() {
    if [[ "${FEATURE:-true}" == true ]]; then ftXbashPathAdd '/feature path/bin' || return $?; fi
    return 0
}
''')
        self.shell('''source "$TEST_REPO/module/main.module"
source "$TEST_REPO/module/main.module"
source "$TEST_REPO/module/main.module"
[[ "$PATH" == *'/feature path/bin'* ]] || exit 2
FEATURE=false
source "$TEST_REPO/module/main.module"
[[ "$PATH" != *'/feature path/bin'* ]] || exit 3
[[ "$PATH" != *"$HOME/.local/bin:$HOME/.local/bin"* ]] || exit 4
''')

    def test_template_does_not_run_system_changes_on_startup(self):
        self.config.write_text((self.repo / 'module/example/user.config.example').read_text())
        self.shell('source "$TEST_REPO/module/main.module"; [[ $? == 0 ]]')
        self.assertNotIn('unexpected_sudo', (self.root / 'events').read_text())

    def test_prompt_preserves_callbacks_without_duplication(self):
        p = self.shell('''PROMPT_COMMAND=('echo user_hook' 'printf "array;literal\\n"')
source "$TEST_REPO/module/main.module"
source "$TEST_REPO/module/main.module"
isUseCustomPS1=false
_ftXbashPromptDispatch
''')
        self.assertEqual(p.stdout.count('user_hook'), 1)
        self.assertEqual(p.stdout.count('array;literal'), 1)

    def test_missing_git_keeps_a_safe_prompt(self):
        self.user.write_text('true\n')
        (self.repo / 'module/git/git.methods').unlink()
        p = self.shell('source "$TEST_REPO/module/main.module"; _ftXbashPromptDispatch')
        self.assertNotIn('command not found', p.stderr)

    def test_git_prompt_normal_unborn_detached_and_outside(self):
        self.shell('''source "$TEST_REPO/module/main.module"
mkdir project; cd project
git init -q -b audit
ftSetBashPs1ByGitBranch >/dev/null
[[ "$PS1" == *'audit'* ]] || exit 2
git -c user.name=Audit -c user.email=audit@example.invalid -c commit.gpgsign=false commit --allow-empty -qm initial
git checkout -q --detach HEAD
ftSetBashPs1ByGitBranch >/dev/null
[[ "$PS1" == *'detached:'* ]] || exit 3
cd ..
ftSetBashPs1ByGitBranch >/dev/null
[[ "$PS1" != *'branchName'* ]] || exit 4
''')

    def test_completion_ignores_inherited_marker(self):
        self.shell('''source "$TEST_REPO/module/main.module"
export isLoadGitCompletion=1
git() { [[ "$1" == symbolic-ref ]] && echo audit; }
ftSetBashPs1ByGitBranch >/dev/null
complete -p git >/dev/null && declare -F __git_main >/dev/null
''')

    def test_refresh_overrides_apply_after_option_defaults(self):
        self.config.write_text('''isEnableConda=false
ftXbashApplyUserEnvironment() { printf 'conda=%s\\n' "$isEnableConda"; }
''')
        p = self.shell('''source "$TEST_REPO/module/main.module"
ftResetXbash --conda
[[ ! ${isResetXbash+x} && ! ${_xbash_refresh_overrides+x} ]] || exit 2
''')
        self.assertEqual(p.stdout.splitlines(), ['conda=false', 'conda=true'])

    def test_force_reload_is_distinct_from_refresh(self):
        self.shell('''source "$TEST_REPO/module/main.module"
ftResetXbash
ftResetXbash --reload
''')
        events = (self.root / 'events').read_text().splitlines()
        self.assertEqual(events.count('module/common.methods'), 2)
        self.assertEqual(events.count('module/user/test.module'), 2)
        self.assertEqual(events.count('launchctl'), 0)

    def test_failure_can_be_fixed_and_retried(self):
        self.config.write_text('xbashConfigStatus=1; return 1\n')
        self.shell('''source "$TEST_REPO/module/main.module"
[[ "$?" == 1 && "$_xbash_startup_state" == failed ]] || exit 2
printf 'isUseCustomPS1=false\\n' > "$TEST_REPO/config/user/test.config"
ftResetXbash
[[ "$?" == 0 && "$_xbash_startup_state" == ready ]] || exit 3
''')

    def test_explicit_session_sync_and_failures(self):
        self.shell('''source "$TEST_REPO/module/main.module"
ftResetXbash
export OPENAI_BASE_URL=stub OPENAI_API_KEY=stub OPENAI_MODEL=stub
ftResetXbash --sync-session
''')
        self.assertEqual((self.root / 'events').read_text().splitlines().count('launchctl'), 3)
        self.shell('''source "$TEST_REPO/module/main.module"
export OPENAI_BASE_URL=stub OPENAI_API_KEY=stub OPENAI_MODEL=stub
launchctl() { return 23; }
ftResetXbash --sync-session
[[ $? == 23 && ! ${_xbash_refresh_overrides+x} ]]
''')

    def test_explicit_system_action_and_refresh_directory(self):
        self.config.write_text('''ftXbashApplySystemConfig() { echo SYSTEM_ACTION; return 23; }
''')
        p = self.shell('''source "$TEST_REPO/module/main.module"
before=$PWD
ftResetXbash --system-config
[[ $? == 23 && "$PWD" == "$before" && ! ${isResetXbash+x} ]]
''')
        self.assertEqual(p.stdout.strip(), 'SYSTEM_ACTION')


if __name__ == '__main__':
    unittest.main(verbosity=2)
