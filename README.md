# Unified (bot) blocklists

Build:
``docker build -t blu .``

Run:
```
docker network create --ipv6 blocklists-net || echo "Already exists"
docker run --rm -it -v %cd%\source:/workdir -v %cd%\source_cached_remote_lists:/source_cached_remote_lists -v %cd%\out\ipv6:/out -e OUT_FILE=/out/unified.list --network=blocklists-net blu
docker network rm blocklists-net || echo "Failed to remove"
```
