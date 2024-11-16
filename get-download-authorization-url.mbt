/// `get_download_authorization_url` returns a URL that can be used in an
/// https GET call to download any files in a bucket with the given `file_name_prefix`.
/// Note that if `file_name_prefix` needs to be escaped for suitability within a query parameter,
/// you must do that first before calling this function.
pub fn get_download_authorization_url(
  self : Client,
  file_name_prefix : String,
  valid_duration_in_seconds~ : Int = 604800, // maximum = 1 week
  debug~ : Bool = false
) -> String!ClientError {
  let api_url = self.api_info.storage_api.api_url
  if not(api_url.starts_with("https://")) {
    raise ClientError("url '\{api_url}' does not start with https://")
  }
  let download_url = self.api_info.storage_api.download_url
  if not(download_url.starts_with("https://")) {
    raise ClientError("url '\{download_url}' does not start with https://")
  }
  let bucket_id = self.bucket_id
  //
  let url = "\{api_url}/b2api/v3/b2_get_download_authorization?bucketId=\{bucket_id}&fileNamePrefix=\{file_name_prefix}&validDurationInSeconds=\{valid_duration_in_seconds}"
  let fields = [
    ("Content-Type", b"application/json"),
    ("Authorization", @base64.str2bytes(self.authorization_token)),
  ]
  let req = @util.new_request(@types.Get, url, fields~)
  let body = match @util.send_request(req, debug~) {
    Ok(body) => @base64.bytes2str(body)
    Err(e) => raise ClientError(e.to_string())
  }
  gen_url!(body, download_url, self.bucket_name, file_name_prefix)
}

fn gen_url(
  body : String,
  download_url : String,
  bucket_name : String,
  file_name_prefix : String
) -> String!ClientError {
  let json = match @json.parse?(body) {
    Ok(json) => json
    Err(e) => raise ClientError(e.to_string())
  }
  let authorization_token = match json {
    Object({ "authorizationToken": String(token) }) => token
    _ => raise ClientError("missing authorizationToken in response: \{body}")
  }
  //
  let url = "\{download_url}/file/\{bucket_name}/\{file_name_prefix}?Authorization=\{authorization_token}"
  url
}

test "gen_url generates valid URL" {
  let body =
    #|{"authorizationToken":"a-b-c-1-2-3"}
  let download_url = "https://f123.example.com"
  let bucket_name = "some-bucket-name"
  let file_name_prefix = "some-file-name-prefix"
  let got = gen_url!(body, download_url, bucket_name, file_name_prefix)
  let want =
    #|https://f123.example.com/file/some-bucket-name/some-file-name-prefix?Authorization=a-b-c-1-2-3
  assert_eq!(got, want)
}
