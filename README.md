Build thirdparty libraries for `NVIDIA GeForce RTX 5090 GPU`:
```
cd thirdparty/ceres
git submodule update --init --recursive
cd ..
mkdir -p ceres-build && cd ceres-build
cmake ../ceres -GNinja \
  -DWITH_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=120 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=../ceres-install \
  -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DBUILD_BENCHMARKS=OFF
ninja -j16
ninja install
cd ../../
```
Setup for `NVIDIA GeForce RTX 5090 GPU`:
```
sudo mkdir -p /usr/include/opencv4
mkdir build && cd build
cmake .. -GNinja \
  -DCMAKE_CUDA_ARCHITECTURES=120 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCeres_DIR=$HOME/colmap/thirdparty/ceres-install/lib/cmake/Ceres \
  -DCMAKE_INSTALL_PREFIX=$HOME/colmap/install \
  -DBLA_VENDOR=Intel10_64lp
ninja -j16
ninja install
cd ..
export LD_LIBRARY_PATH=$HOME/colmap/install/thirdparty:$HOME/colmap/install/lib:$LD_LIBRARY_PATH
```
Run demo with South Building dataset:
```
export IMG_PATH=$HOME/Documents/VisLoc_Datasets/South_Building/images
export OUT_PATH=$(pwd)/output/south_building
mkdir -p $OUT_PATH

# Extract features
./install/bin/colmap feature_extractor \
    --database_path $OUT_PATH/database.db --image_path $IMG_PATH \
    --ImageReader.single_camera 1 --FeatureExtraction.use_gpu 1 --FeatureExtraction.type ALIKED_N16ROT
  
# Match features
./install/bin/colmap exhaustive_matcher \
    --database_path $OUT_PATH/database.db \
    --FeatureMatching.use_gpu 1 --FeatureMatching.type ALIKED_LIGHTGLUE

# Match features (sequential)
./install/bin/colmap sequential_matcher \
    --database_path $OUT_PATH/database.db \
    --FeatureMatching.use_gpu 1 --FeatureMatching.type ALIKED_LIGHTGLUE \
    --SequentialMatching.overlap 10

# Reconstruct
mkdir -p $OUT_PATH/sparse
./install/bin/colmap mapper \
    --database_path $OUT_PATH/database.db --image_path $IMG_PATH --output_path $OUT_PATH/sparse \
    --Mapper.ba_use_gpu 1

# Reconstruct (global)
mkdir -p $OUT_PATH/sparse
./install/bin/colmap view_graph_calibrator --database_path $OUT_PATH/database.db
./install/bin/colmap global_mapper \
    --database_path $OUT_PATH/database.db --image_path $IMG_PATH --output_path $OUT_PATH/sparse \
    --GlobalMapper.gp_use_gpu 1

# Analyze and visualize the final model
./install/bin/colmap model_analyzer --path $OUT_PATH/sparse/0
./install/bin/colmap gui \
    --database_path $OUT_PATH/database.db --image_path $IMG_PATH --import_path $OUT_PATH/sparse/0
```

COLMAP
======

About
-----

COLMAP is a general-purpose Structure-from-Motion (SfM) and Multi-View Stereo
(MVS) pipeline with a graphical and command-line interface. It offers a wide
range of features for reconstruction of ordered and unordered image collections.
The software is licensed under the new BSD license.

The latest source code is available at https://github.com/colmap/colmap. COLMAP
builds on top of existing works and when using specific algorithms within
COLMAP, please also cite the original authors, as specified in the source code,
and consider citing relevant third-party dependencies (most notably
ceres-solver, poselib, sift-gpu, vlfeat).

Download
--------

* Binaries for **Windows** and other resources can be downloaded
  from https://github.com/colmap/colmap/releases.
* Binaries for **Linux/Unix/BSD** are available at
  https://repology.org/metapackage/colmap/versions.
* Pre-built **Docker** images are available at
  https://hub.docker.com/r/colmap/colmap.
* Conda packages are available at https://anaconda.org/conda-forge/colmap and
  can be installed with `conda install colmap`
* **Python bindings** are available at https://pypi.org/project/pycolmap.
  CUDA-enabled wheels are available at https://pypi.org/project/pycolmap-cuda12.
* To **build from source**, please see https://colmap.github.io/install.html.

Getting Started
---------------

1. Download pre-built binaries or build from source.
2. Download one of the provided [sample datasets](https://demuc.de/colmap/datasets/)
   or use your own images.
3. Use the **automatic reconstruction** to easily build models
   with a single click or command.

Documentation
-------------

The documentation is available [here](https://colmap.github.io/).

To build and update the documentation at the documentation website,
follow [these steps](https://colmap.github.io/install.html#documentation).

Support
-------

Please, use [GitHub Discussions](https://github.com/colmap/colmap/discussions)
for questions and the [GitHub issue tracker](https://github.com/colmap/colmap)
for bug reports, feature requests/additions, etc.

Acknowledgments
---------------

COLMAP was originally written by [Johannes Schönberger](https://demuc.de/) with
funding provided by his PhD advisors Jan-Michael Frahm and Marc Pollefeys.
The team of core project maintainers currently includes
[Johannes Schönberger](https://github.com/ahojnnes),
[Paul-Edouard Sarlin](https://github.com/sarlinpe),
[Shaohui Liu](https://github.com/B1ueber2y), and
[Linfei Pan](https://lpanaf.github.io/).

The Python bindings in PyCOLMAP were originally added by
[Mihai Dusmanu](https://github.com/mihaidusmanu),
[Philipp Lindenberger](https://github.com/Phil26AT), and
[Paul-Edouard Sarlin](https://github.com/sarlinpe).

The project has also benefitted from countless community contributions, including
bug fixes, improvements, new features, third-party tooling, and community
support (special credits to [Torsten Sattler](https://tsattler.github.io)).

Citation
--------

If you use this project for your research, please cite:

    @inproceedings{schoenberger2016sfm,
        author={Sch\"{o}nberger, Johannes Lutz and Frahm, Jan-Michael},
        title={Structure-from-Motion Revisited},
        booktitle={Conference on Computer Vision and Pattern Recognition (CVPR)},
        year={2016},
    }

    @inproceedings{schoenberger2016mvs,
        author={Sch\"{o}nberger, Johannes Lutz and Zheng, Enliang and Pollefeys, Marc and Frahm, Jan-Michael},
        title={Pixelwise View Selection for Unstructured Multi-View Stereo},
        booktitle={European Conference on Computer Vision (ECCV)},
        year={2016},
    }

If you use the global SfM pipeline (GLOMAP), please cite:

    @inproceedings{pan2024glomap,
        author={Pan, Linfei and Barath, Daniel and Pollefeys, Marc and Sch\"{o}nberger, Johannes Lutz},
        title={{Global Structure-from-Motion Revisited}},
        booktitle={European Conference on Computer Vision (ECCV)},
        year={2024},
    }

If you use the image retrieval / vocabulary tree engine, please cite:

    @inproceedings{schoenberger2016vote,
        author={Sch\"{o}nberger, Johannes Lutz and Price, True and Sattler, Torsten and Frahm, Jan-Michael and Pollefeys, Marc},
        title={A Vote-and-Verify Strategy for Fast Spatial Verification in Image Retrieval},
        booktitle={Asian Conference on Computer Vision (ACCV)},
        year={2016},
    }

Contribution
------------

Contributions (bug reports, bug fixes, improvements, etc.) are very welcome and
should be submitted in the form of new issues and/or pull requests on GitHub.

License
-------

The COLMAP library is licensed under the new BSD license. Note that this text
refers only to the license for COLMAP itself, independent of its thirdparty
dependencies, which are separately licensed. Building COLMAP with these
dependencies may affect the resulting COLMAP license.

    Copyright (c), ETH Zurich and UNC Chapel Hill.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

        * Redistributions of source code must retain the above copyright
          notice, this list of conditions and the following disclaimer.

        * Redistributions in binary form must reproduce the above copyright
          notice, this list of conditions and the following disclaimer in the
          documentation and/or other materials provided with the distribution.

        * Neither the name of ETH Zurich and UNC Chapel Hill nor the names of
          its contributors may be used to endorse or promote products derived
          from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
