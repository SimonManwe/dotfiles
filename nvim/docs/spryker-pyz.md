# Spryker PYZ Generator for Neovim

A PhpStorm-like plugin for extending Spryker modules in Neovim.

## Installation

Save the plugin as `lua/plugins/spryker-pyz.lua` and run `:Lazy sync`

## Commands & Keybindings

| Key          | Command          | Description                    |
| ------------ | ---------------- | ------------------------------ |
| `<leader>se` | `:SprykerExtend` | Extend existing Spryker module |

## Usage Examples

### 1. Extend Existing Spryker Module

**Use case:** You want to override a method in `CartsRestApiFacade`

```
1. Press <leader>se
2. Select module: "CartsRestApi"
3. Select layer: "Business"
4. Select type: "Facade"
```

**Creates:**

```
src/Pyz/Zed/CartsRestApi/Business/CartsRestApiFacade.php
```

**With content:**

```php
<?php

namespace Pyz\Zed\CartsRestApi\Business;

use Spryker\Zed\CartsRestApi\Business\CartsRestApiFacade as SprykerCartsRestApiFacade;

class CartsRestApiFacade extends SprykerCartsRestApiFacade
{
    // Override methods here
}
```
