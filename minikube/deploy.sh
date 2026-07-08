set -e
source .env

kubectl apply -f namespace.yaml
if ! kubectl get secret firebase-admin >/dev/null 2>&1; then
kubectl create secret generic firebase-admin --from-file=firebase-admin.json=secrets/firebase-admin.json
fi

kubectl apply -f secrets/backend-secret.yaml

kubectl apply -f configs/api-config.yaml
kubectl apply -f configs/ws-config.yaml
kubectl apply -f configs/gateway-config.yaml
kubectl apply -f configs/mongo-config.yaml
kubectl apply -f configs/vue-config.yaml

kubectl apply -f deployments/mongo-deployment.yaml
kubectl apply -f deployments/api-deployment.yaml
kubectl apply -f deployments/ws-deployment.yaml
kubectl apply -f deployments/gateway-deployment.yaml
kubectl apply -f deployments/vue-deployment.yaml