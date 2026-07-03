#!/bin/bash

# Ensure the 'prod' session exists
if ! tmux has-session -t scanning 2>/dev/null; then
  # Create a new session named 'prod', detached
  cd /workspaces/scanning
  tmux new-session -d -s scanning
fi
