import gleam/json

pub type PlunkError {
  /// Error returned directly from the Plunk API
  ApiError(code: Int, error: String, message: String, time: Int)

  /// Errors from this library itself
  /// If you ever see this, please investigate and report it as a bug
  LibraryError(message: String, cause: String)

  /// Errors from the Gleam JSON library
  JSONError(json.DecodeError)
}
