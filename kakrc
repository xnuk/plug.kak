try %{ source "%val{config}/plugins/plug/plug.kak" } catch %{
	eval %sh{
		curl --silent -L https://xnuk.github.io/plug.kak
	}
}
require-module plug

plug xnuk:plug.kak

plug github:alexherbo2/surround.kak %{
	map global normal \' ': enter-user-mode surround<ret>'
	map global normal q ': enter-user-mode surround<ret>'
	map global normal ( ': enter-user-mode surround<ret>('
}

plug github:alexherbo2/search-highlighter.kak %{
	search-highlighter-enable
	set-face global Search rgb:000000,rgb:FFFF00+F
}

plug github:dead10ck/auto-pairs.kak#remove-kcr %{
	auto-pairs-enable
}

plug github:alexherbo2/explore.kak %{
	define-command kcr-fzf-files -params 1 -file-completion %{
		> kcr-fzf-files %arg{@}
	}

	define-command kcr-fzf-buffers -file-completion %{
		> kcr-fzf-buffers
	}

	alias global explore-files kcr-fzf-files
	alias global explore-buffers kcr-fzf-buffers

	explore-enable
}

plug github:occivink/kakoune-expand %{
	map global normal = ': expand<ret>'
	declare-option str expand_commands %{
		expand-impl %{ exec <a-a>b }
		expand-impl %{ exec <a-a>B }
		expand-impl %{ exec <a-i><a-w> }
		expand-impl %{ exec "<a-i>c[({[=\s]','[\]}):;\s]<ret>" }
		expand-impl %{ exec '<a-i>c[({[=\s]","[\]}):;\s]<ret>' }
		expand-impl %{ exec <a-a>r }
		expand-impl %{ exec <a-i>i }
		expand-impl %{ exec <a-i>p }
		expand-impl %{ exec '<a-:><a-;>k<a-K>^$<ret><a-i>i' } # previous indent level (upward)
		expand-impl %{ exec '<a-:>j<a-K>^$<ret><a-i>i' }      # previous indent level (downward)
	}
}

plug github:Delapouite/kakoune-goto-file %{
	map global goto F f
	map global goto f '<esc>: try %{ execute-keys gF } catch goto-file<ret>' -docstring 'file'
}

plug github:occivink/kakoune-sudo-write

# # shortcut plugins that doesn't care about remapping
plug github:Delapouite/kakoune-auto-percent

plug https://gitlab.com/Screwtapello/kakoune-shellcheck

nop %{

# plug alacritty https://github.com/alexherbo2/alacritty.kak %{
# 	alias global terminal alacritty-terminal
# 	alias global popup alacritty-terminal-popup
# }



# plug-old state-save https://gitlab.com/Screwtapello/kakoune-state-save %{
# 	hook global KakBegin .* %{
# 		state-save-reg-load colon
# 		state-save-reg-load pipe
# 		state-save-reg-load slash
# 	}

# 	define-command -hidden state-save-regs %{
# 		state-save-reg-save colon
# 		state-save-reg-save pipe
# 		state-save-reg-save slash
# 	}

# 	hook global KakEnd .* state-save-regs
# 	hook global NormalIdle .* state-save-regs
# }

}
map global normal b ':buffer '

define-command buffer-jump -params 2 -buffer-completion %{
	buffer %arg{1}
	execute-keys "%arg{2}gx"
}

define-command fzf-real-buffer-file-search %{
	declare-option -hidden str fzf_real_patho %sh{mktemp}
	evaluate-commands -draft -buffer * %{
		execute-keys -draft "%%<a-|> nl -nrn -ba | sed -E 's|^ *|%val{bufname}\t|' >> %opt{fzf_real_patho}<ret>"
	}
	fzf -kak-cmd 'eval buffer-jump' -items-cmd "cat %opt{fzf_real_patho}" -fzf-args %[ \
		+m --tiebreak=index --prompt="Lines>" --ansi --extended --delimiter="\t" --nth=3.. --tabstop=1 --layout=reverse-list \
	] -filter 'cut -f1-2' -post-action %[
		nop %sh{rm "$kak_opt_fzf_real_patho"}
	]
}

set-option -add global ui_options ncurses_status_on_top=yes
set-option -add global ui_options ncurses_assistant=cat

define-command combined-space -docstring 'try ; first, then <space>.' %{
	execute-keys %sh{
		leftover=$(printf '%s' "$kak_selections_desc" | sed -E 's/([0-9.]+),\1 *//g')
		if [ -z "$leftover" ]; then
			printf '<space>'
		else
			printf ';'
		fi
	}
}

define-command no-fail-selection-trim -docstring 'It is _ but no fail' %{
	try 'execute-keys _' catch ''
}

define-command ctrl-d %{ execute-keys -save-regs '' %sh{
	if [ "$(printf '%s' "$kak_selection" | wc -m)" -eq 1 ]; then
		echo '<a-i>w*'
	else
		echo '*<s-n>'
	fi
}}

define-command comment-prefer-block %{
	try %{
		comment-block
		execute-keys <a-x>
	} catch comment-line
}

define-command comment-prefer-line %{
	try comment-line catch %{
		comment-block
		execute-keys <a-x>
	}
}

define-command to-spaces 'execute-keys @'
define-command to-tabs   'execute-keys <a-@>'

# How dare you guise use spaces
set-option global indentwidth 0
set-option global aligntab false
set-option global tabstop 4

colorscheme tomorrow-night

# I love Akamig
unset-face global Default

add-highlighter global/ number-lines -hlcursor -separator " " -min-digits 3

# this is a magic

map global normal n 'b: no-fail-selection-trim<ret>'
map global normal <a-n> h
map global normal N B
map global normal <a-N> H
map global normal e j
map global normal <a-e> ]p
map global normal <a-E> }p
map global normal E J
map global normal <a-E> }p
map global normal i 'e: no-fail-selection-trim<ret>'
map global normal <a-i> l
map global normal I E
map global normal <a-I> L
map global normal u k
map global normal <a-u> [p
map global normal <a-U> {p
map global normal U K
map global normal <a-U> {p
map global normal k <a-J>
map global normal v x[p]p
map global normal V X{p}p
map global normal x X
map global normal X <a-x>
map global normal r ';r'
map global normal a ': no-fail-selection-trim<ret>a'

map global insert <a-backspace> '<a-;>b<a-;>_<a-;>d'
map global insert <a-n> '<a-;>b<a-;>;'
map global insert <a-i> '<a-;>e<a-;>;'
map global insert <a-u> '<a-;>k'
map global insert <a-e> '<a-;>j'
map global insert <c-v> '<c-r>"'

map global normal <c-n> ': new<ret>'
map global normal <c-d> ': ctrl-d<ret>'

# macro is rarely used
map global normal @ q

map global normal g t
map global normal t g
map global normal G T
map global normal T G

map global normal h i
map global normal H I
map global normal L <a-i>
map global normal l <a-a>
map global normal \; :

# jump
map global normal j <c-o>
map global normal J <tab>

map global normal <tab> \>
map global normal <s-tab> \<

map global normal <space> ': combined-space<ret>' -docstring 'reduce selections to their cursor'
map global normal <backspace> u
map global goto <backspace> UU -docstring 'redo'
map global normal '#' ': comment-prefer-line<ret>'
map global normal '^' ': comment-prefer-block<ret>'
map global insert '<a-f>' '<a-;>: comment-line<ret>'
map global goto l <a-\;>n -docstring 'next search pattern'
map global goto j <a-\;>:buffer-jump<ret> -docstring 'buffer jump'
map global goto k <a-\;>:buffer-previous<ret> -docstring 'buffer previous'
map global goto h <a-\;>:buffer-next<ret> -docstring 'buffer next'

map global goto n h -docstring 'line end'
map global goto e <esc><c-d>gc -docstring 'half page down'
map global goto i l -docstring 'line start'
map global goto u tvc -docstring 'half page up'
map global goto U k -docstring 'buffer top'
map global goto E j -docstring 'buffer bottom'

# Subline line
map global normal <c-l> <a-s>

map global insert <tab> <a-\;><gt>
map global insert <s-tab> <a-\;><lt>

# system paste
declare-option -hidden str paste_cmd %sh{
	if command -v pbpaste > /dev/null; then
		echo pbpaste
	elif command -v xsel > /dev/null; then
		echo xsel --clipboard
	elif command -v xclip > /dev/null; then
		echo xclip -out -sel clip
	elif command -v wl-paste > /dev/null; then
		echo wl-paste
	else
		echo false
	fi
}

# system copy
declare-option -hidden str copy_cmd %sh{
	if command -v pbcopy > /dev/null; then
		echo pbcopy
	elif command -v wl-copy > /dev/null; then
		echo wl-copy '>' /dev/null '2>&1'
	else
		echo false
	fi
}

map global user p %sh{echo "<a-!> $kak_opt_paste_cmd<ret>"} -docstring 'paste after from system clipboard'
map global user P %sh{echo "! $kak_opt_paste_cmd<ret>"}     -docstring 'paste before from system clipboard'
map global user y %sh{echo "<a-|> $kak_opt_copy_cmd<ret>"}  -docstring 'copy to system clipboard'
map global user <space> ': enter-user-mode lsp<ret>'        -docstring 'enter lsp mode'

# tmux int.
declare-user-mode tmux
map global normal w ': enter-user-mode tmux<ret>'
map global tmux n '! tmux select-pane -L<ret>' -docstring 'goto pane left' 
map global tmux e '! tmux select-pane -D<ret>' -docstring 'goto pane down'
map global tmux u '! tmux select-pane -U<ret>' -docstring 'goto pane up'
map global tmux i '! tmux select-pane -R<ret>' -docstring 'goto pane right'
map global tmux b '! tmux break-pane<ret>' -docstring 'break pane'
map global tmux a '! tmux previous-window<ret>' -docstring 'window: goto left' 
map global tmux s '! tmux next-window<ret>' -docstring 'window: goto right' 
map global tmux r ': prompt %{new window name } %{nop %sh{! tmux rename-window "$kak_text"}}<ret>' -docstring 'window: rename' 
map global tmux v '! tmux select-layout even-vertical<ret>' -docstring 'layout: even-vertical'
map global tmux h '! tmux select-layout even-horizontal<ret>' -docstring 'layout: even-horizontal'
map global tmux V '! tmux select-layout main-vertical<ret>' -docstring 'layout: main-vertical'
map global tmux H '! tmux select-layout main-horizontal<ret>' -docstring 'layout: main-horizontal'
map global tmux <space> '! tmux select-layout tiled<ret>' -docstring 'layout: tiled'

set global incsearch true

# kak-lsp - bring your own kak-lsp
eval %sh{kak-lsp --kakoune -s "$kak_session" --config "$kak_config/kak-lsp.toml"}
set global lsp_hover_anchor true
lsp-enable
lsp-auto-hover-enable
lsp-auto-signature-help-enable
lsp-stop-on-exit-enable

# Use tab for both indenting and completion

hook global InsertCompletionShow .* %{
	try %{
		execute-keys -draft 'h<a-K>\h<ret>'
		map window insert <tab> <c-n>
		map window insert <s-tab> <c-p>
	}
}

hook global InsertCompletionHide .* %{
	unmap window insert <tab> <c-n>
	unmap window insert <s-tab> <c-p>
}

hook global BufCreate .* %{
	try editorconfig-load
	try modeline-parse
	eval %sh{
		if [ -f "$kak_buffile" ]; then
			bang=$(sed -E '1{s0^#!(/usr/bin/env|/bin/) *00; s/ .*$//}; q' "$kak_buffile")
			filetype=$(
				case "$bang" in
					node)
						printf 'javascript'
						;;
					dash)
						printf 'sh'
						;;
				esac
			)

			if [ "$filetype" ]; then
				printf 'set buffer filetype %s' "$filetype"
			fi
		fi
	}
}

hook global WinSetOption filetype=typescript %{
	set buffer autoreload yes
	set buffer formatcmd %sh{
		# if [ -e "$tool prettier-eslint" ]; then
		echo cat '<<' EOF '|' dash '2>/dev/null >/dev/null &'
		echo yarny prettier --write "$(realpath "$kak_buffile")"  
		echo yarny eslint --fix "$(realpath "$kak_buffile")"
		echo EOF
		# elif [ -e "$tool eslint" ]; then
			# echo "$tool eslint --fix $kak_buffile >/dev/null 2>&1 &"
		# elif [ -e "$tool prettier" ]; then
			# echo "$tool prettier --write $kak_buffile >/dev/null 2>&1 &"
		# fi

		echo cat
	}

	set buffer lintcmd %sh{
		format="--format=$HOME/.npm/global-packages/lib/node_modules/eslint-formatter-kakoune"
		ignore_last="ruby -e 'system *ARGV[0...-1]'"
		if [ x"$tool" != x"" ]; then
			printf "%s yarny %s %s %s" "$ignore_last" eslint "$format" "$kak_buffile"
		fi
	}

	hook buffer BufWritePost .*\.tsx? format
	map global insert <a-ret> '<a-;>x<a-;>| emmet<ret>'
}

hook global WinSetOption filetype=(html|less|json) %{
	set buffer autoreload yes
	set buffer extra_word_chars '_' '-'
	set buffer formatcmd %sh{
		echo yarny prettier --write "$(realpath "$kak_buffile")" '>/dev/null 2>/dev/null &' cat
	}
	hook buffer BufWritePost .* format
	map global insert <a-ret> '<a-;>x<a-;>| emmet<ret>'

}

hook global WinSetOption filetype=javascript %{
	set buffer autoreload yes
	set buffer formatcmd %sh{echo "$(npm bin)/prettier" "$kak_buffile"}
	eval %sh{
		basepath=$(npm bin)
		format="--format=$HOME/.npm/global-packages/lib/node_modules/eslint-formatter-kakoune"
		prefix='set buffer lintcmd'
		if [ -e "$basepath/eslint" ]; then
			printf "%s %s %s\nlint-enable\nlint" "$prefix" "$basepath/eslint" "$format"
		fi
	}

	hook buffer BufWritePost .*\.jsx? format
}

hook global WinSetOption filetype=(kak|sh) %{
	hook buffer ModeChange .*:.insert:normal %{
		lint
	}
}

# hook global WinSetOption filetype=(sass|css|scss|less) %{
# 	set buffer lintcmd %sh{
# 		ignore_last="ruby -e 'system *ARGV[0...-1]'"
# 		echo $ignore_last yarny stylelint --formatter json "$(realpath "$kak_buffile")" '|' \
# 			jq '.[] | .source as $source | .warnings[] | [$source, .line, .column, .severity, .text | tostring] | join(":")' -r
# 	}


hook global WinSetOption filetype=(asciidoc|md) autowrap-enable

hook global WinSetOption filetype=git-rebase %{
	map buffer normal <ret> '<a-x>s^[a-z]+ ([a-f0-9]+) <ret>: git show <c-r>1<ret>'
	map buffer normal <tab> '<a-x>s^[a-z]+ ([a-f0-9]+) <ret>: git show <c-r>1<ret>: buffer-previous<ret>'
}

set-face global Whitespace rgb:333333,default
add-highlighter global/ show-whitespaces -spc " " -tab "▏" -lf " "

add-highlighter global/ column 79 default,rgb:404040
add-highlighter global/ column 80 default,rgb:404040
add-highlighter global/ column 81 default,rgb:404040
add-highlighter global/ column 119 default,rgb:404040
add-highlighter global/ column 120 default,rgb:404040
add-highlighter global/ column 121 default,rgb:404040

hook global ModeChange .*:normal:insert %{
	set-face buffer Default rgb:D8D8D8,rgb:0F0F0F
	try %{
		add-highlighter buffer/ number-lines -hlcursor -separator " " -min-digits 3
		add-highlighter buffer/ line '%val{cursor_line}' default,rgb:404040
	}
}

hook global ModeChange .*:insert:normal %{
	unset-face buffer Default
	remove-highlighter buffer/number-lines_-hlcursor_-separator_\ _-min-digits_3
	remove-highlighter buffer/line_%val{cursor_line}_default,rgb:404040
}

# why
hook global BufCreate .*[.](less) %{
	set-option buffer filetype scss
}

hook global BufCreate .*[.](conf) %{
	add-highlighter buffer/ regex '^#[^\n]*$' 0:comment
}

hook global BufCreate .*[.](xlf) %{
	set window filetype 'xml'
}

declare-option str modeline_git_branch
set global modeline_git_branch ''

define-command -params 1 update-modeline %{
	set %arg{1} modelinefmt '%val{bufname} L%val{cursor_line}#%val{cursor_char_column} %opt{modeline_git_branch}{{context_info}} {{mode_info}} - %val{session}'
}

hook global WinCreate .* %{
	hook window NormalIdle .* %{
		eval %sh{
			branch=$(cd "$(dirname "$kak_buffile")" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
			if [ -n "$branch" ]; then
				printf 'set window modeline_git_branch "[%%{%s}]"\n' "$branch"
			else
				printf 'set window modeline_git_branch ""\n'
			fi
		}

		update-modeline window
	}
}

hook global BufCreate \*scratch\* %{
	execute-keys '%d! ls<ret>'
	map buffer normal <ret> '<a-x>_: edit %val{selection}<ret>'
}

# Some notes
# _ : trim selection
# & : align selection
# <c-i> : jumps backward
# <c-o> : jumps forward

