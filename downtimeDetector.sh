
getTime() {
    echo $(date '+%s%N' | cut -b1-13)
}

serviceName=$1
secretName=$serviceName-secret

url=$(minikube service $serviceName --url)

nextValue=$(getTime)

prior=$(curl --silent $url)

if [ "$prior" = "" ]; then
    echo the $serviceName service is not responding at $url
    exit
fi

echo pinging $url
echo updating from $prior to $nextValue

kubectl create secret generic $secretName --from-literal=value="$nextValue" --dry-run --output yaml | kubectl apply --filename -

# not sure why, but if I don't wait a second, curl returns nothing a couple times _right_ after I start hitting the endpoint.  Perhaps due to hitting a rate limit?
sleep 2


start=$(getTime)
startOutage=0

for i in $(seq 1 200);
do
    currentValue=$(curl --silent $url)

    if [ "$prior" = "$currentValue" ]; then
        continue
    fi

    if [ "$currentValue" = "" ] && [ $startOutage = 0 ]; then
        startOutage=$(getTime)
        continue
    fi

    if [ "$currentValue" = "$nextValue" ]; then
        endOutage=$(getTime)
        if [ $startOutage = 0 ]; then
            echo no downtime observed
            exit
        fi

        outageDuration=$(expr $endOutage - $startOutage)
        echo outage obserbed starting at $startOutage and ending at $endOutage
        echo duration of outage: $outageDuration milliseconds
        exit
    fi
done