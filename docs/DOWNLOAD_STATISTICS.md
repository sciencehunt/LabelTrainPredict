# Release download statistics

GitHub records a download counter for each uploaded release asset. LTP does not collect application usage telemetry for this report.

From this repository, with Python 3 and an authenticated GitHub CLI:

```console
python tools/download_report.py --output download-reports
```

The command produces dated CSV, JSON and Markdown snapshots for every release. It separates Mac applications, Linux packages, Windows installers, Windows application parts, source files and update metadata.

Counters measure file downloads, including repeats, bots and maintainer checks. They do not identify unique people or confirm installation. Do not add multipart Windows downloads together as installations. Fixed-name and versioned copies have separate counters. GitHub-generated source ZIP/tar archives are not release assets and are not included.

Preserve dated snapshots and compare the same asset ID across snapshots. Replacing or deleting an asset removes its visible counter. A snapshot is a cumulative count at that time, so summing successive snapshots would double-count downloads.
