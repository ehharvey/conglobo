from xmlrpc.client import ResponseError
from minio import Minio
from minio.error import S3Error

# Set up the Minio client
client = Minio(
    endpoint = '127.0.0.1:9000',
    access_key='OCH9CnYNuKFIl47v',
    secret_key='c0ceU65IyP59YaCgCF4aZqVYaXzTjnM2',
    secure=False
)

# Create a bucket
try:
    client.make_bucket('services')
except ResponseError as err:
    print(err)

# Upload a file to the 'services' bucket
try:
    # Set the file path and name
    file_path = 'services.json'
    file_name = 'services.json'

    # Set the bucket name
    bucket_name = 'services'

    # Upload the file to the bucket
    client.fput_object(bucket_name, file_name, file_path)

    print(f'File {file_name} uploaded successfully to bucket {bucket_name}.')
except S3Error as e:
    print(f'Error uploading file: {e}')