#!/bin/bash
# Build-time only. Rebuilds the NVIDIA DKMS modules with the image signing key
# and publishes the matching public certificate for users to enroll.
#
# The private key arrives as a BuildKit secret and never touches an image layer.
# Without both secrets (pull requests from forks) the modules stay unsigned.
set -euo pipefail

key=/run/secrets/mok_key
cert_pem=/run/secrets/mok_cert
cert_der=/usr/share/cherryscripts/mok.der
dkms_dropin=/etc/dkms/framework.conf.d/90-cherry-signing.conf

if [ ! -s "$key" ] || [ ! -s "$cert_pem" ]; then
    echo "WARNING: no signing secrets mounted, NVIDIA modules stay unsigned" >&2
    exit 0
fi

cleanup() {
    rm -f "$dkms_dropin"
}
trap cleanup EXIT

openssl x509 -in "$cert_pem" -outform DER -out "$cert_der"
expected_signer=$(openssl x509 -inform DER -in "$cert_der" -noout -subject -nameopt multiline \
    | sed -n 's/^ *commonName *= *//p')
if [ -z "$expected_signer" ]; then
    echo "ERROR: signing certificate has no common name" >&2
    exit 1
fi

mkdir -p "$(dirname "$dkms_dropin")"
cat > "$dkms_dropin" <<CONF
mok_signing_key=$key
mok_certificate=$cert_der
CONF

rebuilt=0
while read -r line; do
    if [[ $line =~ ^(nvidia[^/\ ,]*)/([^,]+),\ ([^,]+),\ ([^:]+):\ installed ]]; then
        module=${BASH_REMATCH[1]}
        version=${BASH_REMATCH[2]}
        kernel=${BASH_REMATCH[3]}
        arch=${BASH_REMATCH[4]}
        echo "Signing $module/$version for kernel $kernel ($arch)"
        dkms build --force -m "$module" -v "$version" -k "$kernel" -a "$arch" < /dev/null
        dkms install --force -m "$module" -v "$version" -k "$kernel" -a "$arch" < /dev/null
        rebuilt=$((rebuilt + 1))
    fi
done < <(dkms status)

if [ "$rebuilt" -eq 0 ]; then
    echo "ERROR: no installed NVIDIA DKMS module found, check that kernel headers are present" >&2
    dkms status >&2
    exit 1
fi

checked=0
while read -r module_file; do
    signer=$(modinfo -F signer "$module_file" < /dev/null)
    if [ "$signer" != "$expected_signer" ]; then
        echo "ERROR: $module_file is signed by '${signer:-nobody}', expected '$expected_signer'" >&2
        exit 1
    fi
    checked=$((checked + 1))
done < <(find /lib/modules -name 'nvidia*.ko*')

if [ "$checked" -eq 0 ]; then
    echo "ERROR: no NVIDIA kernel module found after rebuild" >&2
    exit 1
fi

# DKMS may create its own throwaway key on install. It is not the image key and must not ship.
rm -f /var/lib/dkms/mok.key /var/lib/dkms/mok.pub

echo "Signed $checked NVIDIA modules as '$expected_signer'"
openssl x509 -inform DER -in "$cert_der" -noout -fingerprint -sha256
