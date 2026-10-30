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
source "$rFilePathXbashModuleCommon"
source "$rFilePathXbashModuleAuto"
source "$rFilePathXbashModuleGit"
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


if __name__ == '__main__':
    unittest.main(verbosity=2)
