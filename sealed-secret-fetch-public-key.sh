kubeconfig=$1
kubeseal --kubeconfig "$kubeconfig" --fetch-cert --controller-namespace=kube-system --controller-name=sealed-secrets > ./sealed-secrets/sealed-secrets-public-key.pem