#!/bin/bash

# Install IBM Cloud CLI if not installed
if ! command -v ibmcloud &> /dev/null; then
    curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
fi

# Log in to IBM Cloud
ibmcloud login --sso -a cloud.ibm.com -r us-east -g Default

# Install kubectl if not installed
if ! command -v kubectl &> /dev/null; then
    kubectl_version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$kubectl_version/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi

# Install NGINX if not installed
if ! command -v nginx &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y nginx
fi

# Configure kubectl for the IBM Kubernetes Service cluster
ibmcloud ks cluster config --cluster cjeglh7w0k8p827c2dl0
kubectl get nodes

# Install Kubernetes Service plugin if not installed
if ! ibmcloud plugin list | grep -q ks; then
    ibmcloud plugin install ks
fi

# Install Container Registry plugin if not installed
if ! ibmcloud plugin list | grep -q container-registry; then
    ibmcloud plugin install container-registry
fi

# Configure kubectl again after plugin installation
ibmcloud ks cluster config --cluster cjeglh7w0k8p827c2dl0

# Display the current kubectl context
current_context=$(kubectl config current-context)
echo "Current kubectl context: $current_context"

# Check if configured to localhost
if [[ $current_context == "rancher.csde-us-east-1-bx2.4x16/cjeglh7w0k8p827c2dl0" ]]; then
    echo "Configured to rancher.csde-us-east-1-bx2.4x16/cjeglh7w0k8p827c2dl0. Deploying Rancher container..."

    # Deploy Rancher container using kubectl or any other method you prefer
    kubectl apply -f rancher-deployment.yaml
    # Make sure you have the appropriate YAML configuration for the Rancher deployment.

    # Expose the Rancher service using Ingress or LoadBalancer
    kubectl apply -f rancher-ingress.yaml  # Modify this line as needed

    # Configure NGINX as a reverse proxy for Rancher
    sudo tee /etc/nginx/sites-available/rancher-proxy.conf <<EOF
server {
    listen 80;
    server_name rancher.csde.caci.com;

    location / {
        proxy_pass http://rancher-service;  # Use the actual service name
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    sudo ln -s /etc/nginx/sites-available/rancher-proxy.conf /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl reload nginx
    
    # Run kubectl proxy to access Rancher UI
    kubectl proxy
else
    echo "Not configured to localhost. Skipping Rancher deployment."
fi
