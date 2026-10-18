#!/bin/sh
# Add the BuildKit secret mounts to the RUN instruction that carries the
# "cherry-needs-secrets" token (see modules/53-nvidia-module-signing.yml).
# Vib has no way to express secret mounts, so the generated Containerfile is patched.
#
# The certificate fingerprint is appended to the token. BuildKit does not hash secret
# contents into its cache key, so a new certificate has to change the instruction text.
#
# Usage: scripts/inject-build-secrets.sh CONTAINERFILE CERT_FINGERPRINT
set -eu
containerfile="$1"
fingerprint="$2"
output="$containerfile.patched"
trap 'rm -f "$output"' EXIT

awk -v fingerprint="$fingerprint" '
BEGIN {
    token = "cherry-needs-secrets"
    mounts = "--mount=type=secret,id=mok_key,target=/run/secrets/mok_key " \
             "--mount=type=secret,id=mok_cert,target=/run/secrets/mok_cert"
}

function flush(   i, text) {
    if (count == 0) return
    text = ""
    for (i = 1; i <= count; i++) text = text lines[i] "\n"
    if (index(text, token) > 0) {
        if (lines[1] !~ /^RUN /) {
            print "token found in an instruction that is not RUN: " lines[1] > "/dev/stderr"
            failed = 1
        }
        sub(/^RUN /, "RUN " mounts " ", lines[1])
        for (i = 1; i <= count; i++) gsub(token, token ":" fingerprint, lines[i])
        patched++
    }
    for (i = 1; i <= count; i++) print lines[i]
    count = 0
}

{
    lines[++count] = $0
    if ($0 !~ /\\[ \t]*$/) flush()
}

END {
    flush()
    if (failed) exit 1
    if (patched != 1) {
        print "expected the token in exactly one RUN instruction, found " patched + 0 > "/dev/stderr"
        exit 1
    }
}
' "$containerfile" > "$output"

mv "$output" "$containerfile"
echo "Added secret mounts to the NVIDIA signing step"
