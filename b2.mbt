let api_base_url = "https://api.backblazeb2.com"

pub type! ClientError String

/// `Client::new` returns a new client to communicate with the b2 (Backblaze) API
/// for the provided `bucket_name`.
pub fn Client::new(
  key_id : String,
  key_secret : String,
  bucket_name : String
) -> Client!ClientError {
  let input = @base64.str2bytes("\{key_id}:\{key_secret}")
  let basic_auth = @base64.std_encode2str(FixedArray::from_iter(input.iter()))
  let url = "\{api_base_url}/b2api/v3/b2_authorize_account"
  let fields = [
    ("Content-Type", b"application/json"),
    ("Authorization", @base64.str2bytes("Basic \{basic_auth}")),
  ]
  let req = @util.new_request(@types.Get, url, ~fields)
  let body = match @util.send_request(req) {
    Ok(body) => @base64.bytes2str(body)
    Err(e) => raise ClientError("request failed with error code: \{e}")
  }

  //
  Client::from_json!(body, bucket_name)
}
