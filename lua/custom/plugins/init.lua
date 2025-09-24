-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'lervag/vimtex',
    init = function()
      -- VimTeX configuration goes here, e.g.
      if vim.fn.has 'win32' then
        vim.cmd [[
        let g:vimtex_view_general_viewer = 'SumatraPDF'
	let g:vimtex_view_general_options
		\ = '-reuse-instance -forward-search @tex @line @pdf'
	]]
      else
        vim.g.vimtex_view_method = 'zathura'
      end
    end,
  },
}
