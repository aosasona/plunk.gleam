import gleam/json

pub type PlunkError {
  /// Error returned directly from the Plunk API
  ApiError(code: Int, error: String, message: String, time: Int)

  /// Errors from the Gleam JSON library
  JSONError(json.DecodeError)
}
