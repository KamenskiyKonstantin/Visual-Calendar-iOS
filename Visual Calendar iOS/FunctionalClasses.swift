//
//  FunctionalClasses.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 03.08.2024.
//

import Foundation
import Supabase
import SwiftyJSON



struct CalendarJSON: Codable {
    let events: [EventJSON]
    let uid: String
}


struct EventJSON: Codable {
    let timeStart, timeEnd: [Int]
    let systemImage, mainImageURL: String
    let sideImageURLS: [String]
    let color: String
    
    func convertToEvent() -> Event
    {
        return Event(systemImage: systemImage,
        color: color,
        dateTimeStart: dateFrom(timeStart[0], timeStart[1], timeStart[2], timeStart[3], timeStart[4]),
        dateTimeEnd: dateFrom(timeEnd[0], timeEnd[1], timeEnd[2], timeEnd[3], timeEnd[4]),
        minuteHeight: 2,
        mainImageURL: mainImageURL,
        sideImagesURL:  sideImageURLS)
    }
}



class ServerAPIinteractor{
    var client: SupabaseClient
    var auth : AuthClient
    public var authSuccessFlag: Bool = false
    
    init() {
        client = SupabaseClient(supabaseURL: URL(string: "https://wlviarpvbxdaoytfeqnm.supabase.co")!,
                                supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndsdmlhcnB2YnhkYW95dGZlcW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIxNTk0MzksImV4cCI6MjAzNzczNTQzOX0.zoQJTA3Tu_fpe24BrxDjhMtlfxfd_3Nx8TM1t8V3PK0")
        auth = client.auth
    }
    
    func signUp(email:String, password:String) async{
        
        do{
            let signUpResponse = try await auth.signUp(
            email: email,
            password: password)
            print(signUpResponse)
        }
        catch{
            print("an error occured")
            print(error.localizedDescription)
        }
        
    }
    
    func login(email: String, password:String) async{
        
        do{
            let loginResponse = try await auth.signIn(
            email: email,
            password: password)
//            print("User Login Success")
//            print(loginResponse)
            authSuccessFlag = true
        }
        catch{
            print("an error occured")
            print(error.localizedDescription)
        }
    
        
    }
    
    func fetchEvents() async -> [Event]{
        if self.authSuccessFlag{
            do{
                var user = try await client.auth.user()
                var uid = user.id
                var result = try await client.storage.from("user_data").list()
                var bucketList = try await client.storage.listBuckets()
                print(bucketList, result)
                var hasUserFolder = false
                
                for fileItem in result{
                    if fileItem.name == uid.uuidString{
                        hasUserFolder = true
                    }
                }
                
                if !hasUserFolder{
                    let starterJson : [String: Any] = [
                        "uid": uid.uuidString,
                        "events": []
                    ]
                    let json = try JSONSerialization.data(withJSONObject: starterJson, options: .prettyPrinted)
                    try await client.storage.from("user_data").upload(path: uid.uuidString+"/calendar.json", file:json)
                    try await client.storage.from("user_data").upload(path: uid.uuidString+"/images/welcome.txt", file:json)

                }
                var userCalendar = try await client.storage.from("user_data").download(path: uid.uuidString+"/calendar.json")
                let calendar = try JSONDecoder().decode(CalendarJSON.self, from: userCalendar)
                var eventList: [Event] = []
                for event in calendar.events{
                    eventList.append(event.convertToEvent())
                }
                return eventList
                
                
            }
            catch{
                print("error occured")
                print(error.localizedDescription)
                return []
            }
        }
        else{
            return []
        }
    }
}


