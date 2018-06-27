# -*- coding: utf-8 -*-

import os
from os.path import expanduser, expandvars, dirname, join, isfile, isdir
from pathlib import Path
import shlex

class GenClangConf():
    work_dir = ''
    clang_file = ''
    scm_dirs = ['.git', '.svn', '.hg']
    clang_conf_names = ['.clang_complete', '.clang']

    def __init__(self):
        self.work_dir = os.getcwd()

    def get_clang_conf(self):
        clang = self._find_scm_conf()
        if not clang:
            clang = self._find_conf(self.clang_conf_names)

        # print(self.work_dir)
        return clang, self.work_dir

    def gen_clang_conf(self, vim):
        scm_dir = self._find_scm_dir()
        if not scm_dir:
            scm_dir = os.getcwd()
            scm_root_dir = scm_dir
        else:
            scm_root_dir = str(Path(scm_dir).parent)

        self.clang_file = join(scm_dir, '.clang')
        clang = []

        ignore_dirs = vim.eval('g:gen_clang_conf#ignore_dirs')
        ignore_dirs += self.scm_dirs

        for root, dirs, files in os.walk(scm_root_dir):
            for ignore_dir in ignore_dirs:
                is_ignore_dir = 0
                if root.lower().endswith(ignore_dir):
                    dirs[:] = []
                    is_ignore_dir = 1
                    break
            if is_ignore_dir == 0:
                for file in files:
                    is_added = 0
                    for suffix in ['.c', '.cpp', '.h']:
                        if file.endswith(suffix):
                            is_added = 1
                            clang.append('-I' + os.path.relpath(root, scm_root_dir))
                            break
                    if is_added:
                        break
        try:
            with open(self.clang_file, 'w') as f:
                for line in clang:
                    f.write(line + "\n")
            return 1
        except Exception as e:
            print('Save clang_file Failed: ' + self.clang_file + str(e))
        return 0
    
    def clear_clang_conf(self):
        scm_dir = self._find_scm_dir()
        if not scm_dir:
            print("not found scm dir, ignore")
            return

        ext_file = join(scm_dir, '.clang_ext')
        self.clang_file = join(scm_dir, '.clang')
        try:
            os.remove(self.clang_file)
        except Exception as e:
            pass
        try:
            os.remove(ext_file)
        except Exception as e:
            pass

    def get_clang_ext_path(self):
        scm_dir = self._find_scm_dir()
        if not scm_dir:
            self._find_conf(self.clang_conf_names)
            if not self.clang_file:
                print("not found scm dir and .clang file, ignore")
                return ''
            else:
                scm_dir = dirname(self.clang_file)

        ext_file = join(scm_dir, '.clang_ext')
        return ext_file

    def _find_scm_dir(self):
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in self.scm_dirs:
                scm_dir = join(str(d), name)
                if isdir(scm_dir):
                    return scm_dir
        return ''

    def _read_conf(self, conf_file):
        try:
            with open(conf_file) as f:
                args = shlex.split(' '.join(f.readlines()))
                args = [expanduser(expandvars(p)) for p in args]
                return args
        except Exception as e:
            print('Parse Failed: ' + conf_file)
        return []

    def _find_scm_conf(self):
        self.clang_file = ''
        scm_dir = self._find_scm_dir()

        if scm_dir:
            ext_file = join(scm_dir, '.clang_ext')
            self.clang_file = join(scm_dir, '.clang')
            clang = []
            if isfile(ext_file):
                clang = self._read_conf(ext_file)
            if isfile(self.clang_file):
                clang += self._read_conf(self.clang_file)
            self.work_dir = str(Path(scm_dir).parent)
            return clang

        return []

    def _find_conf(self, names):
        self.clang_file = ''
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in names:
                self.clang_file = join(str(d), name)
                if isfile(self.clang_file):
                    break
                self.clang_file = ''
            if self.clang_file:
                break

        if self.clang_file:
            clang = []
            self.work_dir = dirname(self.clang_file)
            # add clang_ext first
            ext_file = join(self.work_dir, '.clang_ext')
            if isfile(ext_file):
                clang += self._read_conf(ext_file)
            clang += self._read_conf(self.clang_file)
            return clang

        return []

if __name__ == '__main__':
    import vim
    test = GenClangConf()
    ret = test.gen_clang_conf(vim)
    # print(ret)


