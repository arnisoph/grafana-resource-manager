FROM debian
RUN \
  apt-get update -qq && \
  apt-get install curl -y && \
  curl -fsSL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/bin/jq && \
  chmod +x /usr/bin/jq && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY grafana-resource-manager.sh /usr/bin/grafana-resource-manager
RUN \
  chmod +x /usr/bin/grafana-resource-manager
