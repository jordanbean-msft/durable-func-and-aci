import json, os, logging
from azure.storage import queue
from azure.storage.queue import (
  QueueClient
)
from azure.storage.blob import (
  BlobServiceClient,
  BlobClient
)

logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"))

def main():
  log = logging.getLogger(__name__)
  connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
  queue_name = os.getenv("AZURE_STORAGE_QUEUE_NAME")
  input_blob_container_name = os.getenv("AZURE_STORAGE_INPUT_BLOB_CONTAINER_NAME")
  output_blob_container_name = os.getenv("AZURE_STORAGE_OUTPUT_BLOB_CONTAINER_NAME")
  #job_id = os.getenv()

  blob_service_client = BlobServiceClient.from_connection_string(connection_string)

  queue_client = QueueClient.from_connection_string(connection_string, queue_name)

  log.info("Connected to queue service")
  
  messages = queue_client.receive_messages()

  log.info("Processing messages")

  for message in messages:
    log.info("Deleting message: " + message.content)

    #input_blob_client = blob_service_client.get_blob_client(conatiner=input_blob_container_name, blob="")
    #output_blob_client = blob_service_client.get_blob_client(container=output_blob_container_name, blob="")

    queue_client.delete_message(message.id, message.pop_receipt)

  log.info("Complete")

if __name__=="__main__":
  main()