minikube start

kubectl apply \
    --filename kustomized.yaml \
    --filename testenv.deployment.yaml \
    --filename testenv.secret.yaml \
    --filename testenv.service.yaml

minikube service testenv
