import unittest
from download_report import category, rows_from


class DownloadReportTests(unittest.TestCase):
    def test_counts_stay_separate(self):
        cases = {'LTP-mac.dmg':'Mac app', 'LTP-0.2.7-mac.dmg':'Mac app',
                 'ltp-linux-x86_64.tar.gz':'Linux package',
                 'LTP-windows-x64-installer.zip':'Windows installer',
                 'LTP-windows-x64-app.part1':'Windows application part',
                 'LTP-windows-x64-app.part2':'Windows application part',
                 'latest.json':'Update / checksum metadata',
                 'SHA256SUMS-windows.txt':'Update / checksum metadata',
                 'LTP-0.2.7-windows-source.zip':'Source / patch'}
        for name,expected in cases.items(): self.assertEqual(category(name),expected)

    def test_keeps_asset_identity_and_zero_counts(self):
        asset = dict(id=10,name='LTP-mac.dmg',download_count=0,size=100,browser_download_url='https://example.test/app')
        rows = rows_from([dict(tag_name='v0.2.7',assets=[asset]),dict(tag_name='v0.2.6',assets=[dict(asset,id=9,download_count=12)])], 'timestamp')
        self.assertEqual([r['asset_id'] for r in rows],[10,9])
        self.assertEqual([r['downloads'] for r in rows],[0,12])
        self.assertEqual([r['release'] for r in rows],['v0.2.7','v0.2.6'])

    def test_no_assets(self):
        self.assertEqual(rows_from([dict(tag_name='v1')], 'timestamp'), [])


if __name__ == '__main__': unittest.main()
