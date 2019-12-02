import datetime
import logging
import os

import boto3

CW = boto3.client("cloudwatch")
logging.getLogger().setLevel(os.environ.get("LOGLEVEL", logging.INFO))


def handler(_event, _context):
    logging.debug("environment variables:\n %s", os.environ)
    before, latest = get_period_timestamps()
    metrics = get_metrics(before, latest)
    logging.debug("available metrics for %s~%s:\n%s", before, latest, metrics)

    messages = metrics["maxANOMV"][latest]
    empty_receives = metrics["sumNOER"][latest]
    instances = metrics["avgGISI"][latest]
    logging.info("ANOMV=%s NOER=%s GISI=%s", messages, empty_receives, instances)

    if instances > 0:
        load = 1 - empty_receives / (instances * 0.098444 * 300)
    elif messages > 0:
        load = 1
    else:
        load = 0

    logging.info("L=%s", load)
    put_metric(latest, load)
    return {"WorkersClusterLoad": load}


def get_period_timestamps():
    now = datetime.datetime.now(datetime.timezone.utc)
    last_5min_mark = now - datetime.timedelta(
        minutes=now.minute % 5 + 5, seconds=now.second, microseconds=now.microsecond,
    )
    return last_5min_mark - datetime.timedelta(minutes=5), last_5min_mark


def get_metrics(t_1, t_2):
    queue = os.environ["QueueName"]
    group = os.environ["GroupName"]
    response = CW.get_metric_data(
        StartTime=t_1,
        EndTime=t_2 + datetime.timedelta(minutes=1),
        ScanBy="TimestampAscending",
        MetricDataQueries=[
            {
                "Id": "maxANOMV",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/SQS",
                        "MetricName": "ApproximateNumberOfMessagesVisible",
                        "Dimensions": [{"Name": "QueueName", "Value": f"{queue}"}],
                    },
                    "Period": 300,
                    "Stat": "Maximum",
                    "Unit": "Count",
                },
            },
            {
                "Id": "sumNOER",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/SQS",
                        "MetricName": "NumberOfEmptyReceives",
                        "Dimensions": [{"Name": "QueueName", "Value": f"{queue}"}],
                    },
                    "Period": 300,
                    "Stat": "Sum",
                    "Unit": "Count",
                },
            },
            {
                "Id": "avgGISI",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/AutoScaling",
                        "MetricName": "GroupInServiceInstances",
                        "Dimensions": [
                            {"Name": "AutoScalingGroupName", "Value": f"{group}"}
                        ],
                    },
                    "Period": 300,
                    "Stat": "Average",
                    "Unit": "None",
                },
            },
            {
                "Id": "uniGDC",
                "MetricStat": {
                    "Metric": {
                        "Namespace": "AWS/AutoScaling",
                        "MetricName": "GroupDesiredCapacity",
                        "Dimensions": [
                            {"Name": "AutoScalingGroupName", "Value": f"{group}"}
                        ],
                    },
                    "Period": 60,
                    "Stat": "Average",
                    "Unit": "None",
                },
            },
        ],
    )
    return {
        m["Id"]: dict(zip(m["Timestamps"], m["Values"]))
        for m in response["MetricDataResults"]
    }


def put_metric(time, value):
    CW.put_metric_data(
        Namespace="Turbine",
        MetricData=[
            {
                "MetricName": "WorkersClusterLoad",
                "Dimensions": [{"Name": "StackName", "Value": os.environ["StackName"]}],
                "Timestamp": time,
                "Value": value,
                "Unit": "None",
            }
        ],
    )
