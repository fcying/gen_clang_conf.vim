# -*- coding: utf-8 -*-

import os
from os.path import expanduser, expandvars, dirname, join, isfile, isdir
from pathlib import Path
import shlex

class GenClangConf():
    work_dir = ''
    scm_dirs = ['.git', '.svn', '.hg']

    def get_clang_conf(self):
        GenClangConf.work_dir = os.getcwd()

        clang = self._find_scm_conf()
        if not clang:
            clang = self._find_conf(['.clang_complete', '.clang'])

        # print(GenClangConf.work_dir)
        return clang, GenClangConf.work_dir

    def gen_clang_conf(self, vim):
        scm_dir = self._find_scm_dir()
        clang_file = join(scm_dir, '.clang')
        ignore_dirs = vim.eval('g:gen_clang_conf#ignore_dirs')
        ignore_dirs += GenClangConf.scm_dirs
        clang = []
        for root, dirs, files in os.walk(str(Path(scm_dir).parent)):
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
                            clang.append('-I' + root)
                            break
                    if is_added:
                        break
        try:
            with open(clang_file, 'w') as f:
                for line in clang:
                    f.write(line + "\n")
        except Exception as e:
            print('Save clang_file Failed: ' + clang_file + str(e))
    
    def clear_clang_conf(self):
        scm_dir = self._find_scm_dir()
        if not scm_dir:
            print("not found scm dir, retrun")
            return

        ext_file = join(scm_dir, '.clang_ext')
        clang_file = join(scm_dir, '.clang')
        try:
            os.remove(clang_file)
        except Exception as e:
            pass
        try:
            os.remove(ext_file)
        except Exception as e:
            pass

    def get_clang_ext_path(self):
        scm_dir = self._find_scm_dir()
        if not scm_dir:
            print("not found scm dir, retrun")
            return ''

        ext_file = join(scm_dir, '.clang_ext')
        return ext_file

    def _find_scm_dir(self):
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in GenClangConf.scm_dirs:
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
        scm_dir = self._find_scm_dir()

        if scm_dir:
            ext_file = join(scm_dir, '.clang_ext')
            clang_file = join(scm_dir, '.clang')
            clang = []
            if isfile(ext_file):
                clang = self._read_conf(ext_file)
            if isfile(clang_file):
                clang += self._read_conf(clang_file)
            GenClangConf.work_dir = str(Path(scm_dir).parent)
            return clang

        return []

    def _find_conf(self, names):
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in names:
                clang_file = join(str(d), name)
                if isfile(clang_file):
                    break
                clang_file = ''
            if clang_file:
                break

        if clang_file:
            clang = []
            GenClangConf.work_dir = dirname(clang_file)
            # add clang_ext first
            ext_file = join(GenClangConf.work_dir, '.clang_ext')
            if isfile(ext_file):
                clang += self._read_conf(ext_file)
            clang += self._read_conf(clang_file)
            return clang

        return []

if __name__ == '__main__':
    test = GenClangConf()
    ret = test.get_clang_conf()
    print(ret)


