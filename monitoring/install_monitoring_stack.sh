#!/bin/bash

# Define versions
PROMETHEUS_VERSION="2.47.0"
GRAFANA_VERSION="10.1.3"
NODE_EXPORTER_VERSION="1.6.1"

# Install Prometheus
echo "Installing Prometheus..."
PROMETHEUS_TAR="prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
PROMETHEUS_DIR="prometheus-${PROMETHEUS_VERSION}.linux-amd64"

if ! command -v prometheus >/dev/null 2>&1; then
    wget "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/${PROMETHEUS_TAR}"
    tar xvf "${PROMETHEUS_TAR}"
    sudo mv "${PROMETHEUS_DIR}" /usr/local/bin/prometheus
    sudo useradd --no-create-home --shell /sbin/nologin prometheus || true
    sudo mkdir -p /etc/prometheus /var/lib/prometheus
    sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus
    sudo cp "${PROMETHEUS_DIR}/prometheus.yml" /etc/prometheus/
    sudo cp "${PROMETHEUS_DIR}/prometheus" /usr/local/bin/
    sudo cp "${PROMETHEUS_DIR}/promtool" /usr/local/bin/
    sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl start prometheus
    sudo systemctl enable prometheus
else
    echo "Prometheus is already installed."
fi

# Install Grafana
echo "Installing Grafana..."
if ! command -v grafana-server >/dev/null 2>&1; then
    # Add the GPG key and repository for Grafana
    sudo curl https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
    sudo apt-get update

    # Install Grafana
    sudo apt-get install -y grafana

    # Start Grafana service
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server
else
    echo "Grafana is already installed."
fi

# Install Node Exporter
echo "Installing Node Exporter..."
NODE_EXPORTER_TAR="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
NODE_EXPORTER_DIR="node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64"

if ! command -v node_exporter >/dev/null 2>&1; then
    wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${NODE_EXPORTER_TAR}"
    tar xvf "${NODE_EXPORTER_TAR}"
    sudo mv "${NODE_EXPORTER_DIR}" /usr/local/bin/node_exporter
    sudo useradd --no-create-home --shell /sbin/nologin node_exporter || true
    sudo mkdir -p /var/lib/node_exporter
    sudo chown node_exporter:node_exporter /var/lib/node_exporter
    sudo cp "${NODE_EXPORTER_DIR}/node_exporter" /usr/local/bin/
    sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl start node_exporter
    sudo systemctl enable node_exporter
else
    echo "Node Exporter is already installed."
fi

# Configure Prometheus to scrape Node Exporter
echo "Configuring Prometheus to scrape Node Exporter..."
PROMETHEUS_CONFIG_FILE="/etc/prometheus/prometheus.yml"
if grep -q "node_exporter" "${PROMETHEUS_CONFIG_FILE}"; then
    echo "Prometheus is already configured to scrape Node Exporter."
else
    sudo sed -i '/scrape_configs:/a \  - job_name: \'node_exporter\'\n    static_configs:\n    - targets: [\'localhost:9100\']' "${PROMETHEUS_CONFIG_FILE}"
    sudo systemctl restart prometheus
fi

echo "Installation complete."
echo "To load default Grafana dashboards, follow these steps:"
echo "1. Open Grafana at http://<your_server_ip>:3000 (default login is admin/admin)"
echo "2. Add Prometheus as a data source: http://localhost:9090"
echo "3. Import Grafana dashboards (e.g., Node Exporter Full ID: 1860)."

