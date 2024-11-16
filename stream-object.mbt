/// `stream_object` performs a GET to retrieve the b2 object, streams it to
/// its https `response_out`, and optionally returns the object's hash using the
/// provided HashFunc.
pub fn stream_object(
  self : Client,
  filename : String,
  response_out : @types.ResponseOutparam,
  hash~ : @common.HashFunc?,
  debug~ : Bool = false
) -> String!ClientError {
  let download_url = self.api_info.storage_api.download_url
  if not(download_url.starts_with("https://")) {
    raise ClientError("url '\{download_url}' does not start with https://")
  }
  //
  let bucket_name = self.bucket_name
  let api_url = "\{download_url}/file/\{bucket_name}/\{filename}"
  let fields = [
    ("Content-Type", b"application/octet-stream"),
    ("Authorization", @base64.str2bytes(self.authorization_token)),
  ]
  let req = @util.new_request(@types.Get, api_url, fields~)
  //
  match @util.stream(req, response_out, hash, debug~) {
    Ok((_byte_count, hash)) => hash
    Err(e) => raise ClientError(e.to_string())
  }
}
