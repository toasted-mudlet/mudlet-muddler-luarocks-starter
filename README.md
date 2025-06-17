# Mudlet Muddler LuaRocks Starter

An experimental starter template for building [Mudlet](https://www.mudlet.org/) 
packages using [muddler](https://github.com/demonnic/muddler), [LuaRocks](https://luarocks.org/), and [Lua 5.1](https://www.lua.org/versions.html#5.1).

Mudlet is a free, open-source, cross-platform client for playing and scripting 
MUDs (Multi-User Dungeons).

## Features

- Project scaffolding for new Mudlet packages
- Ready-to-use [muddler](https://github.com/demonnic/muddler) build configuration
- [LuaRocks](https://luarocks.org/) support for dependency management
- GitHub Actions CI for automated testing and packaging, including dev snapshots
  and tagged releases.  
  [See CI workflow summary below.](#continuous-integration)

> **Note:**  
> This starter is intended for experimental, proof-of-concept applications that
> want to go beyond the boundaries of Mudlet's graphical scripting interface.

> **LuaRocks note:**  
> This template is designed for pure-Lua dependencies only. It does not include 
> or support OS-specific binaries or compiled modules. Please ensure that all 
> dependencies specified in your production `.rockspec` are pure Lua. If you add
> native modules, they may not work across platforms or with Mudlet.

## Requirements

- [Mudlet](https://www.mudlet.org/) (client, for package testing)
- [muddler](https://github.com/demonnic/muddler) (for packaging)
- [LuaRocks](https://luarocks.org/) (for managing Lua dependencies)
- [Lua 5.1](https://www.lua.org/versions.html#5.1)
- [luaver](https://github.com/dhavalkapil/luaver) is recommended for managing multiple Lua versions,
  especially if you work with Lua 5.1 alongside other versions

> **Note:**  
> At the time of writing, Mudlet embeds and executes Lua 5.1 as its scripting
> environment. Thus all code and dependencies in this template must be
> compatible with Lua 5.1.

## Caveats

- **No package isolation:** Mudlet’s Lua environment is global, so packages
  may interfere via globals or event handlers.
- **Module name collisions:** Modules are cached globally by name; use unique
  namespaced module names to avoid conflicts.
- **Pure-Lua dependencies only:** Binary LuaRocks modules are not supported for
  inclusion in Mudlet packages and may not work or may conflict with Mudlet’s 
  own binaries.
- **Shared environment:** All packages share `package.path`, `package.loaded`,
  and Mudlet globals unless you implement custom loaders and strict namespacing.
- **No security sandbox:** Malicious or buggy code can affect the entire 
  Mudlet session.


## Getting Started

1. **Use this template:**
   Click "Use this template" on GitHub, download the source archive, or clone 
   and remove `.git` to start a new project without inheriting git history:
   ```
   git clone --depth 1 https://github.com/toasted-mudlet/mudlet-muddler-luarocks-starter.git
   rm -rf .git
   git init
   git add .
   git commit -m "Initial commit from mudlet-muddler-luarocks-starter"
   ```
2. **Install [muddler](https://github.com/demonnic/muddler), [LuaRocks](https://luarocks.org/)** and
   [Lua 5.1](https://www.lua.org/versions.html#5.1)
3. **Customize the template:**  
   Replace placeholder files and metadata with your own package content.  
   [See template customization guide.](docs/template-customization.md)
4. **Build your package:**  
   Use muddler to build your package.  
   [See local development environment details.](docs/local-dev-env.md)

> **Note:** This is a project scaffolding template. No product-specific code or
> features are included.

## Continuous Integration

This repository uses GitHub Actions for automated testing and packaging:

- **Dev Snapshot:**  
  Builds and tests a development snapshot on every push or pull request to
  `main`, and on manual trigger. Uploads the package as an artifact.
- **Manual Release:**  
  Manually triggered release that builds, tests, tags, and publishes a new
  versioned package and GitHub Release.
- **Tag Release:**  
  Automatically builds, tests, and publishes a release package and GitHub
  Release whenever a new version tag is pushed.

See `.github/workflows/` for workflow definitions.

---

## Attribution

If you create a new project based substantially on this task scheduler, please
consider adding the following attribution or similar for all derived code:

> This project is based on [mudlet-muddler-luarocks-starter](https://github.com/toasted-mudlet/mudlet-muddler-luarocks-starter), originally
> licensed under the MIT License (see [LICENSE](LICENSE) for details). All
> original template code and documentation remain under the MIT License.

## License

Copyright © 2024-2025 github.com/toasted323

This project is licensed under the MIT License.  
See [LICENSE](LICENSE) in the root of this repository for full details.
