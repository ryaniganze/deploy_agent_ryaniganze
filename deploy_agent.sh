#!/bin/bash
if ! command -v python3 > /dev/null
then
    echo "Error: python3 is not installed."
    exit 1
fi

if ! command -v zip > /dev/null
then
    echo "Error: zip is not installed."
    exit 1
fi

echo "Pre-flight checks passed."

read -p "Enter project name: " project_name

project_dir="attendance_tracker_${project_name}"
if [ -d "$project_dir" ]
then
	 read -p "Directory $project_dir already exists. Overwrite it? (y/n): " answer

    if [ "$answer" = "y" ]
    then
        rm -rf "$project_dir"
        mkdir "$project_dir"
        echo "Existing project directory overwritten."
    else
        echo "Deployment aborted."
        exit 1
    fi
else
    mkdir "$project_dir"
    echo "Created project directory: $project_dir"
fi
