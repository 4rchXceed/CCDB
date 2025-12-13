# Generate a setup, simpler to have 1 file for CC
import json
import os


def add_folder(folder: str, first=False) -> list:
    files = []
    files_or_dirs = os.listdir(folder)

    for file in files_or_dirs:
        full_path = folder + "/" + file

        if os.path.isfile(full_path):
            with open(full_path, "r", encoding="utf-8") as f_src:
                files.append(
                    {
                        "t": 1,
                        "p": full_path,
                        "c": f_src.read(),
                    }
                )
        else:
            files.append({"t": 2, "p": full_path})
            files.extend(add_folder(full_path))

    return files


files = add_folder("src", True)

obj = json.dumps(files)

with open("runner.lua", "r", encoding="utf-8") as f_src:
    code = f_src.read().replace("%JSON%", json.dumps(obj))
    with open("bin.lua", "w", encoding="utf-8") as f_src:
        f_src.write(code)
