from subprocess import call

PATHS = {
    "HYPR": "/home/emph/.config/hypr/",
    "HYPRPAPER": "/home/emph/.config/hypr/",
    "HYPRLOCK": "/home/emph/.config/hypr",
}

WALLPAPER = "/home/emph/Pictures/Wallpapers/eyes-on-black.png"


def file_read(key, path):
    content = []
    if key == "HYPRPAPER":
        hypr_substitute(path, content)
    else:
        with open(path, "r") as f:
            for line in f:
                content.append(line)
        hyprlock_substitute(path, content)


def hypr_substitute(path, content):
    content = ["preload= ," + WALLPAPER + "\n", "wallpaper= ," + WALLPAPER + "\n"]
    file_write(path, content)
    hyprpaper_update(WALLPAPER)
    matugen_update(WALLPAPER, "dark", "scheme-tonal-spot")
    return


def hyprpaper_update(wallpaper):
    call(["hyprctl", "hyprpaper", "reload", "," + wallpaper])


def matugen_update(wallpaper, mode, scheme):
    if not mode:
        mode = "dark"
    if not scheme:
        scheme = "scheme-tonal-spot"
    call(["matugen", "image", wallpaper, "--mode", mode, "--type", scheme])


def hyprlock_substitute(path, content):
    in_background_field = False
    for x in range(0, len(content)):
        if in_background_field:
            if "path" in content[x].lower():
                content[x] = "\tpath = " + WALLPAPER + "\n"
                file_write(path, content)
                return
        if "background" in content[x].lower():
            in_background_field = True


def file_write(path, content):
    with open(path, "w") as f:
        for line in content:
            f.write(line)


def main():
    for p in PATHS:
        print(p)

    file_read("HYPRPAPER", "/home/emph/.config/hypr/hyprpaper.conf")
    file_read("HYPRLOCK", "/home/emph/.config/hypr/hyprlock.conf")


if __name__ == "__main__":
    main()
