import os
from minio import Minio
from minio.error import ResponseError

# Instantiate a MinIO client object with endpoint, access key, and secret key
client = Minio(
    "localhost:9000",
    access_key="your-access-key",
    secret_key="your-secret-key",
    secure=False
)

# Set the bucket name
bucket_name = "your-bucket-name"

# Create the bucket if it doesn't exist
if not client.bucket_exists(bucket_name):
    client.make_bucket(bucket_name)

# Set the path to the file to upload
file_path = "/path/to/your/file.txt"

# Set the object name (the name under which the file will be stored in the bucket)
object_name = os.path.basename(file_path)

try:
    # Upload the file to the bucket
    client.fput_object(bucket_name, object_name, file_path)
    print(f"{file_path} uploaded successfully!")
except ResponseError as err:
    print(f"Error uploading {file_path}: {err}")