import boto3
import datetime
import logging
import os

cloudwatch = boto3.client("cloudwatch")
logger = logging.getLogger()
logger.setLevel(os.environ.get("LOGLEVEL", logging.INFO))


def handler(event, context):
    logger.debug(f"environment variables:\n{os.environ}")
    before, latest = get_period_timestamps()
    metrics = get_metrics(before, latest)
    logger.debug(f"available metrics for {before}~{latest}:\n{metrics}")

    ANOMV = metrics["maxANOMV"][latest]
    NOER = metrics["sumNOER"][latest]
    GISI = metrics["avgGISI"][latest]

    if GISI > 0:
        l = 1 - NOER / (GISI * 0.098444 * 300)
    elif ANOMV > 0:
        l = 1
    else:
        l = 0
    logger.info(f"ANOMV={ANOMV} NOER={NOER} GISI={GISI} => l={l}")

    put_metric(latest, l)
    return {"WorkersClusterLoad": l}


def get_period_timestamps():
    now = datetime.datetime.now(datetime.timezone.utc)
    last_5min_mark = now - datetime.timedelta(
        minutes=now.minute % 5 + 5, seconds=now.second, microseconds=now.microsecond,
    )
    return last_5min_mark - datetime.timedelta(minutes=5), last_5min_mark


def get_metrics(t1, t2):
    queue = os.environ["QueueName"]
    group = os.environ["GroupName"]
    response = cloudwatch.get_metric_data(
        StartTime=t1,
        EndTime=t2 + datetime.timedelta(minutes=1),
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
    cloudwatch.put_metric_data(
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
