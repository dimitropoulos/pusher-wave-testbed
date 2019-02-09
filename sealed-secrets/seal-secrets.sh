#!/bin/bash

directory=$1
kubeconfig=$2
cert=$3

find "$directory" -name "*-secret.yaml" | while read -r secret; do
    sealedsecret=${secret%-secret.yaml}-sealedsecret.yaml
    echo sealing the "$secret" secret as "$sealedsecret"
    kubeseal --kubeconfig "$kubeconfig" --format yaml --cert="$cert" <"$secret" >"$sealedsecret"

    echo applying kubernetes resource for "$sealedsecret"
    kubectl --kubeconfig "$kubeconfig" apply --filename "$sealedsecret"

    sed --in-place '1s/^/---\n/' "$sealedsecret" # adds `---` at beginning of the sealedsecret to allow for streaming

    sed --in-place '$ d' "$sealedsecret" # for some reason there are two empty lines (where just one is desired) at the end of the sealedsecret as of v0.7.0

    # echo deleting un-sealed secret "$secret"
    # rm "$secret"
done
