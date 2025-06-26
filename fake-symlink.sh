#!/usr/bin/env bash

# NEMO_SCRIPT_SELECTED_FILE_PATHS is an environment variable that has newline-delimited paths for selected files
# It is only present if the script was run on a local folder/file (ie: not through FTP, Samba, NFS, etc.)

fallback_directory_icon="inode-directory"
gio_is_installed=""


create_symlinks() {
    # Remove trailing '\n'
    NEMO_SCRIPT_SELECTED_FILE_PATHS="${NEMO_SCRIPT_SELECTED_FILE_PATHS%$'\n'}" 

    # Convert $NEMO_SCRIPT_SELECTED_FILE_PATHS into an array using '\n' as the separator
    readarray -t selected_file_paths <<< "$NEMO_SCRIPT_SELECTED_FILE_PATHS"

    # Iterate over each item that the script was called on
    for item in "${!selected_file_paths[@]}"; do

        # Make a fake symlink for folders and real symlinks for anything else
        if [[ -d "${selected_file_paths[$item]}" ]]; then
            file_extension=".desktop"

            if get_unique_filename; then
                make_fake_symlink
            fi
        else
            file_extension=""

            if get_unique_filename; then
                make_regular_symlink
            fi
        fi
    done
}


make_fake_symlink() {
    # If GIO's installation status wasn't checked previously, check it
    if [[ -z "$gio_is_installed" ]]; then
        is_gio_installed
    fi

    obtain_icon "${selected_file_paths[$item]}"

    echo -e "[Desktop Entry]\nName="$symlink_name"\nComment=\nExec=nemo --existing-window '${selected_file_paths[$item]}'\nType=Application\nIcon=$icon" > "${symlink_name}.desktop"
    add_emblem
    make_executable
}


make_regular_symlink() {
    ln -s "${selected_file_paths[$item]}" "$symlink_name"
}


# Generate a unique symlink filename if one already exists
get_unique_filename() {

    if [[ "$file_extension" == ".desktop" ]]; then
        type="Shortcut"
    else
        type="Link"
    fi
    
    # Get folder/file name without prepended path
    selected_file=${selected_file_paths[$item]##*/}

    max_duplicate_symlinks=99
    symlink_name_candidate="${type} to ${selected_file}"

    for ((i=2; i <= max_duplicate_symlinks+1; i++)); do

        # If filename is unique, use it
        if ! [[ -e "${symlink_name_candidate}${file_extension}" ]]; then
            symlink_name="$symlink_name_candidate"
            return 0
        else # Add a number to the filename, starting from 2
            symlink_name_candidate="${type} ${i} to ${selected_file}"
        fi
    done

    error_message "The maximimum amount of identical shortcuts/symlinks in a single directory to \"$selected_file\" that the script allows is ${max_duplicate_symlinks}."
    return 1
}


obtain_icon() {
    icon=""

    # Look for custom folder icon
    if [[ "$gio_is_installed" == "True" ]]; then
        icon=$(gio info "$1" | awk '/metadata::custom-icon-name:/ { print $2 }')

        if [[ -z "$icon" ]]; then
            # Look for primary standard icon
            icon=$(gio info "$1" | awk '/standard::icon:/ { gsub(/,/, "", $2); print $2 }')
        fi
    fi

    # If icon is not set
    if [[ -z "$icon" ]]; then
        icon="$fallback_directory_icon"
    fi
}


# GIO is used to get the icons of folders and to add symlink emblems to the application (.desktop) shortcuts
is_gio_installed() {
    if which gio >/dev/null 2>&1; then
        gio_is_installed="True"
    else
        gio_is_installed="False"
    fi
}


# Add symlink emblem to application (.desktop) shortcut
add_emblem() {
    if [[ "$gio_is_installed" == "True" ]]; then
        gio set -t stringv "${symlink_name}.desktop" metadata::emblems emblem-link && touch "${symlink_name}.desktop"
    fi
}


# Make the application (.desktop) shortcut executable
make_executable() {
    chmod +x "${symlink_name}.desktop"
}


error_message() {
    echo "$(date "+%D %r"): $1" >> 'Script error message.txt'
}


if [[ -z "$NEMO_SCRIPT_SELECTED_FILE_PATHS" ]]; then
    error_message >> "You need to select folders/files before running the script."
    exit 1
else
    create_symlinks
fi
