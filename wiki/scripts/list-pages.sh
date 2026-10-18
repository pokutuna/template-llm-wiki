#!/bin/sh
set -eu

dir=wiki/
words=

for arg in "$@"; do
  case "$arg" in
    DIR=*) dir=${arg#DIR=} ;;
    WORDS=*) words=${arg#WORDS=} ;;
    -h|--help)
      echo "usage: $0 [DIR=<dir>] [WORDS=<regex>]"
      exit 0
      ;;
    *)
      echo "unknown argument: $arg" >&2
      echo "usage: $0 [DIR=<dir>] [WORDS=<regex>]" >&2
      exit 2
      ;;
  esac
done

rg --files "$dir" -g '*.md' -g '!index.md' -g '!template.md' | sort | while IFS= read -r file; do
  awk -v file="$file" -v words="$words" '
    FNR == 1 { in_frontmatter = ($0 == "---"); next }
    in_frontmatter && $0 == "---" {
      n = split(description, sentences, "。")
      summary = (n > 1 ? sentences[1] "。" : description)
      haystack = tolower(file " " title " " description)
      # deprecated のページと idea の進捗を末尾に示す
      mark = (status != "" ? " [" status "]" : "") (progress != "" ? " [" progress "]" : "")
      if (words == "" || haystack ~ tolower(words))
        print file " | " title " | " summary mark
      exit
    }
    in_frontmatter && /^title:/ {
      title = $0
      sub(/^title:[[:space:]]*/, "", title)
    }
    in_frontmatter && /^description:/ {
      description = $0
      sub(/^description:[[:space:]]*/, "", description)
    }
    in_frontmatter && /^status:/ {
      status = $0
      sub(/^status:[[:space:]]*/, "", status)
      sub(/[[:space:]]+#.*$/, "", status)
    }
    in_frontmatter && /^progress:/ {
      progress = $0
      sub(/^progress:[[:space:]]*/, "", progress)
      sub(/[[:space:]]+#.*$/, "", progress)
    }
  ' "$file"
done
