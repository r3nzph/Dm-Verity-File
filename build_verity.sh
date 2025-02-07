#!/bin/bash
set -euo pipefail

# Define output directory (repository root)
OUT_DIR="$(pwd)"

DATA_IMG="${OUT_DIR}/verity_data.img"
HASH_IMG="${OUT_DIR}/verity_hash.img"
OUTPUT_FILE="${OUT_DIR}/verity_output.txt"
ROOT_HASH_FILE="${OUT_DIR}/roothash.txt"

echo "Creating a 100MB image file..."
dd if=/dev/zero of="${DATA_IMG}" bs=1M count=100

echo "Formatting image as ext4..."
mkfs.ext4 "${DATA_IMG}"

echo "Mounting image and adding test data..."
mkdir -p mnt
sudo mount -o loop "${DATA_IMG}" mnt
echo "Hello, dm-verity!" | sudo tee mnt/hello.txt > /dev/null
sudo umount mnt

echo "Generating the dm-verity hash tree..."
sudo veritysetup format "${DATA_IMG}" "${HASH_IMG}" > "${OUTPUT_FILE}"
echo "Verity output:"
cat "${OUTPUT_FILE}"

echo "Extracting the root hash..."
grep "Root hash:" "${OUTPUT_FILE}" | awk '{print $3}' > "${ROOT_HASH_FILE}"
echo "Root hash is: $(cat "${ROOT_HASH_FILE}")"
