# Student Attendance Tracker — Deployment Agent

## Overview

`deploy_agent.sh` automates deployment, execution, and log archiving for the Student Attendance Tracker application.

## Requirements

- Bash
- Python 3
- `zip` and `unzip`
- The three source files in `templates/`

## Run the script

From the repository directory:

```bash
chmod +x deploy_agent.sh
./deploy_agent.sh
```

Choose one of the menu options:

1. Deploy the application.
2. Run an existing deployed application.
3. Archive attendance and absence logs.
4. Exit.

## Deployment

Choose option 1 and enter a project name containing only letters, numbers, underscores, or hyphens.

The script creates an `attendance_tracker_<name>/` directory containing the application, helper configuration, and reports directory.

The roster can be created by copying sample students from `templates/assets.csv` or generating a fresh roster.

The deployed Python application is made executable. The configuration file is restricted to owner read/write permissions (`600`).

### Alert thresholds

During deployment, choose whether to update the alert thresholds.

- Warning threshold: default `75`
- Failure threshold: default `50`

Values must be whole numbers between 0 and 100. The deployed `Helpers/config.json` file is updated without reformatting its contents.

### Roster and session consistency

The copied sample roster retains its existing session history. A fresh roster starts with one session. The configuration's `total_sessions` value must agree with the roster.

## Run the application

Choose option 2 and enter the name used during deployment.

The script runs the deployed `attendance_checker.py` application interactively. Attendance results are written to the reports directory.

## Archive logs

Choose option 3 and enter the deployed project name.

Existing `reports/attendance.log` and `reports/absent.log` files are copied into separate timestamped archive directories:

- `archives/attendance/`
- `archives/absent/`

Files use timestamped names so previous archives are retained. Missing logs are reported without causing the archive operation to fail.

## Interruption handling

During deployment, the shell script handles Ctrl+C (`SIGINT`) and Ctrl+Z (`SIGTSTP`).

When interrupted, the script attempts to create a ZIP archive named `attendance_tracker_<name>_archive.zip` containing the incomplete project. It removes the incomplete project directory only after the archive is successfully created. If archiving fails, the directory is preserved.

The signal handler applies to the shell deployment process, not to an application already running interactively.

## Validation and testing

Run the following checks:

```bash
bash -n deploy_agent.sh
git diff --check
```

Test the deployment, application execution, log archiving, threshold validation, and interruption handling in a disposable project directory.

For interruption testing, confirm that the ZIP archive contains the incomplete project and that the directory is removed only after successful archiving.

## Source files

The original application and configuration templates are stored in `templates/`:

- `assets.csv`
- `attendance_checker.py`
- `config.json`

