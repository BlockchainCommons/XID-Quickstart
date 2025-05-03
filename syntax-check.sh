#!/bin/bash
# syntax-check.sh - Script to check for syntax issues in tutorial code blocks

# Text formatting
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

# Counter variables
ERRORS_FOUND=0

# Directory containing tutorials
TUTORIALS_DIR="./tutorials"

echo "XID Tutorial Syntax Checker"
echo "================================="

# Check all markdown files in tutorials directory
for tutorial in "$TUTORIALS_DIR"/*.md; do
  # Skip README
  if [[ "$(basename "$tutorial")" == "README.md" ]]; then
    continue
  fi
  
  echo -e "\nChecking $(basename "$tutorial")..."
  
  # Extract all code blocks within sh fences
  TMP_FILE=$(mktemp)
  awk '/^```sh/,/^```/ { if (!/^```/) print }' "$tutorial" > "$TMP_FILE"
  
  # Check for missing $ in variable references
  MISSING_DOLLARS=$(grep -n "[A-Za-z_][A-Za-z0-9_]*\$(" "$TMP_FILE" 2>/dev/null || true)
  if [ -n "$MISSING_DOLLARS" ]; then
    echo -e "${RED}Found missing \$ in variable references:${RESET}"
    echo "$MISSING_DOLLARS"
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
  fi
  
  # Check for basic bash syntax
  if ! bash -n "$TMP_FILE" 2>/dev/null; then
    echo -e "${RED}Found bash syntax errors:${RESET}"
    bash -n "$TMP_FILE" 2>&1 | head -5
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
  else
    echo -e "${GREEN}✓ No syntax errors found${RESET}"
  fi
  
  # Clean up
  rm "$TMP_FILE"
done

# Print summary
echo -e "\n================================="
if [ $ERRORS_FOUND -eq 0 ]; then
  echo -e "${GREEN}✓ All tutorials passed syntax check${RESET}"
  exit 0
else
  echo -e "${RED}× Found $ERRORS_FOUND syntax issues${RESET}"
  exit 1
fi