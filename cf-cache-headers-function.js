function handler(event) {
  var response = event.response;
  var headers = response.headers;

  // Set the cache-control header
  headers["cache-control"] = { value: "public, max-age=31557600;" };

  // Return response to viewers
  return response;
}
