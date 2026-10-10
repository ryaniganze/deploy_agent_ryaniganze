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
echo "B. Generate a fresh roster"

read -p "Enter A or B: " roster_choice

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

elif [ "$roster_choice" = "B" ] || [ "$roster_choice" = "b" ]
then
    read -p "How many students do you want to create (1-10)? " student_count

    if [[ "$student_count" =~ ^[0-9]+$ ]] && [ "$student_count" -ge 1 ] && [ "$student_count" -le 10 ]
    then
        echo "mail,Names,Attendance Count,Absence Count" > "$project_dir/Helpers/assets.csv"

        names=("Alice Johnson" "Bob Smith" "Charlie Davis" "Diana Prince" "Ethan Cole" "Fatima Noor" "George Mensah" "Hannah Kim" "Ibrahim Osei" "Jasmine Lee")
        emails=("alice@example.com" "bob@example.com" "charlie@example.com" "diana@example.com" "ethan@example.com" "fatima@example.com" "george@example.com" "hannah@example.com" "ibrahim@example.com" "jasmine@example.com")

        for ((i=0; i<student_count; i++))
        do
            echo "${emails[$i]},${names[$i]},0,0" >> "$project_dir/Helpers/assets.csv"
        done

        sed -i 's/"total_sessions": 5/"total_sessions": 1/' "$project_dir/Helpers/config.json"

        echo "Generated $student_count students with zero prior attendance and absence counts."
        echo "Configuration updated: total_sessions is now 1."
    else
        echo "Error: enter a whole number between 1 and 10."
        exit 1
    fi

else
    echo "Invalid choice. Enter A or B."
    exit 1
fi

read -p "Do you want to update the alert thresholds? (y/n): " update_thresholds

if [ "$update_thresholds" = "y" ] || [ "$update_thresholds" = "Y" ]
then
    read -p "Enter warning threshold (default 75): " warning
    read -p "Enter failure threshold (default 50): " failure

    warning=${warning:-75}
    failure=${failure:-50}

    if [[ "$warning" =~ ^[0-9]+$ ]] &&
       [[ "$failure" =~ ^[0-9]+$ ]] &&
       [ "$warning" -le 100 ] &&
       [ "$failure" -le 100 ]
    then
        sed -i 's/"warning": [0-9]*/"warning": '"$warning"'/' "$project_dir/Helpers/config.json"
        sed -i 's/"failure": [0-9]*/"failure": '"$failure"'/' "$project_dir/Helpers/config.json"

        echo "Alert thresholds updated successfully."
    else
        echo "Error: thresholds must be whole numbers between 0 and 100."
        exit 1
    fi
else
    echo "Keeping the default alert thresholds."
fi
