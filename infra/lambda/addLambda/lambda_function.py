import json
import os
import uuid
import boto3
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")
sns = boto3.client("sns")

BUCKET_NAME = os.environ.get("BUCKET_NAME", "")
FILE_KEY = os.environ.get("FILE_KEY", "data.json")
TABLE_NAME = os.environ.get("TABLE_NAME", "")
TOPIC_ARN = os.environ.get("TOPIC_ARN", "")

secrets = boto3.client("secretsmanager")
_secret_cache = None

def get_admin_email():
    global _secret_cache
    if _secret_cache is None:
        arn = os.environ["APP_SECRET_ARN"]
        resp = secrets.get_secret_value(SecretId=arn)
        _secret_cache = json.loads(resp["SecretString"])
    return _secret_cache["admin_email"]

def _resp(code: int, body: dict):
    return {"statusCode": code, "headers": {"Content-Type": "application/json"}, "body": json.dumps(body)}

def lambda_handler(event, context):
    if not BUCKET_NAME or not TABLE_NAME:
        return _resp(500, {"error": "Missing env vars: BUCKET_NAME or TABLE_NAME"})

    table = dynamodb.Table(TABLE_NAME)

    try:
        # Read JSON list from S3
        response = s3.get_object(Bucket=BUCKET_NAME, Key=FILE_KEY)
        content = response["Body"].read().decode("utf-8")
        items = json.loads(content)

        if not isinstance(items, list):
            return _resp(400, {"error": "Invalid JSON format in S3 file. Expected a list of objects."})

        inserted = 0
        skipped = 0

        for item in items:
            question = item.get("question")
            answer = item.get("answer")

            if question and answer:
                table.put_item(
                    Item={
                        "Id": str(uuid.uuid4()),
                        "question": question,
                        "answer": answer
                    }
                )
                inserted += 1
            else:
                skipped += 1

        # Notify Admin via SNS (optional)
        if TOPIC_ARN:
            try:
                sns.publish(
                    TopicArn=TOPIC_ARN,
                    Subject="New data inserted",
                    Message=f"{inserted} items added to DynamoDB from {FILE_KEY}. Skipped: {skipped}"
                )
            except Exception as sns_err:
                print("SNS publish failed:", sns_err)

        return _resp(200, {"message": "Data loaded successfully", "inserted": inserted, "skipped": skipped})

    except ClientError as e:
        return _resp(500, {"error": "AWS ClientError", "details": str(e)})
    except Exception as e:
        return _resp(500, {"error": "Unhandled error", "details": str(e)})