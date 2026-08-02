#!/usr/bin/env bash
# Verify that snooze parse and write blocks are structurally identical
# across all Njord blueprints. Blueprint-specific key variable names
# are normalized before comparison so only structural drift is caught.

set -euo pipefail

exit_code=0
parse_hashes=()
write_hashes=()
parse_files=()
write_files=()

normalize() {
  # Strip leading whitespace, normalize blueprint-specific key names
  # and snooze_hours defaults (which vary intentionally per blueprint)
  sed -E \
    -e 's/^[[:space:]]*//' \
    -e 's/[a-z_]+_key/__SNOOZE_KEY__/g' \
    -e 's/snooze_hours \| float\([0-9]+\)/snooze_hours | float(__SNOOZE_DEFAULT__)/g'
}

extract_parse_block() {
  # Extract first block: snooze_raw_state → snooze_pairs → is_snoozed (+ its value line)
  awk '
    /^[[:space:]]*snooze_raw_state:/ && !done { printing=1 }
    printing { print }
    /^[[:space:]]*is_snoozed:/ && printing {
      getline
      if (/\{\{/) print
      printing=0; done=1
    }
  ' "$1"
}

extract_write_block() {
  # Extract first snooze_write block (all instances are identical per blueprint)
  awk '
    /snooze_write_now_ts:/ && !done { printing=1 }
    printing { print }
    /value:.*snooze_write_new_state/ && printing {
      printing=0; done=1
    }
  ' "$1"
}

files=(njord_*.yaml)
if [[ ${#files[@]} -eq 0 ]] || [[ ! -f "${files[0]}" ]]; then
  echo "No njord_*.yaml files found"
  exit 0
fi

for file in "${files[@]}"; do
  parse_block=$(extract_parse_block "$file" | normalize)
  write_block=$(extract_write_block "$file" | normalize)

  if [[ -n "$parse_block" ]]; then
    hash=$(echo "$parse_block" | sha256sum | cut -d' ' -f1)
    parse_hashes+=("$hash")
    parse_files+=("$file")
  fi

  if [[ -n "$write_block" ]]; then
    hash=$(echo "$write_block" | sha256sum | cut -d' ' -f1)
    write_hashes+=("$hash")
    write_files+=("$file")
  fi
done

# Completeness check
expected_parse=${#files[@]}
actual_parse=${#parse_hashes[@]}
if [[ $actual_parse -eq 0 ]]; then
  echo "::error::No snooze parse blocks found in any njord_*.yaml file"
  exit_code=1
elif [[ $actual_parse -lt $expected_parse ]]; then
  echo "::warning::Found snooze parse blocks in $actual_parse of $expected_parse njord files"
  for file in "${files[@]}"; do
    found=0
    for pf in "${parse_files[@]}"; do
      [[ "$pf" == "$file" ]] && found=1
    done
    if [[ $found -eq 0 ]]; then
      echo "  Missing parse block: $file"
    fi
  done
fi

actual_write=${#write_hashes[@]}
if [[ $actual_write -eq 0 ]]; then
  echo "::error::No snooze write blocks found in any njord_*.yaml file"
  exit_code=1
elif [[ $actual_write -lt $actual_parse ]]; then
  echo "::warning::Found snooze write blocks in $actual_write of $actual_parse files with parse blocks"
fi

# Consistency check — parse blocks
if [[ ${#parse_hashes[@]} -gt 1 ]]; then
  ref_hash="${parse_hashes[0]}"
  for i in "${!parse_hashes[@]}"; do
    if [[ "${parse_hashes[$i]}" != "$ref_hash" ]]; then
      echo "::error file=${parse_files[$i]}::Snooze parse block differs from ${parse_files[0]}"
      exit_code=1
    fi
  done
fi

# Consistency check — write blocks
if [[ ${#write_hashes[@]} -gt 1 ]]; then
  ref_hash="${write_hashes[0]}"
  for i in "${!write_hashes[@]}"; do
    if [[ "${write_hashes[$i]}" != "$ref_hash" ]]; then
      echo "::error file=${write_files[$i]}::Snooze write block differs from ${write_files[0]}"
      exit_code=1
    fi
  done
fi

echo ""
if [[ $exit_code -eq 0 ]]; then
  echo "Snooze consistency: ${actual_parse} parse + ${actual_write} write blocks checked — all identical."
else
  echo "Snooze consistency check FAILED."
fi

exit $exit_code
