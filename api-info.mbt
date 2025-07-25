///|
/// `APIInfo` represents Backblaze B2 Native API info.
/// It is a data structure that groups the information you need by API suite.
priv struct APIInfo {
  // GroupsAPI - not needed - used for the Partner API.
  // See: https://www.backblaze.com/apidocs/b2-authorize-account
  storage_api : StorageAPI // `json:"storageApi"`
} derive(Show)

///|
fn APIInfo::from_json(map : Map[String, Json]) -> APIInfo raise ClientError {
  match map {
    { "storageApi": Object(storage_api), .. } => {
      let storage_api = StorageAPI::from_json(storage_api)
      { storage_api, }
    }
    _ => raise ClientError("unable to parse APIInfo: \{map}")
  }
}

///|
/// `StorageAPI` represents Backblaze B2 Native Storage API info.
priv struct StorageAPI {
  /// The smallest possible size of a part of a large file (except the last one). This is smaller than the recommendedPartSize. If you use it, you may find that it takes longer overall to upload a large file.
  ///
  /// EXAMPLE
  /// 5000000
  absolute_minimum_part_size : Int // `json:"absoluteMinimumPartSize"`
  /// The base URL to use for all API calls except for uploading and downloading files.
  ///
  /// EXAMPLE
  /// https://apiNNN.backblazeb2.com
  api_url : String // `json:"apiUrl"`
  /// When present,access is restricted to one bucket.
  ///
  /// EXAMPLE
  /// BUCKET_ID
  bucket_id : String? // `json:"bucketId"`
  /// When bucketId is set, and it is a valid bucket that has not been deleted, this field is set to the name of the bucket. It's possible that bucketId is set to a bucket that no longer exists, in which case this field will be null. It's also null when bucketId is null.
  ///
  /// EXAMPLE
  /// myBucketName
  bucket_name : String? // `json:"bucketName"`
  /// A list of strings, each one naming a capability the key has.
  ///
  /// VALID VALUES
  /// [ "deleteFiles", "deleteKeys", "readBucketEncryption", "writeKeys", "writeBuckets", "writeBucketNotifications", "writeBucketReplications", "readBucketNotifications", "readBucketReplications", "deleteBuckets", "readBuckets", "bypassGovernance", "readFileLegalHolds", "readFiles", "listAllBucketNames", "readBucketRetentions", "writeBucketRetentions", "writeFileLegalHolds", "shareFiles", "writeFiles", "listKeys", "listBuckets", "listFiles", "writeFileRetentions", "writeBucketEncryption", "readFileRetentions" ]
  capabilities : Array[String] // `json:"capabilities"`
  /// The base URL to use for downloading files.
  ///
  /// EXAMPLE
  /// https://f001.backblazeb2.com
  download_url : String // `json:"downloadUrl"`
  /// The API type that the information in the object corresponds to.
  ///
  /// EXAMPLE
  /// storageApi
  info_type : String // `json:"infoType"`
  /// When present, access is restricted to files whose names start with the prefix
  ///
  /// EXAMPLE
  /// myFilePrefix
  name_prefix : String? // `json:"namePrefix"`
  /// The recommended file part size.
  ///
  /// EXAMPLE
  /// 100000000
  recommended_part_size : Int // `json:"recommendedPartSize"`
  /// The base URL to use for all API calls using the S3 compatible API.
  ///
  /// EXAMPLE
  /// https://s3.us-west-NNN.backblazeb2.com
  s3apiurl : String // `json:"s3ApiUrl"`
} derive(Show)

///|
fn StorageAPI::from_json(
  map : Map[String, Json],
) -> StorageAPI raise ClientError {
  match map {
    {
      "absoluteMinimumPartSize": Number(absolute_minimum_part_size, ..),
      "apiUrl": String(api_url),
      "bucketId": bucket_id,
      "bucketName": bucket_name,
      "capabilities": Array(capabilities_arr),
      "downloadUrl": String(download_url),
      "infoType": String(info_type),
      "namePrefix": name_prefix,
      "recommendedPartSize": Number(recommended_part_size, ..),
      "s3ApiUrl": String(s3apiurl),
      ..
    } => {
      let absolute_minimum_part_size = absolute_minimum_part_size.to_int()
      let bucket_id = match bucket_id {
        String(v) => Some(v)
        _ => None
      }
      let bucket_name = match bucket_name {
        String(v) => Some(v)
        _ => None
      }
      let name_prefix = match name_prefix {
        String(v) => Some(v)
        _ => None
      }
      let capabilities = Array::new(capacity=capabilities_arr.length())
      for s in capabilities_arr {
        match s {
          String(s) => capabilities.push(s)
          s => raise ClientError("unexpected capabilities field: \{s}")
        }
      }
      let recommended_part_size = recommended_part_size.to_int()
      {
        absolute_minimum_part_size,
        api_url,
        bucket_id,
        bucket_name,
        capabilities,
        download_url,
        info_type,
        name_prefix,
        recommended_part_size,
        s3apiurl,
      }
    }
    _ => raise ClientError("unable to parse StorageAPI: \{map}")
  }
}

// Transaction Class A - Costs: Free
//
//	b2_cancel_large_file
//	b2_delete_bucket
//	b2_delete_file_version
//	b2_delete_key
//	b2_finish_large_file
//	b2_get_upload_part_url
//	b2_get_upload_url
//	b2_hide_file
//	b2_start_large_file
//	b2_update_file_legal_hold
//	b2_update_file_retention
//	b2_upload_file
//	b2_upload_part
//
// Transactions Class B - Cost: The first 2,500 of these calls are free each day, then $0.004 per 10,000
//
//	b2_download_file_by_id
//	b2_download_file_by_name
//	b2_get_file_info
//
// Transactions Class C - Cost: The first 2,500 of these calls are free each day, then $0.004 per 1,000
//
//	b2_authorize_account
//	b2_copy_file
//	b2_copy_part
//	b2_create_bucket
//	b2_create_key
//	b2_get_download_authorization
//	b2_list_buckets
//	b2_list_file_names
//	b2_list_file_versions
//	b2_list_keys
//	b2_list_parts
//	b2_list_unfinished_large_files
//	b2_update_bucket
