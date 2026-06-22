{
  inputs,
  lib,
  self,
  ...
}:
let
  inherit (lib) getExe;
in
{
  flake.nvimWrapper =
    {
      config,
      wlib,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ wlib.wrapperModules.neovim ];

      options.settings.test_mode = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          If true, use the impure on-disk config instead, for fast edits.

          Both versions of the package may be installed simultaneously.
        '';
      };
      config.settings.config_directory =
        if config.settings.test_mode then
          config.settings.unwrapped_config
        else
          config.settings.wrapped_config;
      options.settings.wrapped_config = lib.mkOption {
        type = wlib.types.stringable;
        default = ./.;
      };
      options.settings.unwrapped_config = lib.mkOption {
        type = lib.types.either wlib.types.stringable lib.types.luaInline;
        default = lib.generators.mkLuaInline "vim.uv.os_homedir() .. '/nixos/modules/wrappers/neovim'";
      };
      config.settings.dont_link = config.binName != "nvim";
      config.binName = lib.mkIf config.settings.test_mode (lib.mkDefault "vim");
      config.settings.aliases = lib.mkIf (config.binName == "nvim") [ "vi" ];

      config.runtimePkgs = [
        pkgs.lua-language-server
        pkgs.rust-analyzer
        pkgs.gopls
        pkgs.typescript-language-server
        pkgs.tailwindcss-language-server
        pkgs.vscode-langservers-extracted

        pkgs.stylua
        pkgs.prettierd
        pkgs.clang-tools
        pkgs.black
        pkgs.isort
        pkgs.rustfmt

        pkgs.ripgrep
        pkgs.fd

        # AI backend for the `99` plugin (ClaudeCodeProvider shells out to `claude`)
        pkgs.claude-code

        inputs.anynix.packages.${pkgs.stdenv.hostPlatform.system}.shell-color-scripts
      ];

      config.specs =
        let
          p = pkgs.vimPlugins;
        in
        {
          vague = {
            data = p.vague-nvim;
            config = ''
              require('vague').setup({ transparent = true })
              vim.cmd("colorscheme vague")
            '';
          };

          koda = {
            data = p.koda-nvim;
            config = ''
              require('koda').setup({ transparent = true })
            '';
          };

          mini = {
            data = p.mini-nvim;
            config = ''
              require("mini.icons").setup()
              require("mini.pairs").setup()
              require("mini.ai").setup()
              require("mini.surround").setup({
                mappings = {
                  add = "gsa",
                  delete = "gsd",
                  find = "gsf",
                  find_left = "gsF",
                  highlight = "gsh",
                  replace = "gsr",
                },
              })
              require("mini.comment").setup({
                options = {
                  custom_commentstring = nil,
                  ignore_blank_line = false,
                  start_of_line = false,
                  pad_comment_parts = true,
                },
                mappings = {
                  comment = "gc",
                  comment_line = "gcc",
                  comment_visual = "gc",
                  textobject = "gc",
                },
                hooks = {
                  pre = function() end,
                  post = function() end,
                },
              })
            '';
          };

          treesitter = {
            data = p.nvim-treesitter.withAllGrammars;
            config = ''
              vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter.setup", {}),
                callback = function(args)
                  local buf = args.buf
                  local filetype = args.match
                  local language = vim.treesitter.language.get_lang(filetype) or filetype
                  if not vim.treesitter.language.add(language) then
                    return
                  end
                  vim.wo.foldmethod = "expr"
                  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                  vim.treesitter.start(buf, language)
                  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
              })
            '';
          };

          treesitter-textobjects.data = p.nvim-treesitter-textobjects;

          lspconfig = {
            data = p.nvim-lspconfig;
            config = ''
              vim.diagnostic.config({
                underline = true,
                update_in_insert = false,
                virtual_text = {
                  spacing = 4,
                  source = "if_many",
                  prefix = "●",
                },
                severity_sort = true,
              })
              pcall(function() vim.lsp.inlay_hint.enable(true) end)

              local servers = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "ts_ls",
                "tailwindcss",
                "eslint",
              }
              for _, name in ipairs(servers) do
                pcall(vim.lsp.enable, name)
              end
            '';
          };

          luasnip.data = p.luasnip;

          blink-cmp = {
            data = p.blink-cmp;
            config = ''
              require("blink.cmp").setup({
                keymap = { preset = "enter" },
                appearance = {
                  nerd_font_variant = "mono",
                },
                completion = { documentation = { auto_show = false } },
                sources = {
                  default = { "lsp", "path", "snippets", "buffer" },
                },
                fuzzy = { implementation = "rust" },
              })
            '';
          };

          conform = {
            data = p.conform-nvim;
            config = ''
              require("conform").setup({
                formatters_by_ft = {
                  lua = { "stylua" },
                  python = { "isort", "black" },
                  rust = { "rustfmt" },
                  javascript = { "prettierd" },
                  typescript = { "prettierd" },
                  typescriptreact = { "prettierd" },
                  c = { "clang-format" },
                  cpp = { "clang-format" },
                },
                default_format_opts = { lsp_format = "fallback" },
                format_on_save = { timeout_ms = 500 },
                formatters = {
                  ["clang-format"] = {
                    prepend_args = { "-style=file", "-fallback-style=LLVM" },
                  },
                },
              })
              vim.keymap.set("", "<leader>cf", function()
                require("conform").format({ async = true }, function(err)
                  if not err then
                    local mode = vim.api.nvim_get_mode().mode
                    if vim.startswith(string.lower(mode), "v") then
                      vim.api.nvim_feedkeys(
                        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                        "n",
                        true
                      )
                    end
                  end
                end)
              end, { desc = "Format buffer" })
            '';
          };

          gitsigns = {
            data = p.gitsigns-nvim;
            config = ''
              require("gitsigns").setup({
                signs = {
                  add = { text = "▎" },
                  change = { text = "▎" },
                  delete = { text = "" },
                  topdelete = { text = "" },
                  changedelete = { text = "▎" },
                  untracked = { text = "▎" },
                },
                signs_staged = {
                  add = { text = "▎" },
                  change = { text = "▎" },
                  delete = { text = "" },
                  topdelete = { text = "" },
                  changedelete = { text = "▎" },
                },
                on_attach = function(buffer)
                  local gs = package.loaded.gitsigns
                  local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r,
                      { buffer = buffer, desc = desc, silent = true })
                  end
                  map("n", "]h", function()
                    if vim.wo.diff then
                      vim.cmd.normal({ "]c", bang = true })
                    else
                      gs.nav_hunk("next")
                    end
                  end, "Next Hunk")
                  map("n", "[h", function()
                    if vim.wo.diff then
                      vim.cmd.normal({ "[c", bang = true })
                    else
                      gs.nav_hunk("prev")
                    end
                  end, "Prev Hunk")
                  map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
                  map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
                  map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
                  map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
                  map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                  map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                  map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                  map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
                  map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end,
                    "Blame Line")
                  map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
                  map("n", "<leader>ghd", gs.diffthis, "Diff This")
                  map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
                  map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>",
                    "GitSigns Select Hunk")
                end,
              })
            '';
          };

          nui.data = p.nui-nvim;
          noice = {
            data = p.noice-nvim;
            config = ''
              require("noice").setup({})
            '';
          };

          oil = {
            data = p.oil-nvim;
            config = ''
              require("oil").setup({
                view_options = { show_hidden = true },
              })
              vim.keymap.set("n", "<leader>n", "<cmd>Oil<CR>", { desc = "Toggle Oil" })
            '';
          };

          which-key = {
            data = p.which-key-nvim;
            config = ''
              require("which-key").setup({
                spec = {
                  mode = { "n", "x" },
                  { "<leader>c",  group = "code" },
                  { "<leader>d",  group = "debug" },
                  { "<leader>dp", group = "profiler" },
                  { "<leader>f",  group = "file/find" },
                  { "<leader>s",  group = "search" },
                  { "[",          group = "prev" },
                  { "]",          group = "next" },
                  { "g",          group = "goto" },
                  { "gs",         group = "surround" },
                  { "gc",         group = "comment" },
                  { "z",          group = "fold" },
                },
              })
            '';
          };

          snacks = {
            data = p.snacks-nvim;
            config = ''
              require("snacks").setup({
                picker = {},
                dashboard = {
                  sections = {
                    { section = "header" },
                    {
                      pane = 2,
                      section = "terminal",
                      cmd = "colorscript -e square",
                      height = 5,
                      padding = 1,
                    },
                    { section = "keys", gap = 1, padding = 1 },
                    {
                      pane = 2,
                      icon = " ",
                      desc = "Browse Repo",
                      padding = 1,
                      key = "b",
                      action = function() Snacks.gitbrowse() end,
                    },
                    function()
                      local in_git = Snacks.git.get_root() ~= nil
                      local cmds = {
                        {
                          title = "Notifications",
                          cmd = "gh notify -s -a -n5",
                          action = function()
                            vim.ui.open("https://github.com/notifications")
                          end,
                          key = "n",
                          icon = " ",
                          height = 5,
                          enabled = true,
                        },
                        {
                          title = "Open Issues",
                          cmd = "gh issue list -L 3",
                          key = "i",
                          action = function()
                            vim.fn.jobstart("gh issue list --web", { detach = true })
                          end,
                          icon = " ",
                          height = 7,
                        },
                        {
                          icon = " ",
                          title = "Open PRs",
                          cmd = "gh pr list -L 3",
                          key = "P",
                          action = function()
                            vim.fn.jobstart("gh pr list --web", { detach = true })
                          end,
                          height = 7,
                        },
                        {
                          icon = " ",
                          title = "Git Status",
                          cmd = "git --no-pager diff --stat -B -M -C",
                          height = 10,
                        },
                      }
                      return vim.tbl_map(function(cmd)
                        return vim.tbl_extend("force", {
                          pane = 2,
                          section = "terminal",
                          enabled = in_git,
                          padding = 1,
                          ttl = 5 * 60,
                          indent = 3,
                        }, cmd)
                      end, cmds)
                    end,
                  },
                },
              })

              local k = vim.keymap.set
              k("n", "<leader>/",  function() Snacks.picker.grep() end,                                    { desc = "Grep" })
              k("n", "<leader>fb", function() Snacks.picker.buffers() end,                                 { desc = "Buffers" })
              k("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File" })
              k("n", "<leader>ff", function() Snacks.picker.files() end,                                   { desc = "Find Files" })
              k("n", "<leader>fg", function() Snacks.picker.git_files() end,                               { desc = "Find Git Files" })
              k("n", "<leader>fp", function() Snacks.picker.projects() end,                                { desc = "Projects" })
              k("n", "<leader>fr", function() Snacks.picker.recent() end,                                  { desc = "Recent" })
              k("n", "<leader>sd", function() Snacks.picker.diagnostics() end,                             { desc = "Diagnostics" })
              k("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end,                      { desc = "Buffer Diagnostics" })
              k("n", "<leader>gb", function() Snacks.picker.git_branches() end,                            { desc = "Git Branches" })
              k("n", "<leader>gl", function() Snacks.picker.git_log() end,                                 { desc = "Git Log" })
              k("n", "<leader>gL", function() Snacks.picker.git_log_line() end,                            { desc = "Git Log Line" })
              k("n", "<leader>gs", function() Snacks.picker.git_status() end,                              { desc = "Git Status" })
              k("n", "<leader>gS", function() Snacks.picker.git_stash() end,                               { desc = "Git Stash" })
              k("n", "<leader>gd", function() Snacks.picker.git_diff() end,                                { desc = "Git Diff (Hunks)" })
              k("n", "<leader>gf", function() Snacks.picker.git_log_file() end,                            { desc = "Git Log File" })
              k("n", "gd",         function() Snacks.picker.lsp_definitions() end,                         { desc = "Goto Definition" })
              k("n", "gD",         function() Snacks.picker.lsp_declarations() end,                        { desc = "Goto Declaration" })
              k("n", "gr",         function() Snacks.picker.lsp_references() end,                          { nowait = true, desc = "References" })
              k("n", "gI",         function() Snacks.picker.lsp_implementations() end,                     { desc = "Goto Implementation" })
              k("n", "gy",         function() Snacks.picker.lsp_type_definitions() end,                    { desc = "Goto T[y]pe Definition" })
            '';
          };

          plenary.data = p.plenary-nvim;

          codecompanion = {
            data = p.codecompanion-nvim;
            config = ''
              require("codecompanion").setup({})
            '';
          };

          "99" = {
            data = pkgs.vimUtils.buildVimPlugin {
              pname = "99";
              version = "unstable-2026-06-22";
              src = pkgs.fetchFromGitHub {
                owner = "ThePrimeagen";
                repo = "99";
                rev = "c17422457027c913c76c75a921fca1e623d2678e";
                hash = "sha256-iilpiG81kHIv7Y0qvPzZOanNA0lsPotlB18cvtmTy0o=";
              };
              # Loads fine in real use, but the isolated require-check has no LSP plugin available
              nvimSkipModule = [ "99.editor.lsp" ];
            };
            config = ''
              local _99 = require("99")
              _99.setup({
                provider = _99.Providers.ClaudeCodeProvider,
              })
              vim.keymap.set("v", "<leader>9v", function() _99.visual() end,            { desc = "99 visual replace" })
              vim.keymap.set("n", "<leader>9s", function() _99.search() end,            { desc = "99 search" })
              vim.keymap.set("n", "<leader>9x", function() _99.stop_all_requests() end, { desc = "99 stop all" })
            '';
          };
        };
    };

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        imports = [ self.nvimWrapper ];
      };

      packages.devMode = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        settings.test_mode = true;
        imports = [ self.nvimWrapper ];
      };

      packages.neovimDynamic = pkgs.writeShellApplication {
        name = "nvim";
        text = ''
          if [ -d ~/nixos/modules/wrappers/neovim/lua ]; then
              ${getExe self'.packages.devMode} "$@"
          else
              ${getExe self'.packages.neovim} "$@"
          fi
        '';
      };
    };
}
