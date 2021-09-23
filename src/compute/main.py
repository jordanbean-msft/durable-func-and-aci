import os, logging, json
from azure.storage.queue import (
    QueueClient
)
from azure.storage.blob import (
    BlobServiceClient,
    BlobClient
)
import algorithm

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
        log.info("Processing message: " + message.id)

        job_configuration = json.loads(message.content)

        path_to_input_file = f"{job_configuration['jobId']}/{job_configuration['fileName']}"

        input_blob_client = blob_service_client.get_blob_client(container=input_blob_container_name, blob=path_to_input_file)

        log.info("Downloading input blob: " + path_to_input_file)

        input_file_stream = input_blob_client.download_blob().readall()

        input_json = json.loads(input_file_stream)
        
        result = algorithm.compute(log, input_json['inputData'])

        path_to_output_file = f"{job_configuration['jobId']}/{job_configuration['fileName']}"

        output_blob_client = blob_service_client.get_blob_client(container=output_blob_container_name, blob=path_to_output_file)

        output = {
          "jobId": job_configuration['jobId'],
          "result": result
        }

        output_json = json.dumps(output, indent=4)
        
        log.info("Uploading output blob: " + path_to_output_file)

        output_blob_client.upload_blob(output_json)

        #queue_client.delete_message(message.id, message.pop_receipt)

        #input_blob_client.delete_blob()

    log.info("Complete")

if __name__=="__main__":
    main()