default:
    @just --list

build:
    cabal run website -- build

watch port="8080":
    cabal run website -- watch --port {{port}}

# just article "My Article"
article title lang="en":
    cabal run website -- new --kind post --title {{quote(title)}} --lang {{lang}} --tag haskell  --summary "SUMMARY" --toc 

# just note "My Note"
note title lang="en":
    cabal run website -- new --kind note --title {{quote(title)}} --lang {{lang}}

# just project "My Project"
project title lang="en":
    cabal run website -- new --kind project --title {{quote(title)}} --lang {{lang}}

deploy: build
    #!/usr/bin/env bash
    set -euo pipefail
    git worktree remove --force /tmp/gh-pages 2>/dev/null || rm -rf /tmp/gh-pages
    git worktree prune
    if git show-ref --quiet refs/heads/gh-pages; then
        git worktree add /tmp/gh-pages gh-pages
    else
        git worktree add --orphan -b gh-pages /tmp/gh-pages
    fi
    rsync -a --delete --exclude='.git' _site/ /tmp/gh-pages/
    git -C /tmp/gh-pages add -A
    git -C /tmp/gh-pages diff --cached --quiet && echo "Nothing to deploy." && exit 0
    git -C /tmp/gh-pages commit -m "deploy $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    git -C /tmp/gh-pages push origin gh-pages
