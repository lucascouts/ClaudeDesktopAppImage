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

New releases are cut by the **Build and release** workflow, triggered manually
(`Actions → Build and release → Run workflow`) with the `.deb` URL for the
target version, e.g.
`https://downloads.claude.ai/releases/linux/x64/1.20186.0/Claude-<id>.deb`.

There is no schedule: `claude.ai/api` (which hands out that URL and its build
id) sits behind Cloudflare and rejects GitHub's datacenter runner IPs, so the
latest version cannot be discovered from CI. Obtain the URL where the API is
reachable — for example:

```bash
curl -s -A 'Mozilla/5.0 (X11; Linux x86_64) claude-desktop' \
  https://claude.ai/api/desktop/linux/x64/deb/latest
```

`downloads.claude.ai` itself is not challenged, so CI downloads the `.deb` fine
once given the URL. The `aarch64` build reuses the same URL with `/arm64/`.

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
