#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cmd="${1:-}"
shift || true

args=()
if [[ "$cmd" == "view" ]]; then
  pdf_path=""
  input_spec=""
  passthrough=()
  while (($#)); do
    case "$1" in
      -i)
        input_spec="$2"
        shift 2
        ;;
      -o)
        pdf_path="$2"
        shift 2
        ;;
      *)
        passthrough+=("$1")
        shift
        ;;
    esac
  done

  if [[ -n "$input_spec" && -n "$pdf_path" ]]; then
    IFS=: read -r line col input_path <<<"$input_spec"
    pdf_abs="$(realpath -m "$pdf_path")"
    src_abs="$(realpath -m "$input_path")"
    pdf_dir="$(dirname "$pdf_abs")"
    rel_input="$(realpath --relative-to="$pdf_dir" "$src_abs")"
    case "$rel_input" in
      ./*|../*) ;;
      *) rel_input="./$rel_input" ;;
    esac
    args=(view -i "${line}:${col}:${rel_input}" -o "$pdf_abs" -d "$pdf_dir" "${passthrough[@]}")
  else
    args=(view "${passthrough[@]}")
  fi
else
  args=("$cmd" "$@")
fi

cd "$repo_root"
exec docker compose -f docker/docker-compose.yml run --rm slides synctex "${args[@]}"
