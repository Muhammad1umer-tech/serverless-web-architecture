# locals.tf
locals {
  lambda_functions = {
    addLambda = "${path.root}/lambda/addLambda"
    queryLambda = "${path.root}/lambda/queryLambda"
  }
}

