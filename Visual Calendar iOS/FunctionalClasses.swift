//
//  FunctionalClasses.swift
//  Visual Calendar iOS
//
//  Created by Konstantin Kamenskiy on 03.08.2024.
//

import Foundation
import Supabase



class ServerAPIinteractor{
    var client: SupabaseClient
    var auth : AuthClient
    public var authSuccessFlag: Bool = false
    
    init(){
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
            print("User Login Success")
            print(loginResponse)
            authSuccessFlag = true
        }
        catch{
            print("an error occured")
            print(error.localizedDescription)
        }
    
        
    }
    
    func fetchEvents() async {
        if self.authSuccessFlag{
            do{
                var user = try await client.auth.user()
                var uid = user.id
                var bucketList = try await client.storage.listBuckets()
                print(bucketList)
                
                
            }
            catch{
                print("error occured")
                print(error.localizedDescription)
            }
        }
    }
}


