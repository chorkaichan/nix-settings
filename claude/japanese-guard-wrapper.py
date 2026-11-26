#!/usr/bin/env python3
"""Wrapper around claude-code-japanese-guard.

When the user's prompt in the current turn asks for English (a translation or
English text), skip the guard so the English reply reaches the user as-is,
rendered as Markdown. Otherwise pass the hook input through to the guard.

Usage: japanese-guard-wrapper.py <path to japanese-guard.py>  (hook input on stdin)
"""

import json
import re
import subprocess
import sys

# Words that mean "I want English" in the user's prompt
WANTS_ENGLISH = re.compile(r"英訳|英語で|英語に|英文|in English|translate", re.I)


def is_user_turn(entry):
    """A prompt the user typed (not a tool result or a meta entry)"""
    if entry.get("type") != "user" or entry.get("isMeta"):
        return False
    content = entry.get("message", {}).get("content")
    if isinstance(content, str):
        return True
    if isinstance(content, list):
        return not any(isinstance(c, dict) and c.get("type") == "tool_result" for c in content)
    return False


def prompt_text(entry):
    content = entry.get("message", {}).get("content")
    if isinstance(content, str):
        return content
    return "\n".join(
        c.get("text", "") for c in content or [] if isinstance(c, dict) and c.get("type") == "text"
    )


def last_prompt(transcript_path):
    last = ""
    with open(transcript_path, encoding="utf-8", errors="ignore") as f:
        for line in f:
            try:
                entry = json.loads(line)
            except ValueError:
                continue
            if is_user_turn(entry):
                last = prompt_text(entry)
    return last


def main():
    raw = sys.stdin.read()
    try:
        data = json.loads(raw or "{}")
        path = data.get("transcript_path")
        if path and WANTS_ENGLISH.search(last_prompt(path)):
            return 0
    except (ValueError, OSError):
        pass  # if the prompt cannot be read, let the guard decide
    result = subprocess.run([sys.executable, sys.argv[1]], input=raw, text=True, capture_output=True)
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
