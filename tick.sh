#!/bin/bash
Q_PATH=q
SYM=sym

# --- Port Configuration ---
TP_PORT=5010
RDB_PORT=5011
DASH_PORT=10001

# Native RTE Ports (Pure q) - Offset +10
NAT_BASE_PORT=5019
NAT_WIDE_PORT=5020
NAT_DEEP_PORT=5021
NAT_INPT_PORT=5022

# PyKX RTE Ports (Python/ONNX)
PY_BASE_PORT=5029
PY_WIDE_PORT=5030
PY_DEEP_PORT=5031
PY_INPT_PORT=5032

echo "Starting KDB+ architecture..."

# --- 1. Base Infrastructure ---

# Tickerplant
$Q_PATH tick.q $SYM . -p $TP_PORT > /dev/null 2>&1 &
echo " -> Tickerplant started on $TP_PORT"

# # RDB
# $Q_PATH tick/r.q :$TP_PORT -p $RDB_PORT > /dev/null 2>&1 &
# echo " -> RDB started on $RDB_PORT"

# --- 2. Inference Engines (RTEs) ---

echo "Starting RTE pairs (PyKX vs Native)..."

# # CASE 0: BASELINE (Default)
# $Q_PATH rte_pykx_ff.q :$TP_PORT -p $PY_BASE_PORT -top 10 6 1 -label baseline > /dev/null 2>&1 &
# $Q_PATH rte_ff.q      :$TP_PORT -p $NAT_BASE_PORT -top 10 6 1 -label baseline > /dev/null 2>&1 &

# CASE 1: WIDE (Compute-intensive)
$Q_PATH tick/rte_pykx_ff.q :$TP_PORT -p $PY_WIDE_PORT -top 200 1024 512 1 -label wide > /dev/null 2>&1 &
$Q_PATH tick/rte_ff.q      :$TP_PORT -p $NAT_WIDE_PORT -top 200 1024 512 1 -label wide > /dev/null 2>&1 &

# CASE 2: DEEP (Overhead-intensive)
$Q_PATH tick/rte_pykx_ff.q :$TP_PORT -p $PY_DEEP_PORT -top 10 16 16 16 16 16 16 16 16 1 -label deep > /dev/null 2>&1 &
$Q_PATH tick/rte_ff.q      :$TP_PORT -p $NAT_DEEP_PORT -top 10 16 16 16 16 16 16 16 16 1 -label deep > /dev/null 2>&1 &

# CASE 3: INPUT (I/O-intensive)
$Q_PATH tick/rte_pykx_ff.q :$TP_PORT -p $PY_INPT_PORT -top 2000 16 8 1 -label input > /dev/null 2>&1 &
$Q_PATH tick/rte_ff.q      :$TP_PORT -p $NAT_INPT_PORT -top 2000 16 8 1 -label input > /dev/null 2>&1 &

# --- 3. Final Components ---

# Feed Handler
$Q_PATH fh.q :$TP_PORT > /dev/null 2>&1 &
echo " -> Feed Handler connected"

# Dashboard (Run from its directory to load dependencies)
(cd ../q/dash && $Q_PATH dash.q -p $DASH_PORT -u 1 > /dev/null 2>&1 &)
echo " -> Dashboard started on $DASH_PORT"

# --- Summary ---
echo ""
echo "====================================================="
echo " SYSTEM RUNNING (Background)"
echo "====================================================="
echo "INFRASTRUCTURE:"
echo "  TP: $TP_PORT | RDB: $RDB_PORT | DASH: $DASH_PORT"
echo ""
echo "LATENCY TESTS (PyKX vs Native):"
echo "  TYPE       | PYKX PORT | NATIVE PORT | TOPOLOGY"
echo "  -----------|-----------|-------------|----------------"
echo "  BASELINE   | $PY_BASE_PORT      | $NAT_BASE_PORT        | (Default)"
echo "  WIDE       | $PY_WIDE_PORT      | $NAT_WIDE_PORT        | (200; 1024 512; 1)"
echo "  DEEP       | $PY_DEEP_PORT      | $NAT_DEEP_PORT        | (10; 8x16; 1)"
echo "  INPUT      | $PY_INPT_PORT      | $NAT_INPT_PORT        | (2000; 16 8; 1)"
echo "====================================================="