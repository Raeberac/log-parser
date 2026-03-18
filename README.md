PowerShell Log Parser Engine:
A lightweight, persistent PowerShell utility designed for rapid log analysis and keyword filtering. This tool is built for IT administrators and Help Desk technicians who need to extract critical events (Errors, Failures, Warnings) from large log files while maintaining a clean, stylized terminal environment.

Features:
Persistent Configuration: Saves custom keywords to parser_config.json, ensuring your settings persist across sessions.

Recursive Keyword Matching: Built-in logic matches partial strings (e.g., "fail" captures "failure," "failed," and "failing").

Automated Export: Automatically generates a new log file prefixed with parsed- containing only the relevant entries.

Case-Insensitive Scanning: Automatically ignores letter casing to ensure no critical errors are missed.
