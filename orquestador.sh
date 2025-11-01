#!/usr/bin/env bash

scandate=$(date +%Y%m%d_%H%M%S)

tmp_entries="services_$scandate.txt"

read -rp "Introduce la IP a escanear" target
echo "Escanenando IP: $target" 
#he probado a meter el script --script vuln,vulners pero no soy capaz de ordenar la información para que sea formato Puerto | Estado | Servicio | Versión | CVEs
nmap -sV -sS -Pn -T3 -oN "scan_$scandate" "$target"
echo "Escaneo finalizado. Resultado guardado en scan_$scandate"

: > "$tmp_entries"

grep -E "^[0-9]+/tcp" "scan_$scandate" | while IFS= read -r line; do
    protoport=$(echo "$line" | awk '{print $1}')
    port=$(echo "$protoport" | cut -d'/' -f1)
    proto=$(echo "$protoport" | cut -d'/' -f2)

    state=$(echo "$line" | awk '{print $2}')

    service=$(echo "$line" | awk '{print $3}')

    version=$(echo "$line" | awk '{$1=""; $2=""; $3=""; sub(/^ +/, ""); print}')
    printf "%-10s %-6s %-20s %-30s\n" "$port" "$state" "$service" "$version" >> "$tmp_entries"
done

echo "resumen guardado en $tmp_entries"

