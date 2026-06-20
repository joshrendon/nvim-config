return {

    "https://github.com/neovim/nvim-lspconfig",
    event = {"BufReadPre", "BufNewFile" },
    --vim.lsp.enable('lua_ls', 'pyright')
    vim.filetype.add({extension = {
        v = "systemverilog",
        sv = "systemverilog",
        svh = "systemverilog",
     },
    }),

    vim.lsp.config('svlangserver', {

      settings = {
          systemverilog = {
            includeIndexing     = {"**/*.{v, sv,svh}"},
            excludeIndexing     = {"test/**/*.sv*"},
            defines             = {},
            launchConfiguration = "~/oss-cad-suite/bin/verilator -sv -Wall --lint-only",
            formatCommand       = "~/oss-cad-suite/bin/verible-verilog-format"
          },
      },
    }),

    vim.lsp.config("verible", {
        cmd = { "verible-verilog-ls",
                "--rules_config_search",
                "--rules=-no-tabs"
        },
        root_markers = {".git", "verible.filelist"},
        settings = {
            verible = {
                column_limit = 100,
            }
        }
    }),

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          diagonstics = { globals = { "vim" } },
          runtime = {
            version = "LuaJIT"
          }
        }
      }
    }),

    -- Rust
    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = true,
          check = {
            command = "clippy",
          },
          cargo = {
            allFeatures = true,
          },
        },
      },
      on_attach = function(client, bufnr)
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    }),

    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
            vim.api.nvim_set_hl(0, "@lsp.type.type.python", { link = "@type" })
            vim.api.nvim_set_hl(0, "@lsp.type.class.python", { link = "@type" })
        end,
    }),

    vim.lsp.config("cclss", {}),

    -- Markdown
    vim.lsp.config("marksman", {}),

    -- Enable the servers
    vim.lsp.enable({
        "lua_ls",
        "rust_analyzer",
        "marksman",
        "pyright",
        "verible",
        "svlangserver"
    })
}
