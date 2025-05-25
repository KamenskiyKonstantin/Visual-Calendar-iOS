//
//  FunctionalClasses.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 03.08.2024.
//

import Foundation
import Supabase
import SwiftyJSON


func dateFrom(_ day: Int, _ month: Int, _ year: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    return calendar.date(from: dateComponents) ?? .now
}

func getWeekStartDate(_ date: Date) -> Date {
    let calendar = Calendar.current
    let weekStartDate = calendar.startOfDay(for: date.addingTimeInterval(-date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 604800)))
    let localeWeightedDay = weekStartDate.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT()))
    return localeWeightedDay
}

func DateToIntList(date: Date) -> [Int]{
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: date)
    let day = components.day
    let month = components.month
    let year = components.year
    let hour = components.hour
    let minute = components.minute
    return [day!, month!, year!, hour!, minute!]
}


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
    
    public var eventList: [Event] = []
    public var images: [String:String] = [:]
    
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
            let _ = try await auth.signIn(
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
    
    func logout() async{
        do{
            try await auth.signOut()
            authSuccessFlag = false
        }
        catch{
            print("an error occured")
            print(error.localizedDescription)
        }
    }
    
    func fetchEvents() async {
        if self.authSuccessFlag{
            do{
                let user = try await client.auth.user()
                let uid = user.id
                let result = try await client.storage.from("user_data").list()
                let bucketList = try await client.storage.listBuckets()
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
                    try await client.storage.from("user_data").upload(path: uid.uuidString+"/calendar.json", file:json, options: FileOptions(
                        cacheControl: "0",
                        contentType: "application/json",
                        upsert: true
                    ))
                    try await client.storage.from("user_data").upload(path: uid.uuidString+"/images/welcome.txt", file:json,
                                                                      options: FileOptions(
                                                                          cacheControl: "0",
                                                                          contentType: "application/json",
                                                                          upsert: true
                                                                      ))

                }
                let userCalendar = try await client.storage.from("user_data").download(path: uid.uuidString+"/calendar.json")
                let calendar = try JSONDecoder().decode(CalendarJSON.self, from: userCalendar)
                var eventList: [Event] = []
                for event in calendar.events{
                    eventList.append(event.convertToEvent())
                }
                self.eventList = eventList
                
                
            }
            catch{
                print("error occured")
                print(error.localizedDescription)
                return
            }
        }
        else{
            return
        }
    }
    
    func upsertImage(image:Data, filename: String) async
    
    {
        do{
            let uid = try await client.auth.user().id
            try await client.storage.from("user_data").upload(path: uid.uuidString+"/images/"+filename, file: image, options: FileOptions(
                cacheControl: "0",
                contentType: "image/png",
                upsert: true
            ))
            print("uploaded")
        }
        catch{
            print(error.localizedDescription)
        }
    }
    //
    func fetchImageURLS() async {
        var imageURLS: [String:String] = [:]
        do{
            let uid = try await client.auth.user().id
            let imageList = try await client.storage.from("user_data").list(path: uid.uuidString+"/images")
           
            
            for image in imageList{
                print(image.name)
                let url = try client.storage.from("user_data").getPublicURL(path:  uid.uuidString+"/images/"+image.name)
                imageURLS[String(image.name.split(separator: ".").first!)] = url.absoluteString
                
            }
            
            
        }
    
        catch{
            print(error.localizedDescription)
        }
        self.images.removeAll()
        self.images = imageURLS
    }
    
    func upsertEvents(events: [[String:Any]]){
        Task{
            let uid = try await client.auth.user().id
            let jsonData: [String:Any] =
            [
                "uid":uid.uuidString,
                "events":events
            ]
            print(jsonData, JSONSerialization.isValidJSONObject(jsonData))
            let json = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            try await client.storage.from("user_data").upload(path: uid.uuidString+"/calendar.json", file:json, options: FileOptions(
                cacheControl: "0",
                contentType: "application/json",
                upsert: true
            ))
        }
    }
}


