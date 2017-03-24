#!/usr/bin/env python

import os

# this could be read from the directory but I'd rather be specific.
DOTFILES = [
    '.config',
    '.tmux.conf',
    '.gitconfig',
    '.gitignore_global',
    '.ssh/config',
    '.zprezto'
]

SOURCE = '/Users/pablasso/dev/personal/dotfiles'
DESTINATION = '/Users/pablasso'

def run():
    for dotfile in DOTFILES:
        source_path = os.path.join(SOURCE, dotfile)
        destination_path = os.path.join(DESTINATION, dotfile)
        _move_path_if_applicable(destination_path)
        _create_symlink(source_path, destination_path)


def _move_path_if_applicable(path):
    if not os.path.exists(path):
        return

    backup_path = None
    backup_counter = 1

    while not backup_path:
        candidate_path = '{0}.{1}'.format(path, backup_counter)
     
        if os.path.exists(candidate_path):
            backup_counter += 1
            continue

        backup_path = candidate_path
    
    print('Existing path detected. Backing up at {0} ..'.format(backup_path)),
    os.rename(path, backup_path)
    print(' Done.')


def _create_symlink(source, destination):
    print('creating symlink at {0} ..'.format(destination)),
    os.symlink(source, destination)
    print(' Done.')


if __name__ == '__main__':
    run()
