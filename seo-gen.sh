#!/bin/bash

# --- SEO Meta Extractor by Adnan Hasan ---
# Simple tool to fetch meta data and clean Arabic hamzas

read -p "Enter URL: " url

# Fetch page content with User-Agent
content=$(curl -sL -A "Mozilla/5.0 (X11; Linux x86_64) Firefox/120.0" "$url")

# Function to clean HTML entities and remove hamzas
clean_all() {
    echo "$1" | sed "s/&#8212;/—/g; s/&#39;/'/g; s/&quot;/\"/g; s/&amp;/\&/g" | \
    sed 's/[أإآ]/ا/g; s/ؤ/و/g; s/ئ/ى/g'
}

# Extraction (Title, Description, and Cast)
title=$(echo "$content" | grep -oP '(?<=<title>).*?(?=</title>)' | head -1)
desc=$(echo "$content" | grep -oP '(?<=<meta property="og:description" content=").*?(?=")' | head -1)
[[ -z "$desc" ]] && desc=$(echo "$content" | grep -oP '(?<=<meta name="description" content=").*?(?=")' | head -1)

# Cast Extraction logic
cast=$(echo "$content" | grep -oP '(?<="name": ").*?(?=")' | grep -ivE "TMDB|Database|Movie|TV|Search" | head -5 | tr '\n' ',' | sed 's/,$//')
if [[ -z "$cast" ]]; then
    cast=$(echo "$content" | grep -oP '(?<=/person/)[0-9]+-.*?(?=")' | cut -d'-' -f2- | head -5 | tr '-' ' ' | tr '\n' ',' | sed 's/,$//')
fi

# Final Processing
final_title=$(clean_all "$title")
final_desc=$(clean_all "$desc")
final_cast=$(clean_all "$cast")

echo "------------------------------"
echo "Title: $final_title"
echo "Starring: $final_cast"
echo "Description: $final_desc"
echo "------------------------------"

# Save results locally
{
  echo "Title: $final_title"
  echo "Starring: $final_cast"
  echo "Description: $final_desc"
} > final_meta.txt

echo "Done! Data saved to final_meta.txt"
