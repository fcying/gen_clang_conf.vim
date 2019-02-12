# -*- coding: utf-8 -*-

import os
from os.path import expanduser, expandvars, dirname, join, isfile, isdir
from pathlib import Path
import shlex
import vim

class GenClangConf():
    work_dir = ''
    clang_file = ''
    ignore_dirs = []
    scm_list = []
    suffix_list = []
    clang_conf_names = ['.clang_complete']

    def __init__(self):
        self.work_dir = os.getcwd()
        self.suffix_list = vim.eval('g:gen_clang_conf#suffix_list')
        self.scm_list = vim.eval('g:gen_clang_conf#scm_list')
        self.ignore_dirs = vim.eval('g:gen_clang_conf#ignore_dirs')
        self.ignore_dirs += self.scm_list

    def get_clang_conf_path(self):
        scm_dir = self._find_scm_dir()
        if not scm_dir:
            scm_dir = os.getcwd()
        clang_conf_path = join(scm_dir, '.clang_complete')
        return clang_conf_path

    def gen_clang_conf(self):
        scm_dir = self._find_scm_dir()
        if not scm_dir:
            scm_dir = os.getcwd()
            scm_root_dir = scm_dir
        else:
            scm_root_dir = str(Path(scm_dir).parent)

        self.clang_file = self.get_clang_conf_path()
        if isfile(self.clang_file):
            # read custom config
            clang = self._read_conf(self.clang_file)
        else:
            clang = []

        for root, dirs, files in os.walk(scm_root_dir):
            for ignore_dir in self.ignore_dirs:
                is_ignore_dir = 0
                if root.lower().endswith(ignore_dir):
                    dirs[:] = []
                    is_ignore_dir = 1
                    break
            if is_ignore_dir == 0:
                for file in files:
                    is_added = 0
                    for suffix in self.suffix_list:
                        if file.endswith(suffix):
                            is_added = 1
                            new_line = '-I' + os.path.relpath(root, scm_root_dir)
                            clang.append(new_line.replace('\\', '/'))
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

        self.clang_file = join(scm_dir, '.clang')
        try:
            os.remove(self.clang_file)
        except Exception as e:
            print("clear_clang_conf error: ", str(e))

    def _find_scm_dir(self):
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in self.scm_list:
                scm_dir = join(str(d), name)
                if isdir(scm_dir):
                    return scm_dir
        return ''

    def _read_conf(self, conf_file):
        try:
            with open(conf_file) as f:
                args = f.read().splitlines()
                split_line = args.index('')
                if split_line is (len(args)-1):
                    return []
                args = args[0:split_line]
                # print(args, split_line)
                args = [expanduser(expandvars(p)) for p in args]
                args.append('')
                return args
        except Exception as e:
            print('Parse Failed: ' + conf_file, str(e))
        return []

if __name__ == '__main__':
    test = GenClangConf()
    ret = test.gen_clang_conf()
    # print(ret)


