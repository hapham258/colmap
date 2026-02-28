#!/bin/bash

# Parse options from terminal
options="$@"
set_options() {
  prev_option=""
  for option in $options; do
    case $option in
    "-h" | "--help")
      echo "     $0 [OPTION...]"
      echo "     -h, --help; Show help content"
      echo "     -i, --img; Name of container's image (default: colmap:latest)"
      exit 1
      ;;
    esac
    case $prev_option in
      "-i" | "--img")
        img=$option
        ;;
    esac
    prev_option="$option"
  done
}
set_options

# Check the validity of options and retrieve default values
if [ -z $img ]; then
  img="colmap:latest"
fi
echo "Container's image: $img"

# Setup mounting-related arguments
mounting_args="-v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd):/workspace"
mounting_args="$mounting_args -v $HOME/Documents/VisLoc_Datasets:/home/datasets"
echo "Mounting-related arguments: $mounting_args"

# Run the container
xhost + local:root
if lspci | grep -i nvidia > /dev/null; then
  echo "NVIDIA GPU detected!"
  docker run \
      --gpus all -it --net=host --privileged \
      --env="NVIDIA_DRIVER_CAPABILITIES=all" \
      --device /dev/bus/usb \
      -v /dev:/dev \
      -e DISPLAY=$DISPLAY \
      $mounting_args \
      -w /workspace \
      $img
else
  echo "No NVIDIA GPU found."
  docker run \
      -it --net=host --privileged \
      --device /dev/dri \
      --device /dev/bus/usb \
      -v /dev:/dev \
      -e DISPLAY=$DISPLAY \
      $mounting_args \
      -w /workspace \
      $img
fi
