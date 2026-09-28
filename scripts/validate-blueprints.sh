#!/usr/bin/env bash
# Validate HA blueprint Jinja2 templates for known anti-patterns.
# No dependencies beyond grep/awk — no Python.

set -euo pipefail

exit_code=0
error_count=0

err() {
  local file=$1 line=$2 msg=$3
  echo "::error file=${file},line=${line}::${msg}"
  echo "  ${file}:${line}: ${msg}"
  error_count=$((error_count + 1))
  exit_code=1
}

check_file() {
  local file=$1
  echo "::group::Checking ${file}"

  local in_vars=0 vars_indent=""
  local line_num=0

  while IFS= read -r line; do
    line_num=$((line_num + 1))

    # Detect variables: block start
    if [[ "$line" =~ ^([[:space:]]*)variables:[[:space:]]*$ ]]; then
      in_vars=1
      vars_indent="${BASH_REMATCH[1]}"
      continue
    fi

    # Detect end of variables block (line with same or less indentation)
    if [[ $in_vars -eq 1 ]] && [[ -n "$line" ]] && [[ ! "$line" =~ ^[[:space:]]*# ]]; then
      local stripped="${line#"${line%%[![:space:]]*}"}"
      local current_indent="${line%%"$stripped"}"
      if [[ ${#current_indent} -le ${#vars_indent} ]] && [[ -n "$stripped" ]]; then
        in_vars=0
      fi
    fi

    if [[ $in_vars -eq 1 ]]; then
      # Check 1: Wrapper-unsafe .split() without | string)
      if echo "$line" | grep -qP '\.split\s*\(' && ! echo "$line" | grep -qP '\|\s*string\)\.split\s*\('; then
        err "$file" "$line_num" "Wrapper-unsafe .split() in variables block — use (var | string).split()"
      fi

      # Check 1b: Wrapper-unsafe .startswith()
      if echo "$line" | grep -qP '\.startswith\s*\(' && ! echo "$line" | grep -qP '\|\s*string\)\.startswith\s*\('; then
        err "$file" "$line_num" "Wrapper-unsafe .startswith() in variables block — use (var | string).startswith()"
      fi

      # Check 1c: Wrapper-unsafe .endswith()
      if echo "$line" | grep -qP '\.endswith\s*\(' && ! echo "$line" | grep -qP '\|\s*string\)\.endswith\s*\('; then
        err "$file" "$line_num" "Wrapper-unsafe .endswith() in variables block — use (var | string).endswith()"
      fi

      # Check 2: Unguarded has_value()
      if echo "$line" | grep -qP 'has_value\(\w+\)' && ! echo "$line" | grep -qP 'is string.*has_value'; then
        err "$file" "$line_num" "Unguarded has_value() — guard with 'var is string and var | length > 0'"
      fi
    fi
  done < "$file"

  # Check 3: to_json in value: fields (JSON storage anti-pattern)
  while IFS=: read -r lnum _; do
    err "$file" "$lnum" "to_json in value field — HA native rendering auto-parses JSON; use pipe-delimited strings"
  done < <(grep -nP 'value:\s*".*to_json.*"' "$file" 2>/dev/null || true)

  # Check 4: Empty JSON "{}" as clear value
  while IFS=: read -r lnum _; do
    err "$file" "$lnum" 'Empty JSON "{}" as value — use empty string "" instead'
  done < <(grep -nP 'value:\s*"\{\}"' "$file" 2>/dev/null || true)

  # Check 5: from_json usage
  while IFS=: read -r lnum _; do
    err "$file" "$lnum" "from_json is unreliable under HA native rendering — avoid in variables blocks"
  done < <(grep -nP 'from_json' "$file" 2>/dev/null || true)

  # Check 6: Unmatched Jinja2 delimiters
  local open_expr close_expr open_stmt close_stmt
  open_expr=$({ grep -oP '\{\{' "$file" || true; } | wc -l)
  close_expr=$({ grep -oP '\}\}' "$file" || true; } | wc -l)
  if [[ "$open_expr" -ne "$close_expr" ]]; then
    err "$file" "0" "Unmatched Jinja2 expression delimiters: ${open_expr} {{ vs ${close_expr} }}"
  fi

  open_stmt=$({ grep -oP '\{%' "$file" || true; } | wc -l)
  close_stmt=$({ grep -oP '%\}' "$file" || true; } | wc -l)
  if [[ "$open_stmt" -ne "$close_stmt" ]]; then
    err "$file" "0" "Unmatched Jinja2 statement delimiters: ${open_stmt} {% vs ${close_stmt} %}"
  fi

  echo "::endgroup::"
}

# Find blueprint files
files=(ikea_*.yaml njord_*.yaml)
if [[ ${#files[@]} -eq 0 ]] || [[ ! -f "${files[0]}" ]]; then
  echo "No blueprint files found (ikea_*.yaml, njord_*.yaml)"
  exit 0
fi

for file in "${files[@]}"; do
  check_file "$file"
done

echo ""
if [[ $exit_code -eq 0 ]]; then
  echo "All ${#files[@]} blueprint files passed Jinja2 anti-pattern checks."
else
  echo "Found ${error_count} issue(s) across blueprint files."
fi

exit $exit_code
