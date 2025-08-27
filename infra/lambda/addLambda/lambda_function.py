import json
import boto3
import uuid
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource("dynamodb")
s3 = boto3.client("s3")

bucket_name = "my-unique-bucket-name-umer-12345-29"
file_key = "data.json"
table_name = "serverless_dynamodb_table"
table = dynamodb.Table(table_name)

def lambda_handler(event, context):

    # Support both HTTP API (v2.0) and REST API (v1.0)
    path = event.get('rawPath') or event.get('resource') or ''
    method = (
        event.get("requestContext", {}).get("http", {}).get("method")
        or event.get("httpMethod")
        or ''
    )
    print(f"Received {method} request on path: {path}")

    if path.endswith("/add") and method == "POST":
        try:
            # Read file from S3
            response = s3.get_object(Bucket=bucket_name, Key=file_key)
            content = response["Body"].read().decode("utf-8")
            items = json.loads(content)

            if not isinstance(items, list):
                raise ValueError("Invalid JSON format. Expected a list of objects.")

            # Insert items into DynamoDB
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
                    print(f"Inserted: {question}")
                else:
                    print("Skipping item due to missing question/answer:", item)

            # ✅ Publish to SNS after insertion
            sns = boto3.client("sns")
            topic_arn = "arn:aws:sns:us-east-1:109804294991:data-added-topic-umer-11e3"  # <-- Replace this
            try:
                sns_message = f"{len(items)} items added to DynamoDB from {file_key}."
                sns_response = sns.publish(
                    TopicArn=topic_arn,
                    Subject="New data inserted",
                    Message=sns_message
                )
                print("SNS publish response:", sns_response)
            except Exception as sns_err:
                print("Error sending SNS message:", sns_err)

            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Data loaded into DynamoDB successfully."})
            }

        except Exception as e:
            print("Error:", e)
            return {
                "statusCode": 500,
                "body": json.dumps({"error": "Unhandled error", "details": str(e)})
            }

    else:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'Unsupported path or method'})
        }
