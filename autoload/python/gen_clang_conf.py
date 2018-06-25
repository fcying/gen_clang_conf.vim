# -*- coding: utf-8 -*-

import os
from os.path import expanduser, expandvars, dirname, join, isfile, isdir
from pathlib import Path
import shlex

class GenClangConf():
    work_dir = ''

    def _find_scm_dir(self, names):
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in names:
                scm_dir = os.path.join(d, name)
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
        scm_dir = self._find_scm_dir(['.git', '.svn', '.hg'])

        if scm_dir:
            ext_file = os.path.join(scm_dir, '.clang_ext')
            clang_file = os.path.join(scm_dir, '.clang')
            clang = []
            if isfile(ext_file):
                clang = self._read_conf(ext_file)
            if isfile(clang_file):
                clang += self._read_conf(clang_file)
            return clang

        return []

    def _find_conf(self, names):
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in names:
                clang_file = os.path.join(d, name)
                if isfile(clang_file):
                    # print(clang_file)
                    GenClangConf.work_dir = dirname(clang_file)
                    break
                clang_file = ''
            if clang_file:
                break

        if clang_file:
            GenClangConf.work_dir = dirname(clang_file)
            return self._read_conf(clang_file)

        return []

    def get_clang_conf(self):
        GenClangConf.work_dir = os.getcwd()

        clang = self._find_scm_conf()
        if not clang:
            clang = self._find_conf(['.clang_complete', '.clang'])

        return clang, GenClangConf.work_dir

if __name__ == '__main__':
    test = GenClangConf()
    print(test.get_clang_conf())

