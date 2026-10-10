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
mkdir -p "$project_dir/Helpers"
mkdir -p "$project_dir/reports"
echo "created the helpers and reports directories"
cp templates/attendance_checker.py "$project_dir/"
cp templates/config.json "$project_dir/Helpers/"

echo "Application and configuration files deployed."

echo "Choose how to build the roster:"
echo "A. Copy students from the template"

read -p "Enter A to continue: " roster_choice

if [ "$roster_choice" = "A" ] || [ "$roster_choice" = "a" ]
then
    read -p "How many students do you want to copy (1-10)? " student_count

    if [[ "$student_count" =~ ^[0-9]+$ ]] && [ "$student_count" -ge 1 ] && [ "$student_count" -le 10 ]
    then
        head -n "$((student_count + 1))" templates/assets.csv > "$project_dir/Helpers/assets.csv"
        echo "Copied $student_count students into the roster."
    else
        echo "Error: enter a whole number between 1 and 10."
        exit 1
    fi
else
    echo "Invalid choice. Enter A for now."
    exit 1
fi
