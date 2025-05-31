//
//  FunctionalClasses.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 03.08.2024.
//

import Foundation
import Supabase
import SwiftyJSON
import Combine

struct CalendarJSON: Codable {
    let events: [EventJSON]
    let uid: String
}

struct EventJSON: Codable {
    let timeStart, timeEnd: [Int]
    let systemImage: String
    let backgroundColor: String
    let textColor: String
    let mainImageURL: String
    let sideImageURLS: [String]
    let id: UUID

    func toEvent() -> Event {
        return Event(
            systemImage: systemImage,
            dateTimeStart: Date.from(day: timeStart[0], month: timeStart[1], year: timeStart[2], hour: timeStart[3], minute: timeStart[4]),
            dateTimeEnd: Date.from(day: timeEnd[0], month: timeEnd[1], year: timeEnd[2], hour: timeEnd[3], minute: timeEnd[4]),
            minuteHeight: 2,
            mainImageURL: mainImageURL,
            sideImagesURL: sideImageURLS,
            id: id,
            bgcolor: backgroundColor,
            textcolor: textColor
            
        )
    }
}


@MainActor
class APIHandler: ObservableObject {
    private let client: SupabaseClient
    private var auth: AuthClient { client.auth }

    @Published private(set) var eventList: [Event] = []
    @Published private(set) var images: [String:[String: String]] = [:]

    init(eventList: [Event] = []) {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://wlviarpvbxdaoytfeqnm.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsdmlhcnB2YnhkYW95dGZlcW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIxNTk0MzksImV4cCI6MjAzNzczNTQzOX0.zoQJTA3Tu_fpe24BrxDjhMtlfxfd_3Nx8TM1t8V3PK0"
        )
        self.eventList = eventList
    }

    var isAuthenticated: Bool {
        auth.currentUser != nil
    }

    func signUp(email: String, password: String) async throws {
        let response = try await auth.signUp(email: email, password: password)
        print("SignUp: \(response)")
    }

    func login(email: String, password: String) async throws {
        _ = try await auth.signIn(email: email, password: password)
    }

    func logout() async throws {
        try await auth.signOut()
    }
    

    func fetchEvents() async throws {
        print("=============== Fetching Events ===================")
        guard let uid = try? await auth.user().id else { return }

        let userFolderExists = try await client.storage.from("user_data").list()
            .contains(where: { $0.name == uid.uuidString })

        if !userFolderExists {
            try await createInitialUserData(uid: uid)
        }

        let data = try await client.storage.from("user_data").download(path: "\(uid.uuidString)/calendar.json")
        let calendar = try JSONDecoder().decode(CalendarJSON.self, from: data)
        
        DispatchQueue.main.async {
                self.eventList = calendar.events.map { $0.toEvent() }
                for event in self.eventList {
                    print(event.getString())
                }
                print("===================================================")
            }
        
        }

    
    func fetchImageURLs() async throws {
        let uid = try await client.auth.user().id
        let imageList = try await client.storage.from("user_data").list(path: "\(uid.uuidString)/images")

        var urls: [String: String] = [:]

        for image in imageList {

            let url = try client.storage.from("user_data")
                .getPublicURL(path: "\(uid.uuidString)/images/\(image.name)")

            let key = image.name.components(separatedBy: ".").first ?? image.name
            urls[key] = url.absoluteString
        }
        let result: [String:[String:String]] = ["User":urls]

        DispatchQueue.main.async {
            self.images = result
        }
    }
    
    private func createInitialUserData(uid: UUID) async throws {
        let starter: CalendarJSON = .init(events: [], uid: uid.uuidString)
        let jsonData = try JSONEncoder().encode(starter)

        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/calendar.json",
            file: jsonData,
            options: .init(cacheControl: "0", contentType: "application/json", upsert: true)
        )

        try await client.storage.from("user_data").upload(
            path: "\(uid.uuidString)/images/welcome.txt",
            file: Data(),
            options: .init(cacheControl: "0", contentType: "text/plain", upsert: true)
        )
        
        // remove welcome
        let _ = try await client.storage.from("user_data").remove(paths: ["\(uid.uuidString)/images/welcome.txt"])
    }
    
    // UPDATE
    func upsertImage(imageData: Data, filename: String) async throws {
        let user = try await client.auth.user()
        let uid = user.id.uuidString
        
        let path = "\(uid)/images/\(filename)"
        
        do {
            try await client.storage.from("user_data").upload(
                path: path,
                file: imageData,
                options: FileOptions(
                cacheControl: "0",
                contentType: "image/png",
                upsert: true
                )
            )
            
        }
    
    }
    func upsertEvents(_ events: [Event]) async throws {
        let user = try await client.auth.user()
        let uid = user.id.uuidString
        
        let eventDictionaries: [[String: Any]] = events.map { $0.getDictionary() }
        let payload: [String: Any] = [
            "uid": uid,
            "events": eventDictionaries
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
        print("upserting events: \(String(data: jsonData, encoding: .utf8) ?? "")")
        // Upload to Supabase
        do{
            try await client.storage.from("user_data").upload(
                path: "\(uid)/calendar.json",
                file: jsonData,
                options: FileOptions(
                    cacheControl: "0",
                    contentType: "application/json",
                    upsert: true
                )
            )
            self.eventList = events
        }
        catch {
            print("Error uploading calendar.json: \(error)")
        }
        
        
        
    }
}
