/// `Client` represents an authorized b2 client.
struct Client {
  /// The identifier for the account.
  account_id : String // `json:"accountId"`
  /// A data structure that groups the information you need by API suite.
  api_info : APIInfo // `json:"apiInfo"`
  /// An authorization token to use with all calls, other than b2_authorize_account, that need an Authorization header. This authorization token is valid for at most 24 hours.
  authorization_token : String // `json:"authorizationToken"`
  /// Expiration timestamp for the application key.
  application_key_expiration_timestamp : Int? // `json:"applicationKeyExpirationTimestamp,omitempty"`

  /// This client is used to interact with this bucket.
  bucket_id : String
  bucket_name : String
} derive(Show)

fn Client::from_json!(
  body : String,
  bucket_id : String,
  bucket_name : String
) -> Client!ClientError {
  let json = try {
    @json.parse!(body)
  } catch {
    e => raise ClientError(e.to_string())
  }
  //
  match json {
    {
      "accountId": String(account_id),
      "apiInfo": Object(api_info),
      "authorizationToken": String(authorization_token),
      "applicationKeyExpirationTimestamp": application_key_expiration_timestamp,
    } => {
      let application_key_expiration_timestamp = match
        application_key_expiration_timestamp {
        Number(v) => Some(v.to_int())
        _ => None
      }
      let api_info = APIInfo::from_json!(api_info)
      {
        account_id,
        api_info,
        authorization_token,
        application_key_expiration_timestamp,
        bucket_id,
        bucket_name,
      }
    }
    _ => raise ClientError("unable to parse Client: \{json}")
  }
}

test "Client::from_json - invalid apiInfo structure" {
  let invalid_apiInfo_json =
    #|{
    #|  "accountId": "12345",
    #|  "apiInfo": "invalidApiInfo",
    #|  "authorizationToken": "auth_token",
    #|  "applicationKeyExpirationTimestamp": 1672531200
    #|}
  try {
    let client = Client::from_json!(
      invalid_apiInfo_json, "some-bucket-id", "some-bucket-name",
    )
    raise ClientError("expected failure, but got: \{client}")
  } catch {
    ClientError(e) =>
      assert_eq!(
        e,
        #|unable to parse Client: Object({"accountId": String("12345"), "apiInfo": String("invalidApiInfo"), "authorizationToken": String("auth_token"), "applicationKeyExpirationTimestamp": Number(1672531200)})
        ,
      )
  }
}

test "Client::from_json - partial valid JSON input" {
  let partial_valid_json =
    #|{
    #|  "accountId": "12345",
    #|  "apiInfo": {
    #|    "storageApi": {
    #|      "absoluteMinimumPartSize": 5000000,
    #|      "apiUrl": "https://apiNNN.backblazeb2.com"
    #|    }
    #|  },
    #|  "authorizationToken": "auth_token"
    #|}
  try {
    let client = Client::from_json!(
      partial_valid_json, "some-bucket-id", "some-bucket-name",
    )
    raise ClientError("expected failure, but got: \{client}")
  } catch {
    ClientError(e) =>
      assert_eq!(
        e,
        #|unable to parse Client: Object({"accountId": String("12345"), "apiInfo": Object({"storageApi": Object({"absoluteMinimumPartSize": Number(5000000), "apiUrl": String("https://apiNNN.backblazeb2.com")})}), "authorizationToken": String("auth_token")})
        ,
      )
  }
}

test "Client::from_json - random JSON input" {
  let random_json =
    #|{
    #|  "randomField": "randomValue",
    #|  "anotherRandomField": 12345
    #|}
  try {
    let client = Client::from_json!(
      random_json, "some-bucket-id", "some-bucket-name",
    )
    raise ClientError("expected failure, but got: \{client}")
  } catch {
    ClientError(e) =>
      assert_eq!(
        e,
        #|unable to parse Client: Object({"randomField": String("randomValue"), "anotherRandomField": Number(12345)})
        ,
      )
  }
}

test "Client::from_json - empty JSON input" {
  let empty_json = "{}"
  try {
    let client = Client::from_json!(
      empty_json, "some-bucket-id", "some-bucket-name",
    )
    raise ClientError("expected failure, but got: \{client}")
  } catch {
    ClientError(e) =>
      assert_eq!(
        e,
        #|unable to parse Client: Object({})
        ,
      )
  }
}

test "Client::from_json - missing required fields" {
  let missing_fields_json =
    #|{
    #|  "accountId": "12345",
    #|  "apiInfo": {},
    #|  "authorizationToken": "auth_token"
    #|}
  try {
    let client = Client::from_json!(
      missing_fields_json, "some-bucket-id", "some-bucket-name",
    )
    raise ClientError("expected failure, but got: \{client}")
  } catch {
    ClientError(e) =>
      assert_eq!(
        e,
        #|unable to parse Client: Object({"accountId": String("12345"), "apiInfo": Object({}), "authorizationToken": String("auth_token")})
        ,
      )
  }
}

test "Client::from_json - invalid JSON input" {
  let invalid_json = "invalid JSON string"
  try {
    let client = Client::from_json!(
      invalid_json, "some-bucket-id", "some-bucket-name",
    )
    raise ClientError("expected failure, but got: \{client}")
  } catch {
    ClientError(e) => assert_eq!(e, "Invalid character 'i' at line 1, column 0")
  }
}

test "Client::from_json - valid JSON input with nulls" {
  let valid_json =
    #|{
    #|  "accountId": "12345",
    #|  "apiInfo": {
    #|    "storageApi": {
    #|      "absoluteMinimumPartSize": 5000000,
    #|      "apiUrl": "https://apiNNN.backblazeb2.com",
    #|      "bucketId": null,
    #|      "bucketName": null,
    #|      "capabilities": ["deleteFiles", "readFiles"],
    #|      "downloadUrl": "https://f001.backblazeb2.com",
    #|      "infoType": "storageApi",
    #|      "namePrefix": null,
    #|      "recommendedPartSize": 100000000,
    #|      "s3ApiUrl": "https://s3.us-west-NNN.backblazeb2.com"
    #|    }
    #|  },
    #|  "authorizationToken": "auth_token",
    #|  "applicationKeyExpirationTimestamp": null
    #|}
  inspect!(
    Client::from_json!(valid_json, "some-bucket-id", "some-bucket-name"),
    content=
      #|{account_id: "12345", api_info: {storage_api: {absolute_minimum_part_size: 5000000, api_url: "https://apiNNN.backblazeb2.com", bucket_id: None, bucket_name: None, capabilities: ["deleteFiles", "readFiles"], download_url: "https://f001.backblazeb2.com", info_type: "storageApi", name_prefix: None, recommended_part_size: 100000000, s3apiurl: "https://s3.us-west-NNN.backblazeb2.com"}}, authorization_token: "auth_token", application_key_expiration_timestamp: None, bucket_id: "some-bucket-id", bucket_name: "some-bucket-name"}
    ,
  )
}
