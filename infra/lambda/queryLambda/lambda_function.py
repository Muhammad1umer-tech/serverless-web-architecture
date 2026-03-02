import json
import os
import boto3
from boto3.dynamodb.conditions import Attr
from botocore.exceptions import ClientError

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ.get("TABLE_NAME", "")

def _resp(code: int, body: dict):
    return {"statusCode": code, "headers": {"Content-Type": "application/json"}, "body": json.dumps(body)}

def lambda_handler(event, context):
    if not TABLE_NAME:
        return _resp(500, {"error": "Missing env var: TABLE_NAME"})

    table = dynamodb.Table(TABLE_NAME)

    try:
        raw_body = event.get("body") or "{}"
        body = json.loads(raw_body) if isinstance(raw_body, str) else raw_body

        question_to_find = body.get("question")
        if not question_to_find:
            return _resp(400, {"error": "Missing 'question' in request body"})

        response = table.scan(
            FilterExpression=Attr("question").eq(question_to_find)
        )
        items = response.get("Items", [])

        if not items:
            return _resp(404, {"error": "Question not found"})

        return _resp(200, {"answer": items[0].get("answer")})

    except ClientError as e:
        return _resp(500, {"error": "AWS ClientError", "details": str(e)})
    except Exception as e:
        return _resp(500, {"error": "Unhandled error", "details": str(e)})