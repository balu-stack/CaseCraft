import Foundation

struct Doctor: Identifiable, Codable, Hashable {

    // Backend column: doctor_id
    let id: String

    // Backend column: doctor_name
    let name: String

    // Backend column: doctor_phone (can be null in DB)
    let phone: String

    // Backend column: specialization (can be null in DB)
    let specialization: String

    // Backend column: is_active (1/0 or true/false)
    let active: Bool

    enum CodingKeys: String, CodingKey {
        case id = "doctor_id"
        case name = "doctor_name"
        case phone = "doctor_phone"
        case specialization
        case active = "is_active"
    }

    // if phone/specialization come null from backend, convert to ""
    init(id: String, name: String, phone: String, specialization: String, active: Bool) {
        self.id = id
        self.name = name
        self.phone = phone
        self.specialization = specialization
        self.active = active
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        phone = (try? c.decode(String.self, forKey: .phone)) ?? ""
        specialization = (try? c.decode(String.self, forKey: .specialization)) ?? ""
        active = (try? c.decode(Bool.self, forKey: .active)) ?? true
    }
}