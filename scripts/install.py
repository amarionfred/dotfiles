#!/usr/bin/env python3
"""Install the public desktop, Zsh and editor profile listed in install-files.txt."""

import argparse
from datetime import datetime, timezone
from pathlib import Path
import shutil


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target-dir', type=Path, default=Path.home())
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    target = args.target_dir.expanduser().resolve()
    repo = Path(__file__).resolve().parents[1]
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ')
    backup = target / '.local/state/dotfiles-backups' / stamp
    changed = 0

    for name in (repo / 'install-files.txt').read_text().splitlines():
        rel = Path(name)
        if not name or name.startswith('#'):
            continue
        if rel.is_absolute() or '..' in rel.parts:
            raise ValueError(f'Invalid install path: {rel}')
        src, dst = repo / rel, target / rel
        if not src.is_file() or src.is_symlink():
            raise ValueError(f'Expected a regular source file: {rel}')
        if not dst.parent.resolve().is_relative_to(target):
            raise ValueError(f'Destination parent leaves target directory: {rel}')
        data = src.read_bytes()
        try:
            data = data.decode('utf-8').replace('@HOME@', str(target)).encode('utf-8')
        except UnicodeDecodeError:
            pass
        mode = src.stat().st_mode & 0o777
        if (dst.is_file() and not dst.is_symlink() and dst.read_bytes() == data
                and dst.stat().st_mode & 0o777 == mode):
            continue
        exists = dst.exists() or dst.is_symlink()
        if exists and dst.is_dir() and not dst.is_symlink():
            raise ValueError(f'Expected a file but found a directory: {dst}')
        print(f'{"Would restore" if args.dry_run else "Restore"}: {rel}')
        changed += 1
        if args.dry_run:
            continue
        if exists:
            saved = backup / rel
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(dst, saved, follow_symlinks=False)
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.is_symlink():
            dst.unlink()
        dst.write_bytes(data)
        dst.chmod(mode)

    print(f'{changed} files selected.')
    if not args.dry_run and backup.exists():
        print(f'Backups of replaced files: {backup}')


if __name__ == '__main__':
    main()
