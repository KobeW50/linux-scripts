#!/usr/bin/env bash

# NEMO_SCRIPT_SELECTED_FILE_PATHS is an environment variable that has newline-delimited paths for selected files
# It is only present if the script was run on a local folder/file (ie: not through FTP, Samba, NFS, etc.)

fallback_directory_icon="inode-directory"
fallback_file_icon="filetypes"
gio_is_installed="False"

# GIO is used to get the icons of folders/files and to add symlink emblems to the application (.desktop) shortcuts
is_gio_installed() {
    if which gio >/dev/null 2>&1; then
        gio_is_installed="True"
    else
        gio_is_installed="False"
    fi
}


create_fake_symlinks() {
    is_gio_installed

    # Remove trailing '\n'
    NEMO_SCRIPT_SELECTED_FILE_PATHS="${NEMO_SCRIPT_SELECTED_FILE_PATHS%$'\n'}" 

    # Convert $NEMO_SCRIPT_SELECTED_FILE_PATHS into an array using '\n' as the separator
    readarray -t selected_file_paths <<< "$NEMO_SCRIPT_SELECTED_FILE_PATHS"

    for item in "${!selected_file_paths[@]}"; do

        # Obtain icon of folder/file
        obtain_icon "${selected_file_paths[$item]}"

        # Get folder/file name without prepended path
        selected_file=${selected_file_paths[$item]##*/}

        symlink_name="Link to $selected_file"

        # Create application (.desktop) shortcut:
        #
        # If item is a directory/folder make it a nemo shortcut
        if [[ -d "$selected_file" ]]; then
            echo -e "[Desktop Entry]\nName="$symlink_name"\nComment=\nExec=nemo --existing-window '${selected_file_paths[$item]}'\nType=Application\nIcon=$icon" > "${symlink_name}.desktop"

        # If item is a file or symlink open the file with the default application
        elif [[ -f "$selected_file" || -L "$selected_file" ]]; then
            echo -e "[Desktop Entry]\nName="$symlink_name"\nComment=\nExec=xdg-open '${selected_file_paths[$item]}'\nType=Application\nIcon=$icon" > "${symlink_name}.desktop"

        else
            error_message "${selected_file_paths[$item]} is a type of file that the script was not designed to handle. You can report the issue here: https://github.com/KobeW50/linux-scripts/issues"
        fi

        # Add symlink emblem to application (.desktop) shortcut
        if [[ "$gio_is_installed" == "True" ]]; then
            gio set -t stringv "${symlink_name}.desktop" metadata::emblems emblem-link && touch "${symlink_name}.desktop"
        fi

        # Make the application (.desktop) shortcut executable
        chmod +x "${symlink_name}.desktop"

    done
}


obtain_icon() {
    icon=""

    # Look for custom icon
    if [[ "$gio_is_installed" == "True" ]]; then
        icon=$(gio info "$1" | awk '/metadata::custom-icon-name:/ { print $2 }')

        if [[ -z "$icon" ]]; then
            # Look for primary standard icon
            icon=$(gio info "$1" | awk '/standard::icon:/ { gsub(/,/, "", $2); print $2 }')
        fi
    fi

    # If icon is not set
    if [[ -z "$icon" && -d $1 ]]; then
        icon="$fallback_directory_icon"
    elif [[ -z "$icon" ]]; then
        icon="$fallback_file_icon"
    fi
}   


error_message() {
    echo "$1" > 'Script error message.txt'
    exit 1
}


if [[ -z "$NEMO_SCRIPT_SELECTED_FILE_PATHS" ]]; then
    error_message "You need to select folders/files before running the script."
else
    create_fake_symlinks
fi
