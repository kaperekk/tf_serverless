import boto3
import uuid
from PIL import Image

s3 = boto3.client('s3')
PATH_TO_IMAGES="/images"

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key'] 
        download_path = f'{PATH_TO_IMAGES}/{uuid.uuid4()}-{key}'
        upload_path = f'{PATH_TO_IMAGES}/resized-{key}'
        
        s3.download_file(bucket, key, download_path)
        resize_image(download_path, upload_path)
        
        new_key = "resized-{}".format(key)
        s3.upload_file(upload_path, bucket, new_key)

def resize_image(download_path, upload_path):
    with Image.open(download_path) as img:
        width, height = img.size
        print("Original image resolution: {} x {}".format(width, height))

        if width > 3840 and height > 2160:
            print("Image is UHD, resizing to HD (1920x1080)")
            img = img.resize((1920, 1080), Image.ANTIALIAS)
            
        img.save(upload_path)
