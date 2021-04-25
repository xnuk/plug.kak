try %{ require-module plug } catch %{

provide-module plug %{
	declare-option str-list plug_modules
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
						if [ "$ref" != "$repo" ]; then
							git switch --detach "origin/$ref" ||
							git switch --detach "$ref"
						fi
					) &
					fi
				done
			) > /dev/null 2>&1 < /dev/null &}
		}
	}

	define-command -params 1..2 plug %{
		eval %sh{
			ops="$1"
			body="$2"

			a="${1%#*}"
			a="${a##*/}"
			a="${a##*:}"
			a="${a%%.*}"
			a="${a#kakoune-}"
			a="${a#kak-}"

			printf 'set-option -add global plug_modules %%{%s#%s}\n' "$a" "$ops"

			if [ -n "$body" ]; then
				printf 'hook -once global ModuleLoaded %s %%{%s}\n' "$a" "$body"
			fi
		}
	}
}

}
