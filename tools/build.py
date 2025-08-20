from pathlib import Path
import os
from json import load

raw_import_data: dict = {}
wa_class_list: list = []
wa_non_class_list: list = []
mdt_w_routes_list: list = []
mdt_adv_routes_list: list = []


def get_import_files():
    path = "./tools/imports"
    for subdir, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".txt"):
                txt_path = os.path.join(subdir, file)
                txt_base = txt_path.replace("./src/data/json", "")
                txt_base = txt_base.replace("/", "_")
                txt_base = txt_base.replace("\\", "_")[1:]
                txt_split = txt_base.split(".")[0][1:]
                txt_split = (
                    txt_base.replace("tools_", "")
                    .replace("imports_", "")
                    .replace("addons_", "")
                    .replace("weakauras_class_", "")
                    .replace("elvui_", "")
                    .replace("weakauras_non-class_", "")
                )[1:][:-4]
                with open(txt_path, "r", encoding="utf-8") as import_file:
                    if "routes" in txt_path:
                        if "PUG" in txt_path:
                            mdt_w_routes_list.append(
                                import_file.read().strip().join(('"', '"'))
                            )
                        elif "Adv" in txt_path:
                            mdt_adv_routes_list.append(
                                import_file.read().strip().join(('"', '"'))
                            )
                    elif "weakauras" in txt_path:
                        if "class" in txt_path:
                            wa_class_list.append(
                                import_file.read().strip().join(('"', '"'))
                            )
                        elif "utility" in txt_path:
                            wa_non_class_list.append(
                                import_file.read().strip().join(('"', '"'))
                            )
                    else:
                        raw_import_data[txt_split] = import_file.read().strip()


def get_template():
    path: Path = Path.cwd().joinpath("tools/imports_template.lua")
    with path.open() as template:
        return template.read()


def write_template(input):
    path: Path = Path.cwd().joinpath("QuaziiUI/imports.lua")
    with open(path, "w") as template:
        template.write(input)


def process_temple():
    template = get_template()
    wa_class_string = ",\n            ".join(wa_class_list)
    wa_non_class_string = ",\n            ".join(wa_non_class_list)

    template = template.replace('"{CLASS_WA}"', wa_class_string)
    template = template.replace('"{NON_CLASS_WA}"', wa_non_class_string)

    for k, v in raw_import_data.items():
        replace_string = "{" + k + "}"
        value_string = v
        template = template.replace(replace_string, value_string)
    write_template(template)


get_import_files()

process_temple()
