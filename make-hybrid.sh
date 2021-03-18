#!/usr/bin/env bash
  set -eu -o pipefail
  shopt -qs failglob
  DISK_IMAGE="$1"
  # Define partition type GUIDs for all OS-managed partitions. This is required
  # for the boot partition, where we set gptprio bits in the GUID-specific use
  # field, but we might as well do it for all of them.
  BOTTLEROCKET_BOOT_TYPECODE="6b636168-7420-6568-2070-6c616e657421"
  EFI_SYSTEM_TYPECODE="C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
  BOTTLEROCKET_ROOT_TYPECODE="5526016a-1a97-4ea4-b39a-b7c8c6ca4502"
  BOTTLEROCKET_HASH_TYPECODE="598f10af-c955-4456-6a99-7720068a6cea"
  BOTTLEROCKET_RESERVED_TYPECODE="0c5d99a5-d331-4147-baef-08e2b855bdc9"
  BOTTLEROCKET_PRIVATE_TYPECODE="440408bb-eb0b-4328-a6e5-a29038fad706"
  BOTTLEROCKET_DATA_TYPECODE="626f7474-6c65-6474-6861-726d61726b73"
  BOTTLEROCKET_FIRM_TYPECODE="31415927-c929-45e7-a172-fe3407e096ac"
  truncate -s 2G "${DISK_IMAGE}"
  # boot: 40M + root: 920M + hash: 10M + reserved: 28M = 998M
  # boot partition attributes (-A): 48 = gptprio priority bit; 56 = gptprio successful bit
  # partitions are backwards so that we don't make things inconsistent when specifying a wrong end sector :)
  sgdisk --clear \
     -n 0:2005M:2047M -c 0:"BOTTLEROCKET-PRIVATE"    -t 0:"${BOTTLEROCKET_PRIVATE_TYPECODE}" \
     -n 0:1977M:0     -c 0:"BOTTLEROCKET-RESERVED-B" -t 0:"${BOTTLEROCKET_RESERVED_TYPECODE}" \
     -n 0:1967M:0     -c 0:"BOTTLEROCKET-HASH-B"     -t 0:"${BOTTLEROCKET_HASH_TYPECODE}" \
     -n 0:1047M:0     -c 0:"BOTTLEROCKET-ROOT-B"     -t 0:"${BOTTLEROCKET_ROOT_TYPECODE}" \
     -n 0:1007M:0     -c 0:"BOTTLEROCKET-BOOT-B"     -t 0:"${BOTTLEROCKET_BOOT_TYPECODE}" -A 0:"clear":48 -A 0:"clear":56 \
     -n 0:979M:0      -c 0:"BOTTLEROCKET-RESERVED-A" -t 0:"${BOTTLEROCKET_RESERVED_TYPECODE}" \
     -n 0:969M:0      -c 0:"BOTTLEROCKET-HASH-A"     -t 0:"${BOTTLEROCKET_HASH_TYPECODE}" \
     -n 0:49M:0       -c 0:"BOTTLEROCKET-ROOT-A"     -t 0:"${BOTTLEROCKET_ROOT_TYPECODE}" \
     -n 0:9M:0        -c 0:"BOTTLEROCKET-BOOT-A"     -t 0:"${BOTTLEROCKET_BOOT_TYPECODE}" -A 0:"set":48 -A 0:"set":56 \
     -n 0:1M:0        -c 0:"PI-BOOT"                 -t 0:"${BOTTLEROCKET_FIRM_TYPECODE}" \
     --sort --print "${DISK_IMAGE}"
