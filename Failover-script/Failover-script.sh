#!/bin/bash

# ======================================================
# MANUAL FAILOVER SCRIPT
# ------------------------------------------------------
# This script must ONLY be executed manually
# when the current MySQL master is confirmed to be
# unreachable.
#
# Reason:
# To prevent split-brain scenarios and potential
# data inconsistency.
#
# Preconditions:
# - Master is NOT reachable
# - Slave replication is fully in sync
# - Failover decision has been verified by operator
#
# DO NOT run this script automatically.
################ We couldn't test it ###################
# ======================================================

set -e

NAMESPACE="prod"
SLAVE_POD="mysql-slave-0"
MASTER_POD="mysql-master-0"

echo "======================================"
echo "[INFO] Starting MySQL Failover"
echo "======================================"

# --------------------------------------
# Get MySQL Root Password from Secret
# --------------------------------------
MYSQL_PASS=$(kubectl get secret mysql-secret -n $NAMESPACE -o jsonpath="{.data.MYSQL_ROOT_PASSWORD}" | base64 -d)

# --------------------------------------
# 1. CHECK MASTER STATUS (Split-Brain Protection)
# --------------------------------------
echo "[INFO] Checking if master is still reachable..."

if kubectl get pod $MASTER_POD -n $NAMESPACE > /dev/null 2>&1; then
  if kubectl exec -n $NAMESPACE $MASTER_POD -- \
    mysqladmin ping -uroot -p$MYSQL_PASS > /dev/null 2>&1; then

    echo "[ERROR] Master is still reachable! Abort to prevent split-brain."
    exit 1
  fi
fi

echo "[OK] Master is NOT reachable"

# --------------------------------------
# 2. CHECK SLAVE STATUS
# --------------------------------------
echo "[INFO] Checking slave replication status..."

SLAVE_STATUS=$(kubectl exec -n $NAMESPACE $SLAVE_POD -- \
  mysql -uroot -p$MYSQL_PASS -e "SHOW SLAVE STATUS\G")

echo "$SLAVE_STATUS"

SECONDS_BEHIND=$(echo "$SLAVE_STATUS" | grep "Seconds_Behind_Master" | awk '{print $2}')
SQL_RUNNING=$(echo "$SLAVE_STATUS" | grep "Slave_SQL_Running" | awk '{print $2}')

# --------------------------------------
# 3. VALIDATE REPLICATION STATE
# --------------------------------------
if [ "$SQL_RUNNING" != "Yes" ]; then
  echo "[ERROR] Slave SQL thread is NOT running. Abort!"
  exit 1
fi

if [ "$SECONDS_BEHIND" != "0" ] && [ "$SECONDS_BEHIND" != "NULL" ]; then
  echo "[ERROR] Slave is behind master ($SECONDS_BEHIND sec). Abort to prevent data loss!"
  exit 1
fi

echo "[OK] Slave is fully synced"

# --------------------------------------
# 4. PROMOTE SLAVE → MASTER
# --------------------------------------
echo "[INFO] Promoting slave to master..."

kubectl exec -n $NAMESPACE $SLAVE_POD -- \
mysql -uroot -p$MYSQL_PASS -e "
STOP SLAVE;
RESET SLAVE ALL;
SET GLOBAL read_only = OFF;
"

echo "[SUCCESS] Slave promoted to MASTER"

# --------------------------------------
# 5. SWITCH TRAFFIC (LABEL-BASED ROUTING)
# --------------------------------------
echo "[INFO] Switching roles (master/slave labels)..."

kubectl label pod $SLAVE_POD -n $NAMESPACE role=master --overwrite
kubectl label pod $MASTER_POD -n $NAMESPACE role=slave --overwrite

echo "[OK] Labels updated"

# --------------------------------------
# 6. VERIFY SERVICE ROUTING
# --------------------------------------
echo "[INFO] Verifying service endpoints..."

kubectl get endpoints mysql -n $NAMESPACE

echo "[OK] Traffic should now go to new master"

# --------------------------------------
# 7. SCALE DOWN OLD MASTER (SAFE AFTER SWITCH)
# --------------------------------------
echo "[INFO] Scaling down old master..."

kubectl scale statefulset mysql-master -n $NAMESPACE --replicas=0

echo "[OK] Old master scaled down"

# --------------------------------------
# DONE
# --------------------------------------
echo "======================================"
echo "[SUCCESS] FAILOVER COMPLETE"
echo "======================================"
echo "Applications now use new master (mysql-slave)"
