# How to setup the BigQuery API

1. Install Anaconda: https://www.continuum.io/downloads
2. Install the environment requirements
 	1. Navigate to top of this package (`mooc_capstone_private/`)
 	2. Type `conda env create -f environment.yml && source activate mooc` (Linux only) OR `conda create --name mooc && source activate mooc && pip install google-cloud pytest pandas pandas-gbq lxml click beautifulsoup4` (Mac) OR `conda create --name mooc && activate mooc && pip install google-cloud pytest pandas pandas-gbq lxml click beautifulsoup4`
 	3. Type `source activate mooc` (Linux/Mac) or `activate mooc`
3. Install `gsutil` using instructions from [this page](https://cloud.google.com/storage/docs/gsutil_install).
3. Authenticate your Google Cloud account for this computer `gcloud auth application-default login`
4. Restart your computer.
5. Navigate to `src/helper_scripts` and enter the following command, replacing everything in `<>` with your desired entries:
`python rbq.py <sql> -c <course> -d <date> -l <limit>`
