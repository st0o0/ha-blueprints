#!/usr/bin/env python3
"""Validate HA blueprint YAML files: input references + Jinja2 syntax."""

import sys
import os
import re
import glob

import yaml
import jinja2


class InputRef:
    """Marker for !input YAML tags."""

    def __init__(self, name, line=None):
        self.name = name
        self.line = line

    def __repr__(self):
        return f"!input {self.name}"


class InputRefLoader(yaml.SafeLoader):
    """YAML loader that captures !input tags as InputRef markers."""

    pass


def _input_constructor(loader, node):
    value = loader.construct_scalar(node)
    return InputRef(value, line=node.start_mark.line + 1)


InputRefLoader.add_constructor("!input", _input_constructor)

for tag in ("!include", "!include_dir_list", "!include_dir_named",
            "!include_dir_merge_list", "!include_dir_merge_named",
            "!secret", "!env_var"):
    InputRefLoader.add_constructor(tag, lambda loader, node: None)


def collect_input_refs(node, path=""):
    """Recursively collect all InputRef instances from a parsed YAML tree."""
    refs = []
    if isinstance(node, InputRef):
        refs.append((node.name, node.line, path))
    elif isinstance(node, dict):
        for key, value in node.items():
            child_path = f"{path}.{key}" if path else key
            refs.extend(collect_input_refs(value, child_path))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            refs.extend(collect_input_refs(item, f"{path}[{i}]"))
    return refs


def collect_defined_inputs(blueprint_input, prefix=""):
    """Extract all defined input names, handling nested sections."""
    defined = {}
    if not isinstance(blueprint_input, dict):
        return defined

    for key, value in blueprint_input.items():
        if isinstance(value, dict) and "input" in value and "name" in value:
            defined[key] = {"line": None, "is_section": True}
            defined.update(collect_defined_inputs(value["input"], prefix))
        else:
            defined[key] = {"line": None, "is_section": False}

    return defined


JINJA2_DELIMITERS = re.compile(r"\{\{|\{%|\{#")


def extract_templates(node, path="", line_offset=0):
    """Extract Jinja2 template strings from YAML values."""
    templates = []
    if isinstance(node, str) and JINJA2_DELIMITERS.search(node):
        templates.append((node, path, line_offset))
    elif isinstance(node, dict):
        for key, value in node.items():
            if isinstance(value, InputRef):
                continue
            child_path = f"{path}.{key}" if path else key
            templates.extend(extract_templates(value, child_path, line_offset))
    elif isinstance(node, list):
        for i, item in enumerate(node):
            templates.extend(extract_templates(item, f"{path}[{i}]", line_offset))
    return templates


def validate_file(filepath):
    """Validate a single blueprint file. Returns (errors, warnings)."""
    errors = []
    warnings = []
    filename = os.path.basename(filepath)

    with open(filepath, "r", encoding="utf-8") as f:
        raw_content = f.read()

    try:
        data = yaml.load(raw_content, Loader=InputRefLoader)
    except yaml.YAMLError as e:
        errors.append((filename, 0, f"YAML parse error: {e}"))
        return errors, warnings

    if not isinstance(data, dict) or "blueprint" not in data:
        return errors, warnings

    blueprint = data["blueprint"]
    if not isinstance(blueprint, dict) or "input" not in blueprint:
        return errors, warnings

    # --- Input reference validation ---
    defined_inputs = collect_defined_inputs(blueprint["input"])

    body = {k: v for k, v in data.items() if k != "blueprint"}
    all_refs = collect_input_refs(body)

    referenced_names = set()
    for ref_name, ref_line, ref_path in all_refs:
        referenced_names.add(ref_name)
        if ref_name not in defined_inputs:
            errors.append((
                filename, ref_line or 0,
                f"Undefined input reference '!input {ref_name}' at {ref_path}"
            ))

    for input_name, info in defined_inputs.items():
        if input_name not in referenced_names and not info["is_section"]:
            warnings.append((
                filename, 0,
                f"Input '{input_name}' is defined but never referenced via !input"
            ))

    # --- Jinja2 syntax validation ---
    env = jinja2.Environment()
    templates = extract_templates(data, line_offset=0)

    for template_str, field_path, _ in templates:
        try:
            env.parse(template_str)
        except jinja2.TemplateSyntaxError as e:
            line_in_yaml = _find_template_line(raw_content, template_str)
            errors.append((
                filename, line_in_yaml,
                f"Jinja2 syntax error in {field_path}: {e.message}"
            ))

    return errors, warnings


def _find_template_line(raw_content, template_str):
    """Best-effort line number for a template string in the raw YAML."""
    snippet = template_str.strip()[:60]
    for i, line in enumerate(raw_content.splitlines(), 1):
        if snippet in line:
            return i
    return 0


def main():
    if len(sys.argv) > 1:
        files = sys.argv[1:]
    else:
        files = sorted(
            glob.glob("ikea_*.yaml") +
            glob.glob("njord_*.yaml")
        )

    if not files:
        print("No blueprint files found.")
        return 0

    total_errors = 0
    total_warnings = 0

    for filepath in files:
        if not os.path.isfile(filepath):
            print(f"::error file={filepath}::File not found")
            total_errors += 1
            continue

        errors, file_warnings = validate_file(filepath)
        total_errors += len(errors)
        total_warnings += len(file_warnings)

        for filename, line, msg in errors:
            line_part = f",line={line}" if line else ""
            print(f"::error file={filename}{line_part}::{msg}")

        for filename, line, msg in file_warnings:
            line_part = f",line={line}" if line else ""
            print(f"::warning file={filename}{line_part}::{msg}")

    print()
    print(f"Checked {len(files)} file(s): "
          f"{total_errors} error(s), {total_warnings} warning(s)")

    return 1 if total_errors > 0 else 0


if __name__ == "__main__":
    sys.exit(main())
