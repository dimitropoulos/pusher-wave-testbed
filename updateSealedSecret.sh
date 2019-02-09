
getTime() {
    echo $(date '+%s%N' | cut -b1-13)
}

name=$1
kubeconfig=$2
cert=$3

secretName=$name-secret

url=$(minikube service $name --url)

nextValue=$(getTime)

prior=$(curl --silent $url)

if [ "$prior" = "" ]; then
    echo the $name service is not responding at $url.  try waiting a minute and try again
    exit
fi

echo pinging $url
echo updating from $prior to $nextValue

kubectl --kubeconfig "$kubeconfig" create secret generic $secretName --from-literal=value="$nextValue" --dry-run --output yaml >"$name"/unsealed-secret.yaml

unsealedSecret="$name"/unsealed-secret.yaml
sealedSecret="$name"/"$name"-sealedsecret.yaml
kubeseal --kubeconfig "$kubeconfig" --format yaml --cert="$cert" <"$unsealedSecret" >"$sealedSecret"
rm "$unsealedSecret"

kubectl --kubeconfig "$kubeconfig" apply --filename "$sealedSecret"
rm "$sealedSecret" # comment this line if you want to view the sealed secret

for i in $(seq 1 60); do
    currentValue=$(curl --silent $url)

    if [ "$currentValue" = "$nextValue" ]; then
        echo secret successfully updated
        exit
    fi

    echo waiting... "$i"
    sleep 1
done

echo sorry, charlie.. didn\'t work..