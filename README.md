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
delta updates. A GitHub Actions workflow polls Anthropic's release API every
6 hours and publishes new versions automatically.

## Build locally

Requires `curl`, `jq`, `binutils` (ar), `tar`.

```bash
./build.sh x64            # or: ./build.sh arm64
./build.sh x64 /path/to/claude.deb   # reuse an already-downloaded .deb
```

## License

Packaging files (scripts/workflow) are MIT. Claude Desktop itself is
proprietary software by Anthropic PBC, subject to
[Anthropic's Consumer Terms](https://www.anthropic.com/legal/consumer-terms).
The AppImage bundles Anthropic's unmodified binaries; if Anthropic objects to
this redistribution, the releases will be taken down on request.
