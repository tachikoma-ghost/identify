import Blob "mo:core/Blob";
import Text "mo:core/Text";
import Debug "mo:core/Debug";
import Error "mo:core/Error";
import Option "mo:core/Option";
import Runtime "mo:core/Runtime";
import { ic } "mo:ic";
import Call "mo:ic/Call";
import IC "mo:ic/Types";
import RSA "RSA";

module {
  type Timestamp = Nat64;

  public func transformKeys({ context; response } : TransformArgs) : IC.HttpRequestResult {
    ignore context;
    let ?content = Text.decodeUtf8(response.body) else Runtime.trap("Invalid response body");

    let keys = switch (RSA.pubKeysFromJSON(content)) {
      case (#err err) Runtime.trap("Http transformBody failes: " # err);
      case (#ok data) data;
    };

    Debug.print("parsed keys from: " # content);

    let body = RSA.serializeKeys(keys);
    Debug.print("parsed keys to:   " # body);

    return {
      status = response.status;
      body = Text.encodeUtf8(body);
      headers = [];
    };
  };

  public func transform({ context; response } : TransformArgs) : IC.HttpRequestResult {
    ignore context;
    return { response with headers = [] };
  };

  public type TransformArgs = {
    context : Blob;
    response : IC.HttpRequestResult;
  };
  public type TransformResult = IC.HttpRequestResult;
  public type TransformFn = shared query TransformArgs -> async TransformResult;

  public type Request = IC.HttpRequestArgs;

  public func getRequest(url : Text, headers : [Header], maxBytes : Nat64, transform : TransformFn, replicated : Bool) : async* {
    data : Text;
  } {
    let http_request : Request = {
      url = url;
      max_response_bytes = ?maxBytes;
      headers;
      body = null;
      method = #get;
      transform = ?{ function = transform; context = Blob.fromArray([]) };
      is_replicated = ?replicated;
    };

    try {
      let http_response = await Call.httpRequest(http_request);
      return { data = decodeBody(http_response.body) };
    } catch (err) {
      Runtime.trap("http outcall error: " # Error.message(err));
    };
  };

  public type Header = IC.HttpHeader; // {name: Text; value: Text}

  /// Perform a post request
  /// WARNING!: The post request is not replicated, and therefore could be manipulated by the node provider!
  public func postRequest(url : Text, body : ?Text, headers : [Header], maxBytes : Nat64, transform : TransformFn) : async* {
    data : Text;
    statusCode : Nat;
  } {
    let http_request : Request = {
      url = url;
      max_response_bytes = ?maxBytes;
      headers;
      body = Option.map(body, Text.encodeUtf8);
      method = #post;
      transform = ?{ function = transform; context = Blob.fromArray([]) };
      is_replicated = ?false;
    };

    try {
      let http_response = await Call.httpRequest(http_request);
      return { data = decodeBody(http_response.body); statusCode = http_response.status };
    } catch (err) {
      Runtime.trap("http outcall error: " # Error.message(err));
    };
  };

  func decodeBody(body : Blob) : Text {
    switch (Text.decodeUtf8(body)) {
      case (null) "No value returned";
      case (?y) y;
    };
  };

};
