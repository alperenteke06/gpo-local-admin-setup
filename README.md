# GPO Local Admin Setup

Automated GPO startup script for creating a local administrator account with centralized logging.

## Overview

This repository provides a batch script that can be deployed via Group Policy Object (GPO) as a startup script.  
The script silently creates a local administrator account, adds it to the Administrators group, ensures the password never expires, and logs every action to a central file server.

## Features

- Creates a local user with specified username and password.
- Sets the Full Name and Description for the user.
- Adds the local user and optionally a domain user to the Administrators group.
- Ensures the local user's password never expires.
- Centralized logging on a specified file server in UTF-8 format.
- Silent execution — no pop-ups or command windows for end-users.

## Requirements

- Windows 10/11 or Windows Server 2016 and above.
- The executing machine must have permission to write to the file server path for logging.
- GPO must be configured to run the script at computer startup.
- Script must be deployed with administrative privileges (GPO Startup Script runs as SYSTEM by default).

## How to Use

1. **Edit the Script:**
   - Set the `localUsername`, `localPassword`, and `domainUsername` variables as needed.
   - Update the `logpath` variable to point to your central file server.

2. **Prepare the GPO:**
   - Open `Group Policy Management`.
   - Create a new GPO or edit an existing one.
   - Navigate to:  
     `Computer Configuration > Policies > Windows Settings > Scripts (Startup/Shutdown) > Startup`
   - Add the batch script.

3. **Distribute:**
   - Link the GPO to the appropriate Organizational Units (OUs).

4. **Check Logs:**
   - Logs will be generated at the configured file server path:
     ```
     \\YourFileServer\SharedLogs\HOSTNAME_TIMESTAMP_log.txt
     ```

## Example Log Output

| Timestamp         | Status | Message                                                               |
|-------------------|--------|-----------------------------------------------------------------------|
| 04/28/2025 10:30  | OK     | Local user created successfully: support.admin                        |
| 04/28/2025 10:30  | OK     | Full Name set successfully for user: support.admin                    |
| 04/28/2025 10:30  | OK     | Description set successfully for user: support.admin                  |
| 04/28/2025 10:30  | OK     | Local user added to Administrators group: support.admin               |
| 04/28/2025 10:30  | OK     | Domain user added to Administrators group: YOURDOMAIN\support.admin   |
| 04/28/2025 10:30  | OK     | Password never expire option set successfully for user: support.admin |
| 04/28/2025 10:31  | END    | Script completed successfully                                         |

## Notes

- If the user or group membership already exists, the script logs it without errors.
- Ensure that file server paths are reachable during startup (offline systems will fail to log).
- Consider additional security measures like randomizing passwords or managing accounts through LAPS for better security compliance.