echo "======================================="
echo "Creating Local Cluster"
echo "======================================="

kind create cluster --name k8s-ingress-kafka

kubectl create namespace kafka

kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

