node_exporter --collector.disable-defaults --collector.filesystem --collector.cpu --collector.cpufreq --collector.diskstats --collector.meminfo --collector.netdev --collector.netclass &
vindex -d /mirrors -l 0.0.0.0 &
/app/lug -c /configs/config.yaml
