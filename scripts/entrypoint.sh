# Begin run services
node_exporter \
--collector.disable-defaults \
--collector.filesystem \
--collector.cpu \
--collector.cpufreq \
--collector.diskstats \
--collector.meminfo \
--collector.netdev \
--collector.netclass &

/app/lug -c /configs/config.yaml
