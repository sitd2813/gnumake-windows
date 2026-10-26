# GNU Make for Windows

Unofficial builds of [GNU Make](https://www.gnu.org/software/make/) for Windows

## Verifying the release executables

The release executables are published as GitHub immutable releases with artifact attestations. Verify the authenticity of downloaded executables with the following commands (requires GitHub CLI):

```powershell
gh release verify-asset --repo=sitd2813/gnumake-windows v<VERSION> <EXE>
gh attestation verify --repo=sitd2813/gnumake-windows <EXE>
```

## License

The patches in `patches/` are licensed under the [GNU General Public License, version 3](https://www.gnu.org/licenses/gpl-3.0.html) or later. All other source files in this repository are licensed under the [BSD Zero-Clause License](LICENSE).
