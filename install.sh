#!/bin/bash

EXPORTER_VERSION=$(curl -s https://api.github.com/repos/prometheus-community/postgres_exporter/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
read -rp "Enter the port number for the Postgres Exporter (default: 15432): " -e -i "15432" POSTGRES_EXPORTER_PORT

function install_postgres_exporter() {
    echo "Downloading Postgres Exporter v${EXPORTER_VERSION}..."
    curl -LO "https://github.com/prometheus-community/postgres_exporter/releases/download/v${EXPORTER_VERSION}/postgres_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz"
    tar -xzf postgres_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz
    sudo mv postgres_exporter-${EXPORTER_VERSION}.linux-amd64/postgres_exporter /usr/local/bin/

    echo "Cleaning up..."
    rm -rf postgres_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz postgres_exporter-${EXPORTER_VERSION}.linux-amd64
}

function create_postgres_exporter_user() {
    echo "Creating postgres_exporter user and directory..."
    sudo useradd --no-create-home --shell /bin/false postgres_exporter
    sudo mkdir -p /etc/postgres_exporter
    sudo cp postgres_exporter.env /etc/postgres_exporter/postgres_exporter.env
    sudo chown -R postgres_exporter:postgres_exporter /etc/postgres_exporter
}

function create_postgres_exporter_systemd_service() {
    echo "Creating postgres_exporter systemd service..."
    sudo tee /etc/systemd/system/postgres_exporter.service > /dev/null << EOF
[Unit]
Description=Prometheus Postgres Exporter
After=network.target

[Service]
User=postgres_exporter
Group=postgres_exporter
EnvironmentFile=/etc/postgres_exporter/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter --collector.stat_statements --web.listen-address=:$POSTGRES_EXPORTER_PORT

[Install]
WantedBy=multi-user.target
EOF
}

function enable_and_start_postgres_exporter_service() {
    echo "Enabling and starting postgres_exporter service..."
    sudo systemctl daemon-reload
    sudo systemctl enable postgres_exporter.service --now
}

function print_success_message() {
    echo "Postgres Exporter installed successfully!!!"
    echo "You can now access the metrics at http://localhost:$POSTGRES_EXPORTER_PORT/metrics"
}

install_postgres_exporter
create_postgres_exporter_user
create_postgres_exporter_systemd_service
enable_and_start_postgres_exporter_service
print_success_message
