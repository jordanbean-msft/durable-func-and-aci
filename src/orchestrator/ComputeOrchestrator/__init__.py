# This function is not intended to be invoked directly. Instead it will be
# triggered by an HTTP starter function.
# Before running this sample, please:
# - create a Durable activity function (default name is "Hello")
# - create a Durable HTTP starter function
# - add azure-functions-durable to requirements.txt
# - run pip install -r requirements.txt

import logging
import json
import time
from typing import NamedTuple

import azure.functions as func
import azure.durable_functions as df

class InputData:
  id: str
  job_id: str
  input_data: list

  def __init__(self, id, input_data):
    self.id = id
    self.input_data = input_data

  @staticmethod
  def to_json(obj):
      return json.dumps(obj, default=lambda o: o.__dict__, sort_keys=True, indent=4)
  @staticmethod
  def from_json(stream):
      temp = json.loads(stream)
      result = InputData(temp["id"], temp["input_data"])
      result.job_id = temp["job_id"]
      return result

def orchestrator_function(context: df.DurableOrchestrationContext):
    overall_job_id = time.time_ns()

    input_data = []
    input_data.append(InputData(id=1, input_data=[1,1]))
    input_data.append(InputData(id=2, input_data=[2,2]))
    input_data.append(InputData(id=3, input_data=[3,3]))
    tasks = []

    for input in input_data:
        job_id =  f"{overall_job_id}-{input.id}"        
        input.job_id = job_id
        tasks.append(context.call_activity("Compute", input))
        event_name = f"Compute-{job_id}"
        print(f"eventName: {event_name}")
        tasks.append(context.wait_for_external_event("ComputeComplete"))

    yield context.task_all(tasks)    

main = df.Orchestrator.create(orchestrator_function)