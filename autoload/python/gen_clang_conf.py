# -*- coding: utf-8 -*-

import os
from os.path import expanduser, expandvars, dirname, join, isfile, isdir
from pathlib import Path
import shlex
import vim

class GenClangConf():
    #.clang_complete .ccls
    clang_conf_name = 'compile_flags.txt'
    clang_ext_name = '.clang_ext'
    scm_dir = ''
    root_dir = ''

    def __init__(self):
        self.rc = 0;
        self.ignore_dirs_extend = []
        self.default_conf = vim.eval('g:gen_clang_conf#default_conf')
        self.suffix_list = vim.eval('g:gen_clang_conf#suffix_list')
        self.ignore_dirs = vim.eval('g:gen_clang_conf#ignore_dirs')
        self.scm_list = vim.eval('g:gen_clang_conf#scm_list')
        self.conf_save_in_scm = int(vim.eval('g:gen_clang_conf#conf_save_in_scm'))
        self.clang_conf_name = vim.eval('g:gen_clang_conf#clang_conf_name')

        self.ignore_dirs += self.scm_list

    def get_clang_conf_path(self):
        self.scm_dir, self.root_dir = self._find_scm_dir()

        if not self.scm_dir:
            self.scm_dir = self.root_dir = os.getcwd()

        if self.conf_save_in_scm == 1:
            clang_conf_path = join(self.scm_dir, self.clang_conf_name)
        else:
            clang_conf_path = join(self.root_dir, self.clang_conf_name)
        return clang_conf_path

    def get_clang_ext_path(self):
        self.scm_dir, self.root_dir = self._find_scm_dir()

        if not self.scm_dir:
            self.scm_dir = self.root_dir = os.getcwd()

        clang_ext_path = join(self.scm_dir, self.clang_ext_name)
        return clang_ext_path

    def gen_clang_conf(self):
        clang_file = self.get_clang_conf_path()
        ext_file = self.get_clang_ext_path()

        # read custom config
        if isfile(ext_file):
            clang = self._read_custom_conf(ext_file)
        else:
            clang = []

        # default config
        for str in self.default_conf[::-1]:
            clang.insert(0, str)

        # gen config
        for root, dirs, files in os.walk(self.root_dir):
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
                            new_line = '-I' + os.path.relpath(root, self.root_dir)
                            clang.append(new_line.replace('\\', '/'))
                            break
                    if is_added:
                        break
        if self.rc != 0:
            return -1
        try:
            with open(clang_file, 'w') as f:
                for line in clang:
                    f.write(line + '\n')
            return 0
        except Exception as e:
            self.rc = -1
            print('Save clang_file Failed: ' + clang_file + str(e))
        return -1
    
    def clear_clang_conf(self):
        file_path = self.get_clang_conf_path()
        if isfile(file_path):
            try:
                os.remove(file_path)
            except Exception as e:
                self.rc = -1
                print('clear_clang_conf error: ', str(e))

    def _find_scm_dir(self):
        cwd = Path(os.getcwd())
        dirs = [cwd.resolve()] + list(cwd.parents)
        for d in dirs:
            for name in self.scm_list:
                scm_dir = join(str(d), name)
                if isdir(scm_dir):
                    return scm_dir, str(d)
        return '', ''

    def _get_ext_options(self, data):
        try:
            # print(data)
            options = dict(item.split("=", 1) for item in data)
            for option in options.keys():
                l = list(options.get(option).split(','))
                setattr(self, option, l)
            self.ignore_dirs.extend(self.ignore_dirs_extend)
        except Exception as e:
            self.rc = -1
            print('ext option error: ', str(e))

    def _read_custom_conf(self, conf_path):
        try:
            with open(conf_path) as f:
                args = f.read().splitlines()
                try:
                    split_line = args.index('')
                except ValueError as e:
                    # not options config
                    split_line = 0
                self._get_ext_options(args[0:split_line])
                args = args[split_line+1:]
                # print(options,args, split_line)
                args = [expanduser(expandvars(p)) for p in args]
                args.append('')
                return args
        except Exception as e:
            self.rc = -1
            print('ext file error: ' , str(e))
        return []

if __name__ == '__main__':
    test = GenClangConf()
    ret = test.gen_clang_conf()
    # print(ret)


