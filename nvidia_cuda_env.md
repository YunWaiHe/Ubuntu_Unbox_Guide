

# Installation Order

0. dependency
1. Nvidia Driver
2. CUDA Toolkit
3. cuDNN

# 1. Nvidia Driver

[https://www.nvidia.com/Download/index.aspx?lang=en-us](https://www.nvidia.com/Download/index.aspx?lang=en-us)

```shell
# after execute .run file
sudo mokutil --import /usr/share/nvidia/nvidia-modsign-crt-12312312.der
reboot
```

```shell
# validate installation: no warning and no error
nvidia-smi
```

# 2. CUDA Toolkit

[https://developer.nvidia.com/cuda-toolkit-archive](https://developer.nvidia.com/cuda-toolkit-archive)

In general, it depends on your project.

Select corresponding version.

```shell
# no need to select NVIDIA driver
# if failed, look up log files
# simple test after installation
```

# 3. cuDNN

[https://developer.nvidia.com/rdp/cudnn-archive](https://developer.nvidia.com/rdp/cudnn-archive)

[https://docs.nvidia.com/deeplearning/cudnn/archives/index.html](https://docs.nvidia.com/deeplearning/cudnn/archives/index.html)

support matrix

[https://docs.nvidia.com/deeplearning/cudnn/archives/cudnn-897/support-matrix/index.html](https://docs.nvidia.com/deeplearning/cudnn/archives/cudnn-897/support-matrix/index.html)

## Installation

```shell
# if tar file installation
# https://developer.download.nvidia.com/compute/cudnn/redist/
# get cuda relative_path from redistrib_version.json
# concat

wget https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-x86_64/cudnn-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz
tar -xvf cudnn-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz
sudo cp cudnn-*-archive/include/cudnn*.h /usr/local/cuda/include 
sudo cp -P cudnn-*-archive/lib/libcudnn* /usr/local/cuda/lib64 
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
```

## Test

```shell
# https://developer.download.nvidia.com/compute/cudnn/redist/
# get cudnn_samples relative_path from redistrib_version.json
# concat

wget https://developer.download.nvidia.com/compute/cudnn/redist/cudnn_samples/linux-x86_64/cudnn_samples-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz
tar -xvf cudnn_samples-linux-x86_64-8.9.7.29_cuda12-archive.tar.xz
cd cudnn_samples-linux-x86_64-8.9.7.29_cuda12-archive/src/cudnn_samples_v8/mnistCUDNN
make clean && make
./mnistCUDNN
# If cuDNN is properly installed and running on your Linux system, you will see "Test passed!"
```

Or use scripts

[https://github.com/YunWaiHe/Ubuntu_Unbox_Guide/blob/main/cudnn_install.sh](https://github.com/YunWaiHe/Ubuntu_Unbox_Guide/blob/main/cudnn_install.sh)
