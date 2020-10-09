dnf -y install numactl numatop tuna
systemctl enable tuned
systemctl start tuned
tuned-adm profile throughput-performance
