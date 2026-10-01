"""Report GitHub release asset downloads. Standard library + authenticated gh CLI.

Counts are file downloads, including repeats and maintainer checks, not users or
successful installations. ZIP/tarball source downloads made by GitHub itself are
not release assets and are not included. No application telemetry is collected.
"""
import argparse
import csv
import datetime
import json
from pathlib import Path
import subprocess


def category(name):
    n = name.lower()
    if n.endswith('.dmg'): return 'Mac app'
    if 'linux' in n and n.endswith('.tar.gz'): return 'Linux package'
    if 'installer' in n and n.endswith('.zip'): return 'Windows installer'
    if '-app.part' in n: return 'Windows application part'
    if 'source' in n or n.endswith('.patch'): return 'Source / patch'
    if n.endswith('.json') or 'sha256' in n: return 'Update / checksum metadata'
    return 'Other release asset'


def rows_from(releases, timestamp):
    return [dict(snapshot_utc=timestamp, release=r['tag_name'], asset_id=a['id'],
                 asset=a['name'], category=category(a['name']), downloads=a['download_count'],
                 bytes=a['size'], url=a['browser_download_url'])
            for r in releases for a in r.get('assets', [])]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', default='sciencehunt/LabelTrainPredict')
    parser.add_argument('--output', type=Path, default=Path('download-reports'))
    parser.add_argument('--input', type=Path, help='Use saved API JSON instead of fetching')
    args = parser.parse_args()
    if args.input:
        releases = json.loads(args.input.read_text(encoding='utf-8-sig'))
    else:
        response = subprocess.run(['gh', 'api', '--paginate', '--slurp',
            f'repos/{args.repo}/releases?per_page=100'], check=True, capture_output=True, text=True, encoding='utf-8')
        releases = json.loads(response.stdout)
    if releases and isinstance(releases[0], list): releases = [r for page in releases for r in page]
    now = datetime.datetime.now(datetime.timezone.utc)
    rows = rows_from(releases, now.isoformat())
    totals = {}
    for row in rows: totals[row['category']] = totals.get(row['category'], 0) + row['downloads']
    args.output.mkdir(parents=True, exist_ok=True)
    stem = args.output / ('downloads-' + now.strftime('%Y%m%dT%H%M%S%fZ'))
    stem.with_suffix('.json').write_text(json.dumps(dict(snapshot_utc=now.isoformat(), totals=totals, assets=rows), indent=2)+'\n', encoding='utf-8')
    with stem.with_suffix('.csv').open('w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['snapshot_utc','release','asset_id','asset','category','downloads','bytes','url'])
        writer.writeheader(); writer.writerows(rows)
    text = ('# GitHub download report\n\nSnapshot: '+now.isoformat()+'\n\n'
            '| Asset category | Downloads |\n|---|---:|\n'+
            ''.join(f'| {name} | {count} |\n' for name,count in sorted(totals.items()))+
            '\nCounts measure individual file downloads, including repeats, maintainer checks and bots. '
            'They do not measure unique people or successful installations. Windows app parts must not be added together as installations. '
            'Versioned and fixed-name assets are separate counters. Update manifest requests are separate from app downloads. '
            'GitHub-generated source archives are not included. Deleted or replaced assets lose their visible counters; '
            'keep these dated snapshots and compare by asset ID. Do not sum repeated snapshots. No app telemetry is used.\n')
    stem.with_suffix('.md').write_text(text, encoding='utf-8')
    print(text); print('Detailed CSV:', stem.with_suffix('.csv'))


if __name__ == '__main__': main()
