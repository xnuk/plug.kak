provide-module plug %{
	declare-option -hidden str-list plug_modules
	declare-option -hidden str-list plug_update_script_git_opts

	define-command -hidden -params 1 load-module %{
		try %{
			require-module %arg{1}
		} catch %{
			echo -debug "could not find module: %arg{1}"
		}
	}

	hook -once global KakBegin '.*' %{
		eval %sh{
			for m in $kak_opt_plug_modules; do
				printf 'load-module %%{%s}\n' "$m"
			done
		}
	}

	define-command -params 0.. plug %{
		eval %sh{
			if [ -z "$1" ]; then
				echo echo hi
				exit
			fi

			ops=$1
			body=$2
			set -- "$1"
			a=${1##*/}
			a=${a##*:}
			a=${a%%.*}
			a=${a#kakoune-}
			a=${a#kak-}
			printf 'set-option -add global plug_modules %%{%s}\n' "$a"
			printf 'set-option -add global plug_update_script_git_opts %%{%s}\n' "$ops"
			printf 'hook -once global ModuleLoaded %s %%{nop\n%s}\n' "$a" "$body"
		}
	}
}













































nop %{
plug github:alexherbo2/surround.kak %{
	map global normal \' ': enter-user-mode surround<ret>'
	map global normal q ': enter-user-mode surround<ret>'
	map global normal ( ': enter-user-mode surround<ret>('
}

plug github:alexherbo2/search-highlighter.kak %{
	search-highlighter-enable
	set-face global Search rgb:000000,rgb:FFFF00+F
}

plug %{github:dead10ck/auto-pairs.kak -b remove-kcr} %{
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

