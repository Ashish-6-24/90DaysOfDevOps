#!/bin/bash
set -euo pipefail

check_disk(){
    local usage
    usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    echo "Disk Usage is: ${usage}%"

    if [ "${usage}" -gt 80 ]; then
        return 1
    else
        return 0
    fi
}

check_memory(){
    local free_memory
    free_memory=$(free -m | awk 'NR==2 {print $7}')
    echo "Free memory is: ${free_memory}MB"

    if [ "${free_memory}" -lt 700 ]; then
        return 1
    else
        return 0
    fi
}

main(){
    if check_disk; then
        echo "Disk status: Healthy"
    else
        echo "Disk Status: Critical"
    fi

    echo ""

    if check_memory; then
        echo "Memory Status: Healthy Memory"
    else
        echo "Memory status: Low memory"
    fi
}

main "$@"
