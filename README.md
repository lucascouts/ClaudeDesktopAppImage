# Claude Desktop — unofficial AppImage

Unofficial AppImage of [Claude Desktop](https://claude.ai/download) for Linux,
repackaged from Anthropic's official `.deb` release. Not affiliated with or
endorsed by Anthropic. Part of the
[Claude Desktop for Linux](https://github.com/lucascouts/claude-desktop-app)
packaging project.

Built for `x86_64` and `aarch64` (the `aarch64` build is cross-built and not
yet runtime-tested). Grab the latest from
[Releases](https://github.com/lucascouts/ClaudeDesktopAppImage/releases).

```bash
chmod +x Claude_Desktop_Unofficial-*-x86_64.AppImage
./Claude_Desktop_Unofficial-*-x86_64.AppImage
```

## Why AppImage (vs the Flatpak)

No sandbox: local MCP servers (`npx`, `uvx`, ...) and the VM-based
code-execution sandbox (qemu) work exactly as on a native install. See
[ClaudeDesktopFlatpak](https://github.com/lucascouts/ClaudeDesktopFlatpak)
for the sandboxed alternative.

## Chromium sandbox note

AppImages cannot ship the setuid `chrome-sandbox` helper, so Electron uses
unprivileged user namespaces. On systems where those are disabled (Debian
`kernel.unprivileged_userns_clone=0`, Ubuntu 24.04+ AppArmor restriction),
`AppRun` automatically falls back to `--no-sandbox`.

## Updates

Releases embed zsync update information — use
[AppImageUpdate](https://github.com/AppImageCommunity/AppImageUpdate) for
delta updates.

New releases are cut automatically: the **Build and release** workflow runs
every six hours and publishes `v<version>` whenever that tag is missing.

### Where the version comes from

Not from Anthropic's API. `claude.ai/api` is what hands out the download URL and
its per-release build id, but it sits behind Cloudflare and rejects GitHub's
datacenter runner IPs — no User-Agent gets around that.

So CI reads the answer second-hand, from the
[`app-misc/claude-desktop-bin`](https://github.com/obentoo/bentoo/tree/master/app-misc/claude-desktop-bin)
ebuild in the [bentoo overlay](https://github.com/obentoo/bentoo). That overlay's
autoupdate *does* query the API — from a residential IP, where it answers — and
commits both values: the version in the ebuild's filename, the build id in its
`BUILD_ID`. Reading them back is an ordinary GitHub fetch, which always works
from CI. That is [`ci/resolve-overlay-pin.sh`](ci/resolve-overlay-pin.sh).

`downloads.claude.ai` itself is not challenged, so downloading the `.deb` from CI
works fine once the URL is known. The `aarch64` build reuses the same URL with
`/arm64/` — Anthropic serves the same build id there.

To build some other version, run the workflow manually
(`Actions → Build and release → Run workflow`) and pass a `deb_url`; that
overrides the overlay lookup.

## Build locally

Requires `curl`, `binutils` (ar), `tar` (and `jq` only for the API-probe form).

```bash
./build.sh x64 /path/to/claude.deb            # from a local .deb (no API)
./build.sh x64 https://downloads.claude.ai/.../Claude-<id>.deb  # from a URL
./build.sh x64                                # probe the API (non-datacenter IP)
```

## License

Packaging files (scripts/workflow) are MIT. Claude Desktop itself is
proprietary software by Anthropic PBC, subject to
[Anthropic's Consumer Terms](https://www.anthropic.com/legal/consumer-terms).
The AppImage bundles Anthropic's unmodified binaries; if Anthropic objects to
this redistribution, the releases will be taken down on request.
