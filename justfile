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
