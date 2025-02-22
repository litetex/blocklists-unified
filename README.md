# Unified (bot) blocklists

Build:
``docker build -t blu .``

Run:
``docker run --rm -it -v %cd%\source:/workdir -v %cd%\out\ipv6:/out -e OUT_FILE=/out/ipv6/unified.list blu``

### Configuration for client

```bash
BLOCKLIST_DOWNLOADS=(
    "https://codeberg.org/litetex/blocklists-unified/raw/branch/master/out/ipv6/unified.list"
    "https://codeberg.org/litetex/blocklists-unified/raw/branch/master/out/ipv6/fallback.list"
)
```
