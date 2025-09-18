from pathlib import Path
import os
from json import load

raw_import_data: dict = {}
wa_class_list: list = []
wa_non_class_list: list = []
mdt_w_routes_list: list = []
mdt_adv_routes_list: list = []


def get_import_files():
    base_dir: Path = Path(__file__).parent
    imports_dir: Path = base_dir.joinpath("imports")

    for txt_path in imports_dir.rglob("*.txt"):
        rel = txt_path.relative_to(imports_dir)
        with txt_path.open("r", encoding="utf-8") as import_file:
            if rel.parts[0] == "weakauras":
                # WeakAuras lists
                if len(rel.parts) > 1 and rel.parts[1] == "class":
                    wa_class_list.append(import_file.read().strip().join(('"', '"')))
                elif len(rel.parts) > 1 and rel.parts[1] == "utility":
                    # Handle QUI Anchors separately for category 0
                    if rel.stem == "QUI Anchors":
                        raw_import_data["ANCHOR_WA"] = import_file.read().strip()
                    else:
                        wa_non_class_list.append(import_file.read().strip().join(('"', '"')))
            elif rel.parts[0] == "routes":
                # Optional MDT routes support
                if "PUG" in rel.name:
                    mdt_w_routes_list.append(import_file.read().strip().join(('"', '"')))
                elif "Adv" in rel.name:
                    mdt_adv_routes_list.append(import_file.read().strip().join(('"', '"')))
            else:
                # Everything else becomes a {PLACEHOLDER} by filename
                key = Path(rel.stem).name.upper()
                raw_import_data[key] = import_file.read().strip()


def get_template():
    base_dir: Path = Path(__file__).parent
    path: Path = base_dir.joinpath("imports_template.lua")
    with path.open() as template:
        return template.read()


def write_template(input):
    # Write generated imports to the QuaziiUI addon directory (one level up from tools)
    base_dir: Path = Path(__file__).parent
    path: Path = base_dir.parent.joinpath("QuaziiUI/imports.lua")
    with open(path, "w") as template:
        template.write(input)


def process_temple():
    template = get_template()
    wa_class_string = ",\n            ".join(wa_class_list)
    wa_non_class_string = ",\n            ".join(wa_non_class_list)

    template = template.replace('"{CLASS_WA}"', wa_class_string)
    template = template.replace('"{NON_CLASS_WA}"', wa_non_class_string)

    def lua_escape(value: str) -> str:
        escaped = value.replace('\\', r'\\')
        escaped = escaped.replace('"', r'\"')
        escaped = escaped.replace('\n', r'\n').replace('\r', r'\r')
        return escaped

    for k, v in raw_import_data.items():
        # Support both quoted and unquoted placeholders in the template
        quoted_placeholder = '"{' + k + '}"'
        unquoted_placeholder = '{' + k + '}'
        value_string = lua_escape(v)
        replacement = '"' + value_string + '"'
        template = template.replace(quoted_placeholder, replacement)
        template = template.replace(unquoted_placeholder, replacement)
    write_template(template)


get_import_files()

process_temple()
