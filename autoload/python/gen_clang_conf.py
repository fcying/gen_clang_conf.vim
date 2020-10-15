# -*- coding: utf-8 -*-

import os
from os.path import expanduser, expandvars, join, isfile, isdir
from pathlib import Path
import vim

class GenClangConf():
    #.clang_complete .ccls
    conf_name = 'compile_flags.txt'
    ext_conf_name = '.clang_ext'
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
        self.conf_name = vim.eval('g:gen_clang_conf#conf_name')

        self.ignore_dirs += self.scm_list

    def get_conf_path(self):
        self.scm_dir, self.root_dir = self._find_scm_dir()

        if not self.scm_dir:
            self.scm_dir = self.root_dir = os.getcwd()

        if self.conf_save_in_scm == 1:
            clang_conf_path = join(self.scm_dir, self.conf_name)
        else:
            clang_conf_path = join(self.root_dir, self.conf_name)
        return clang_conf_path

    def get_ext_conf_path(self):
        self.scm_dir, self.root_dir = self._find_scm_dir()

        if not self.scm_dir:
            self.scm_dir = self.root_dir = os.getcwd()

        ext_conf_path = join(self.scm_dir, self.ext_conf_name)
        return ext_conf_path

    def gen_clang_conf(self):
        conf_file = self.get_conf_path()
        ext_file = self.get_ext_conf_path()

        conf_list = []

        # default config
        for str in self.default_conf[::-1]:
            conf_list.insert(0, str)

        # read custom config
        if isfile(ext_file):
            conf_list += self._read_custom_conf(ext_file)

        # gen config
        for root, dirs, files in os.walk(self.root_dir):
            is_ignore_dir = 0
            for ignore_dir in self.ignore_dirs:
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
                            conf_list.append(new_line.replace('\\', '/'))
                            break
                    if is_added:
                        break

        if self.conf_name == '.ycm_extra_conf.py':
            conf_lsit_bak = []
            for line in conf_list: 
                conf_lsit_bak.append('\'' + line + '\',')
            conf_list = conf_lsit_bak
            conf_list.insert(0, "flags = { 'flags': [")
            conf_list.append(']}')
            conf_list.append('def Settings( **kwargs ):')
            conf_list.append('    return flags')

        # print(conf_list)

        if self.rc != 0:
            return -1
        try:
            with open(conf_file, 'w') as f:
                for line in conf_list:
                    f.write(line + '\n')
            return 0
        except Exception as e:
            self.rc = -1
            print('Save {0} Failed: {1}'.format(conf_file, e))
        return -1
    
    def clear_clang_conf(self):
        file_path = self.get_conf_path()
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
                # print(args, split_line)
                args = [expanduser(expandvars(p)) for p in args]
                # args.append('')
                return args
        except Exception as e:
            self.rc = -1
            print('ext file error: ' , str(e))
        return []

if __name__ == '__main__':
    test = GenClangConf()
    ret = test.gen_clang_conf()
    # print(ret)


