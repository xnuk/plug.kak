try %{ require-module plug } catch %{

provide-module plug %{
	declare-option -hidden str-list plug_modules
	declare-option -hidden str-list plug_eager_modules

	hook -once global KakBegin '.*' %{
		nop %sh{(
			plugpath="$kak_config/plugins"

			for m in $kak_opt_plug_modules; do
				mod="${m%%#*}"
				path="$plugpath/$mod"

				if [ -d "$path" ]; then
				(
					(
						fd --type=f -e kak . "$path" -X cat
						echo "try %{ require-module $mod } catch %{ provide-module $mod nop; require-module $mod }"
					) | kak -p "$kak_session" > /dev/null 2>&1
				) &
				fi
			done
		) > /dev/null 2>&1 < /dev/null &}

		set-option -add global plug_modules %opt{plug_eager_modules}

		unalias global plug! plug-force
		define-command -override -hidden -params 100 plug-register %{}
		define-command -override -hidden -params 100 plug-force %{}

		define-command -override -params 0 plug %{
			nop %sh{(
				plugpath="$kak_config/plugins"

				for m in $kak_opt_plug_modules; do
					mod="${m%%#*}"
					path="$plugpath/$mod"
					repo="${m#*#}"
					ref="${repo##*#}"
					repo="${repo%#*}"


					if [ ! -d "$path" ]; then (
						set -e

						git clone "$repo" "$path" --recurse-submodules

						cd "$path"
						if [ "$ref" != "$repo" ]; then
							git switch --detach "origin/$ref" ||
							git switch --detach "$ref"
						fi

					) &
					else (
						set -e

						cd "$path"
						git fetch origin
						if [ "$ref" = "$repo" ]; then
							ref=HEAD
						fi

						git switch --detach "origin/$ref" ||
						git switch --detach "$ref"
					) &
					fi
				done
			) > /dev/null 2>&1 < /dev/null &}
		}
	}

	define-command -hidden -params 2..3 plug-register %{
		eval %sh{
			force="$1"
			ops="$2"
			body="$3"

			a="${2%#*}"
			a="${a##*/}"
			a="${a##*:}"
			a="${a%%.*}"
			a="${a#kakoune-}"
			a="${a#kak-}"

			if [ "$force" = "yes" ]; then
				printf 'set-option -add global plug_eager_modules %%{%s#%s}\n' "$a" "$ops"
			else
				printf 'set-option -add global plug_modules %%{%s#%s}\n' "$a" "$ops"
			fi

			if [ -n "$body" ]; then
				printf 'hook -once global ModuleLoaded %s %%{%s}\n' "$a" "$body"
			fi

			plugpath="$kak_config/plugins"
			mod="$a"
			path="$plugpath/$mod"

			if [ "$force" = "yes" -a -d "$path" ]; then
				fd --type=f -e kak . "$path" -X cat
			fi
		}
	}

	define-command -params 1..2 plug %{
		plug-register "no" %arg{@}
	}

	define-command -hidden -params 1..2 plug-force %{
		plug-register "yes" %arg{@}
	}

	alias global plug! plug-force
}

}
