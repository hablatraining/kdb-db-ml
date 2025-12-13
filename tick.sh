#!/bin/bash

Q_PATH=q
SYM=sym

TP_PORT=5010
RDB_PORT=5011
RTE_PORT=5013
DASH_PORT=10001

SESSION_NAME="kdb_tick_system"
DASH_DIR="q/dash"

# Limpieza previa
tmux has-session -t $SESSION_NAME 2>/dev/null && tmux kill-session -t $SESSION_NAME

echo "Creando sesión TMUX grande..."

# --- 1. Crear sesión forzando un tamaño grande (200 columnas x 50 filas) ---
# Esto evita el error "no space for new pane"
tmux new-session -d -s $SESSION_NAME -x 200 -y 50 -n KDB_System "$Q_PATH tick.q $SYM . -p $TP_PORT"

# --- 2. Lanzar los procesos Tick (Estrategia simplificada) ---
# En lugar de porcentajes complicados, dividimos y usamos 'tiled' al final.

# Dividir para RDB
tmux split-window -t $SESSION_NAME:0 "$Q_PATH tick/r.q :$TP_PORT -p $RDB_PORT"

# Dividir para RTE
tmux split-window -t $SESSION_NAME:0 "$Q_PATH rte.q :$TP_PORT -p $RTE_PORT"

# Dividir para FH
tmux split-window -t $SESSION_NAME:0 "$Q_PATH fh.q :$TP_PORT"

# FORZAR DISEÑO MOSAICO (TILED)
# Esto reajusta automáticamente todos los paneles para que quepan bien
tmux select-layout -t $SESSION_NAME:0 tiled


# --- 3. Dashboard (En una ventana nueva) ---

DASH_COMMAND="cd $DASH_DIR && $Q_PATH dash.q -p $DASH_PORT -u 1"
tmux new-window -t $SESSION_NAME:1 -n Dashboard "$DASH_COMMAND"


# --- Finalización ---
tmux select-window -t $SESSION_NAME:0
echo "Sistema kdb+ lanzado exitosamente."
echo "-----------------------------------"
echo "TP  : $TP_PORT"
echo "RDB : $RDB_PORT"
echo "RTE : $RTE_PORT"
echo "DASH: $DASH_PORT (http://localhost:$DASH_PORT)"
echo "-----------------------------------"
echo "Ejecuta: tmux attach -t $SESSION_NAME"