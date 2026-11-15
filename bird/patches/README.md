# BIRD 3.4.0 downstream patches

Originally developed against BIRD `v3.4.0`, commit
`c3669497e3949b942d86d07e343092cc439b4659`. The image build applies the patches
to the selected release in numeric order. To apply them to a clean source tree:

```sh
for patch in /path/to/patches/0*.patch; do
  git apply "$patch"
done
```

1. Recheck candidate feasibility and refresh it when a source expires.
2. Fix an upstream route-export stack over-read. The patch retains its original
   author and description.
3. Exclude candidates on an interface while it is being stopped or removed.
4. Add optional Babel route hysteresis, configuration, and monitoring.

Hysteresis is disabled by default. The first three fixes still apply when it is
disabled. Configuration and CLI details are in the patched BIRD manual.

When upgrading BIRD, check which fixes have reached upstream, drop any patches
that are no longer needed, and revalidate the remaining series against the new
version.
