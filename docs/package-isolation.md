# Package Isolation

> **Note:**  
> This documentation describes the package isolation system for **application 
> code**—the main logic and modules of your Mudlet package. It is **not 
> applicable for glue code, UI scripting, or quick prototyping** in the Mudlet 
> command line or script editor. 

## Application bootstrapping

This package provides a foundation for developing maintainable, 
well-isolated Mudlet applications.  
The bootstrapping process delivers four key features:
- **Environment isolation:** Each package runs in its own Lua environment,
  keeping its globals separate from other packages and from Mudlet itself.
- **Application initialization:** Your package’s initialization code is always 
  executed within this isolated environment.
- **Application integration:** Event handlers and callbacks registered with the 
  Mudlet API from your initialization code are automatically wrapped, ensuring
  they always run in your package’s environment.
- **Dependency isolation:** Each package only has access to its own modules and 
  luarocks dependencies; it cannot naturally access those of other packages.

> This is pragmatic, best-effort isolation, not security-focused sandboxing.  
> The goal is to minimize friction and provide a natural level of separation 
> between packages, without extra ceremony.

## How the package namespace is named and accessed

When your package is bootstrapped, a unique global table is created for it in 
Mudlet's global lua environment. This table serves **both as the package's 
namespace and as its execution environment**. The name is based on your package 
name, sanitized and wrapped with double underscores, e.g.:

For `packageName = "my-package"`, the namespace is:
```
    __my_package__
```

This table acts as the global environment for all your package code and event 
handlers. You can access it anywhere via:
```
    _G["__my_package__"]
```

All the package-level globals, state, and global functions live inside this 
table, keeping them separate from other packages and Mudlet’s own globals.

> **Note:**  
> In this system, the terms "environment" and "namespace" refer to the same 
> table: it is both the runtime context for your package code and the container
> for your package's public symbols.

## Integration and event-based design

This package environment is designed for **event-driven integration**.  
The recommended way for other scripts, packages, or users to interact and
integrate with your package is by raising events (using Mudlet's event system)
and having your package respond via registered event handlers. This ensures all
your code runs within your package's isolated environment, maintaining
separation and avoiding namespace leaks.

If you expose functions or objects in your package’s public namespace (e.g., 
via _G["__my_package__"]), you must take extra care to ensure that your code 
executes within the package environment:

- Always assume that public methods may have their environment (`fenv`) changed 
  or reset by callers (e.g., via `setfenv`). In Lua 5.1, the function 
  environment is stored with the function object, but any code with a reference
  to your function can change it.
- Code defensively: do not assume the public method's environment is the 
  package environment. Your public API layer should act as an
  **anti-corruption layer**—a boundary that protects your package from external
  interference or environment corruption.
- Apply indirection to enforce the correct package environment by using your 
  API method to call a `setfenv`'ed delegate that runs your logic:
```
local function _public_api_method(input)
  -- Implementation here
end

function namespace:public_api_method(input)
  setfenv(_public_api_method, namespace)
  _public_api_method(input)
end
```
- Failing to enforce the correct environment will likely break isolation and 
  lead to subtle bugs or pollution of the global environment.

## Package isolation details

- **Namespace as environment:** A dedicated namespace table is created and set 
  as the global environment for your package code using `setfenv`.
- **Inheritance from Mudlet's global environment:** The namespace uses 
  `setmetatable` to inherit from Mudlet’s global environment, so your code can 
  access built-in functions and any existing global variables, but new globals
  are kept local to your package.
- **No global pollution:** All globals created in your package are stored in the
  namespace, not in Mudlet’s global environment or in other packages’ namespaces.
- **Custom `require`:** A custom `require` function ensures that modules loaded
  within your package are namespaced (e.g., `_G.package.loaded['__my_package__my_other_dependency']`).
  This prevents accidental leakage or collision of modules between packages.
- **No cross-package access:** By default, your package cannot access other 
  packages’ modules or luarocks dependencies via `require`.
- **Wrapped event handlers:** When your package registers event handlers or 
  callbacks with Mudlet, these are automatically wrapped to ensure they always 
  execute in your package’s isolated environment.