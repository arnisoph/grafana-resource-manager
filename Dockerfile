FROM debian
COPY grafana-resource-manager.sh /usr/bin/grafana-resource-manager
RUN \
  apt update -qq && \
  apt install jq curl -y && \
  chmod +x /usr/bin/grafana-resource-manager && \
  apt clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENTRYPOINT ["/usr/bin/grafana-resource-manager"]
