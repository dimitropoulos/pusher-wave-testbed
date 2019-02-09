minikube start

kubectl apply \
    --filename wave \
    --filename sealed-secrets \
    --filename testenv

minikube service testenv

sleep 120 # it takes a bit for everything to come up

sh sealed-secret-fetch-public-key.sh ~/.kube/config

sh updateSealedSecret.sh testenv ~/.kube/config sealed-secrets/sealed-secrets-public-key.pem

rm sealed-secrets/sealed-secrets-public-key.pem