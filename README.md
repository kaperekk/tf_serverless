S3 bucket sends notification about new .jpg file to SQS
SQS triggers lambda
lambda uses docker image to run script
script rescales UHD image to HD image and saves both