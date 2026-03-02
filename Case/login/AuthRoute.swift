import Foundation

enum AuthRoute: Hashable {
    case forgotPassword
    case resetPassword(email: String)
}