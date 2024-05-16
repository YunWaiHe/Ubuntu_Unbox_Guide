#!/bin/bash

BASE_URL="https://developer.download.nvidia.com/compute/cudnn/redist/"
INDEX_URL="${BASE_URL}index.html"
TEMP_FILE=$(mktemp)

# cuDNN version
echo "Fetching cuDNN versions from \e[34m${INDEX_URL}\e[0m"
curl -s ${INDEX_URL} -o ${TEMP_FILE}
echo "Parsing available cuDNN versions..."
VERSIONS=($(grep -oP "(?<=href='redistrib_)[0-9]+\.[0-9]+\.[0-9]+(?=\.json')" ${TEMP_FILE} | uniq))
if [[ -z "$VERSIONS" ]]; then
    echo "No versions found, please double-check the website structure."
    rm ${TEMP_FILE}
    exit 1
fi
echo "\e[31mPlease select a cuDNN version:\e[0m"
select VERSION in "${VERSIONS[@]}"; do
    if [[ -n "$VERSION" ]]; then
        echo "\e[32mYou selected cuDNN \e[33m$VERSION\e[0m"
        SELECT_VERSION=$VERSION
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# CUDA version
JSON_URL="https://developer.download.nvidia.com/compute/cudnn/redist/redistrib_${SELECT_VERSION}.json"
JSON_FILE=$(mktemp)
curl -s ${JSON_URL} -o ${JSON_FILE}
CUDA_VARIANTS=($(jq -r '.cudnn.cuda_variant[]' ${JSON_FILE}))
echo "\e[31mPlease select a CUDA version:\e[0m"
select CUDA in "${CUDA_VARIANTS[@]}"; do
    if [[ -n "$CUDA" ]]; then
        echo "\e[32mYou selected CUDA \e[33m$CUDA\e[0m"
        SELECT_CUDA=$CUDA
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# Download
cudnn_path=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn["linux-\($arch)"][$cuda_version].relative_path' ${JSON_FILE})
cudnn_samples_path=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn_samples["linux-\($arch)"][$cuda_version].relative_path' ${JSON_FILE})

cudnn_md5=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn["linux-\($arch)"][$cuda_version].md5' ${JSON_FILE})
cudnn_samples_md5=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn_samples["linux-\($arch)"][$cuda_version].md5' ${JSON_FILE})

echo "${BASE_URL}${cudnn_path}"
echo "${BASE_URL}${cudnn_samples_path}"


# Download paths
cudnn_path=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn["linux-\($arch)"][$cuda_version].relative_path' ${JSON_FILE})
cudnn_samples_path=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn_samples["linux-\($arch)"][$cuda_version].relative_path' ${JSON_FILE})

# MD5 checksums
cudnn_md5=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn["linux-\($arch)"][$cuda_version].md5' ${JSON_FILE})
cudnn_samples_md5=$(jq -r --arg arch "$(uname -m)" --arg cuda_version "cuda${SELECT_CUDA}" '.cudnn_samples["linux-\($arch)"][$cuda_version].md5' ${JSON_FILE})

# Cleanup JSON files
rm ${JSON_FILE}

# Download files
cudnn_url="${BASE_URL}${cudnn_path}"
cudnn_file=$(basename ${cudnn_path})
cudnn_samples_url="${BASE_URL}${cudnn_samples_path}"
cudnn_samples_file=$(basename ${cudnn_samples_path})

echo "Downloading cuDNN file from ${cudnn_url}"
curl -o ${cudnn_file} ${cudnn_url}

echo "Downloading cuDNN samples file from ${cudnn_samples_url}"
curl -o ${cudnn_samples_file} ${cudnn_samples_url}

# Verify MD5
echo "Verifying MD5 checksums..."
calculated_cudnn_md5=$(md5sum ${cudnn_file} | awk '{ print $1 }')
calculated_cudnn_samples_md5=$(md5sum ${cudnn_samples_file} | awk '{ print $1 }')

if [[ "${calculated_cudnn_md5}" == "${cudnn_md5}" ]]; then
    echo -e "\e[32mcuDNN file checksum is correct.\e[0m"
else
    echo -e "\e[31mcuDNN file checksum mismatch!\e[0m"
    exit 1
fi

if [[ "${calculated_cudnn_samples_md5}" == "${cudnn_samples_md5}" ]]; then
    echo -e "\e[32mcuDNN samples file checksum is correct.\e[0m"
else
    echo -e "\e[31mcuDNN samples file checksum mismatch!\e[0m"
    exit 1
fi


# Extract and install cuDNN
echo "Extracting ${cudnn_file}..."
tar -xf ${cudnn_file}
extracted_dir=$(basename ${cudnn_file} .tar.xz)
sudo cp ${extracted_dir}/include/cudnn*.h /usr/local/cuda/include
sudo cp -P ${extracted_dir}/lib/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*

# Extract and compile cuDNN samples
echo "Extracting ${cudnn_samples_file}..."
tar -xf ${cudnn_samples_file}
extracted_samples_dir=$(basename ${cudnn_samples_file} .tar.xz)
cd ${extracted_samples_dir}/src/cudnn_samples_v8/mnistCUDNN
make clean && make
sudo apt install libfreeimage-dev
./mnistCUDNN

# Cleanup downloaded files
rm ${cudnn_file}
rm ${cudnn_samples_file}

echo -e "\e[34mInstallation and verification completed successfully.\e[0m"