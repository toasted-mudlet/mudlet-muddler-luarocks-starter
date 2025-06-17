# Template Customization Guide

To rebrand this starter template for your own Mudlet package, you should update
the following files and directories:

## Files to update for rebranding

1. `/README.md` and `/docs/`
    - Replace `/README.md` and the contents of `/docs/` with your own content,
      branding, and documentation.
2. `/muddler/mfile`
    - Update the `mfile` to use your own package name, author, and summary.
    - The `{{VERSION}}` placeholder is automatically injected during CI—no
      need to change this unless you want to customize version handling.
3. `/muddler/README.md`
    - Update this file to describe your package for end users.
    - The `{{VERSION}}` placeholder is automatically injected during CI.

## Product-specific files and folders

- **Your package’s UI scripts and Mudlet-specific code go in:** `/muddler/src/`
- **Your LuaRocks dependencies go in:**
    - `mudlet-package-dev-1.rockspec` — pure Lua, non-binary, runtime-only
      dependencies
- **Your Lua source files go in:** `/src/`
- **Replace or update `/src/app/init.lua`** to integrate your application code.

> **Note:**  
> `/muddler/src/resources/lua/` is a reserved folder.  
> During the build process, this is populated automatically as the mountpoint
> for the `/src/` folder.  
> **Any content in this folder is removed during the build process.**


