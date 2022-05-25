# Custom Github Webhook

## Usage Instructions 

A service that retrieves all issues from a given repository on github and returns a JSON asynchronously (1 day apart) via webhook with issues and contributors that existed in the project at the time of the call.

Entries:
  - User Name
  - Repository Name

Usage: `Webhook.create_repository_webhook(user_name, repository_name, target_url, time)`

`time` defines how long (in milliseconds) to send the webhook (Useful for testing functionality in short times)
