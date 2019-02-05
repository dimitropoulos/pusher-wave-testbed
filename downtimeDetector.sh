url=$1

if [ -z $url ]; then
    echo please supply a url
    exit
fi

value=$(date)

prior=$(curl --silent $url)

echo prior: $prior
echo updating to: $value
echo

kubectl create secret generic testenv-secret --from-literal=value="$value" --dry-run --output yaml | kubectl apply --filename -

# not sure why, but if I don't wait a second, curl returns nothing a couple times _right_ after I start hitting the endpoint
sleep 2

start=$(date '+%s%N' | cut -b1-13)
startOutage=0

for i in `seq 1 200`;
do
    result=$(curl --silent $url)

    if [ "$prior" = "$result" ]; then
        # change not yet realized
        continue
    fi

    if [ "$result" = "" ] && [ $startOutage = 0 ]; then
        startOutage=$(date '+%s%N' | cut -b1-13)
        continue
    fi

    if [ "$result" = "$value" ]; then
        endOutage=$(date '+%s%N' | cut -b1-13)
        echo outage started at $startOutage and ended at $endOutage. total milliseconds: $(expr $endOutage - $startOutage)
        exit
    fi
done