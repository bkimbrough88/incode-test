package main

import (
  "encoding/json"
  "io"
  "log"
  "net/http"
  "os"
  "strings"
  "time"

  "github.com/aws/aws-sdk-go/aws"
  "github.com/aws/aws-sdk-go/aws/session"
  "github.com/aws/aws-sdk-go/service/dynamodb"
  "github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
  "github.com/aws/aws-sdk-go/service/dynamodb/dynamodbiface"
  "go.uber.org/zap"
)

var (
  svc    dynamodbiface.DynamoDBAPI
  logger *zap.Logger
)

const postsTable = "posts"

type Post struct {
  Id         string    `json:"id"`
  Author     string    `json:"author"`
  DatePosted time.Time `json:"datePosted"`
  Message    string    `json:"message"`
}

func postsHandler(w http.ResponseWriter, req *http.Request) {
  logger.Debug("Received request", zap.Any("request", req))
  switch req.Method {
  case "GET":
    handleGet(w)
  case "POST":
    handlePost(w, req)
  default:
    logger.Warn("Method not allowed", zap.String("method", req.Method))
    w.WriteHeader(http.StatusMethodNotAllowed)
  }
}

func handlePost(w http.ResponseWriter, req *http.Request) {
  if req.ContentLength > 0 {
    body, err := io.ReadAll(req.Body)
    if err != nil {
      logger.Error("Failed to read request body", zap.Error(err))
      w.WriteHeader(http.StatusInternalServerError)
      return
    }
    
    post := &Post{}
    err = json.Unmarshal(body, post)
    if err != nil {
      logger.Error("Failed to convert body JSON into post object", zap.Error(err))
      w.WriteHeader(http.StatusInternalServerError)
      return 
    }

    err = createPost(*post)
    if err != nil {
      w.WriteHeader(http.StatusInternalServerError)
      return
    }

    w.WriteHeader(http.StatusCreated)
  } else {
    logger.Info("Received post request with no body")
    w.WriteHeader(http.StatusBadRequest)
  }
}

func handleGet(w http.ResponseWriter)  {
  posts, err := getPosts()
  if err != nil {
    w.WriteHeader(http.StatusInternalServerError)
    return
  }
  
  w.Header().Add("ContentType", "application/json")
  postsJson, err := json.Marshal(posts)
  if err != nil {
    logger.Error("Failed to marshal posts into JSON", zap.Error(err))
    w.WriteHeader(http.StatusInternalServerError)
    return
  }

  _, _ = w.Write(postsJson)
  w.WriteHeader(http.StatusOK)
}

func createPost(post Post) error {
  item, err := dynamodbattribute.MarshalMap(post)
  if err != nil {
    logger.Error("Failed to marshal post to dynamoDB item", zap.Error(err))
    return err
  }

  input := dynamodb.PutItemInput{
    Item:      item,
    TableName: aws.String(postsTable),
  }
  _, err = svc.PutItem(&input)
  if err != nil {
    logger.Error("Failed to insert item into table", zap.Error(err), zap.String("table", postsTable), zap.Any("item", item))
    return err
  }

  logger.Debug("Inserted item into table", zap.String("table", postsTable), zap.Any("item", item))
  return nil
}

func getPosts() ([]*Post, error) {  
  input := dynamodb.ScanInput{
    TableName: aws.String(postsTable),
  }
  scan, err := svc.Scan(&input)
  if err != nil {
    logger.Error("Failed to query DynamoDB", zap.Error(err), zap.String("table", postsTable))
    return nil, err
  }
  
  var posts []*Post
  err = dynamodbattribute.UnmarshalListOfMaps(scan.Items, posts)
  if err != nil {
    logger.Error("Failed to convert query result into Posts list", zap.Error(err), zap.Any("items", scan.Items))
    return nil, err
  }

  logger.Debug("Returning posts", zap.Any("posts", posts))
  return posts, nil
}

func main() {
  loggerProduction, err := zap.NewProduction()
  if err != nil {
    log.Fatalf("failed to initiate logger. Error: %s", err.Error())
  }
  logger = loggerProduction

  region := os.Getenv("AWS_REGION")
  awsSession, err := session.NewSession(&aws.Config{
    Region: aws.String(region)},
  )
  if err != nil {
    logger.Error("Failed to establish new AWS session", zap.Error(err))
    return
  }
  svc = dynamodb.New(awsSession)

  http.HandleFunc("/posts", postsHandler)

  if strings.ToLower(os.Getenv("USE_TLS")) == "true" {
    _ = http.ListenAndServeTLS(":443", os.Getenv("TLS_CERT_PATH"), os.Getenv("TLS_KEY_PATH"), nil)
  } else {
    _ = http.ListenAndServe(":80", nil)
  }
}
