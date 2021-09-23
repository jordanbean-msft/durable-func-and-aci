import json
import logging

import azure.functions as func
import azure.durable_functions as df

def main(event: func.EventGridEvent, client: df.DurableOrchestrationClient):
    result = json.dumps({
        'id': event.id,
        'data': event.get_json(),
        'topic': event.topic,
        'subject': event.subject,
        'event_type': event.event_type,
    })

    logging.info('Python EventGrid trigger processed an event: %s', result)

    client.raise_event(event.get_json()["instance_id"], 'ComputeComplete', event.get_json()["input_id"])
