#!/bin/bash
set -euo pipefail

# Variables
DATA_IMG="verity_data.img"
HASH_IMG="verity_hash.img"
MOUNT_POINT="mnt"
BLOCK_SIZE=4096
DATA_SIZE_MB=100

echo "Step 1: Creating a 100MB data image..."
dd if=/dev/zero of="${DATA_IMG}" bs=1M count=${DATA_SIZE_MB}

echo "Step 2: Formatting the image as ext4..."
mkfs.ext4 "${DATA_IMG}"

echo "Step 3: Mounting image and adding test data..."
mkdir -p ${MOUNT_POINT}
sudo mount -o loop "${DATA_IMG}" ${MOUNT_POINT}
echo "Hello, dm-verity!" | sudo tee ${MOUNT_POINT}/hello.txt > /dev/null
sudo umount ${MOUNT_POINT}

echo "Step 4: Generating the dm-verity hash tree..."
# Run veritysetup format and capture its output
sudo veritysetup format "${DATA_IMG}" "${HASH_IMG}" > verity_output.txt

echo "Step 5: Extracting the root hash..."
grep "Root hash:" verity_output.txt | awk '{print $3}' > roothash.txt
echo "Root hash is: $(cat roothash.txt)"

