import json
import boto3
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

    # Parse body safely
    raw_body = event.get('body', '{}')
    try:
        body = json.loads(raw_body) if isinstance(raw_body, str) else raw_body
    except Exception:
        body = {}

    if path.endswith("/query") and method == "POST":
        try:
            question_to_find = body.get("question")
            if not question_to_find:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"error": "Missing 'question' in request body"})
                }

            # Scan for the question
            response = table.scan(
                FilterExpression=Attr("question").eq(question_to_find)
            )

            items = response.get("Items", [])

            if not items:
                return {
                    "statusCode": 404,
                    "body": json.dumps({"error": "Question not found"})
                }

            # Return only the answer
            answer = items[0].get("answer")
            return {
                "statusCode": 200,
                "body": json.dumps({"answer": answer})
            }

        except Exception as e:
            print("Error in query:", e)
            return {
                "statusCode": 500,
                "body": json.dumps({"error": "Query failed", "details": str(e)})
            }

    # Unsupported route
    else:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'Unsupported path or method'})
        }
