import Foundation

final class ClinicSession {
    static let shared = ClinicSession()
    private init() {}

    var clinicId: String = ""
}