//
//  Manga.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 23/10/2022.
//

import Foundation
import SwiftUI

//MARK: - Manga STRUCTS

struct SeasonalMangaListAntsylich: Codable {
    let id: String
    let name: String
    let manga_ids: [String]
}



struct MangaResponse: Codable{
    var  result:    String
    var  response:  String
    var  data:      [Manga]
}

struct Manga: Codable, Identifiable{
    var id: String
    var type: String
    var attributes: MangaAttributes
    var relationships: [MangaRelations]
}

struct MangaAttributes: Codable{
    var title: MangaLang
    var description: MangaLang?
    var year: Int? //Not all Manga on Manga Dex have Year Released, Causes errors if assumed. Same applies to above optionals.
    var status: String
}

struct MangaLang: Codable   {
    var en: String?
}

struct MangaRelations: Codable{
    var id: String
    var type: String
    var attributes: MangaRelationAttributes?
}

struct MangaRelationAttributes: Codable{
    var fileName: String?
}



//MARK: - Seasonal Manga Stuff

struct SeasonalResponseJSON: Codable{
    var  result:    String
    var  response:  String
    var  data:      SeasonalResponseData
}

struct SeasonalResponseData: Codable{
    var id: String
    var type: String
    var relationships: [MangaIDs]
}

struct MangaIDs:Codable{
    var id: String
}



enum MangaCallError : Error{
    case seasonalURL(String), decodedResponse(String), network(String), mangaItemsURL(String)
}


extension Manga{
    
    static  func buildSearchLink(for queryText: String) -> String {
        
        let newQueryText =  queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let apiString = "https://api.mangadex.org/manga?title=\(newQueryText!)&includedTagsMode=AND&excludedTagsMode=OR&availableTranslatedLanguage%5B%5D=en&contentRating%5B%5D=safe&contentRating%5B%5D=suggestive&contentRating%5B%5D=erotica&order%5BlatestUploadedChapter%5D=desc&includes%5B%5D=manga&includes%5B%5D=cover_art"
        
        return apiString
        
        
        
    }//Build Search For Ends Here
    
    
    
    static func getCallSeasonalMangaFromAntsylich()async throws -> String?{
        
        let url = URL(string: "https://antsylich.github.io/mangadex-seasonal/seasonal-list.json" )
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url!)
            
            let response = try JSONDecoder().decode(SeasonalMangaListAntsylich.self, from: data)
            
            var idsListString = ""
            
            for item in response.manga_ids {
                idsListString = "\(idsListString)&ids%5B%5D=\(item)"
            }
            
            print("https://api.mangadex.org/manga?includedTagsMode=AND&excludedTagsMode=OR&availableTranslatedLanguage%5B%5D=en\(idsListString)&contentRating%5B%5D=safe&contentRating%5B%5D=suggestive&contentRating%5B%5D=erotica&order%5BlatestUploadedChapter%5D=desc&includes%5B%5D=manga&includes%5B%5D=cover_art")
            
            return "https://api.mangadex.org/manga?includedTagsMode=AND&excludedTagsMode=OR&availableTranslatedLanguage%5B%5D=en\(idsListString)&contentRating%5B%5D=safe&contentRating%5B%5D=suggestive&contentRating%5B%5D=erotica&order%5BlatestUploadedChapter%5D=desc&includes%5B%5D=manga&includes%5B%5D=cover_art"
            
            
        } catch {
            print("Failed to fetch season Manga IDs: \(error)")
        }
        
        throw MangaCallError.network("You're Offline or your device has an issue") //If the function made it here then the API call failed thus why I'm throwing
    }
    
    
    static func buildSeasonalMangaCall (seasonListId: String) async throws -> String?{
        
        
        let listURL: String = "https://api.mangadex.org/list/\(seasonListId)"
        
        guard let apiurl = URL(string: listURL) else {
            print("Failure and Emotional Damage")
            throw MangaCallError.seasonalURL("The URL is wrong")
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: apiurl)
            if let decodedResponse = try? JSONDecoder().decode(SeasonalResponseJSON.self, from: data){
                let listOfIDs : [MangaIDs] = decodedResponse.data.relationships
                
                var idsListString: String = ""
                
                for item in listOfIDs{
                    idsListString = "\(idsListString)&ids%5B%5D=\(item.id)"
                }
                
                
                return "https://api.mangadex.org/manga?includedTagsMode=AND&excludedTagsMode=OR&availableTranslatedLanguage%5B%5D=en\(idsListString)&contentRating%5B%5D=safe&contentRating%5B%5D=suggestive&contentRating%5B%5D=erotica&order%5BlatestUploadedChapter%5D=desc&includes%5B%5D=manga&includes%5B%5D=cover_art"
                
                
            }   else{   throw MangaCallError.decodedResponse("SLID There was an error decoding the JSON Values")    }
            
            
        }//Do Ends Here
        
        catch {      print("There was an error getting Seasonal IDs \n \(error)")     }
        
        throw MangaCallError.network("You're Offline") //If the function made it here then the API call failed thus why I'm throwing
        
    }// func buildSeasonalMangaCall ends here
    
    
    
    
    
    
    
    static func callMangaDexAPI(for callURL: String) async throws -> [Manga]{
        
        if let apiurl = URL(string: callURL)  {
            
            do{
                let (data, _) = try await URLSession.shared.data(from: apiurl)
                if let decodedResponse = try? JSONDecoder().decode(MangaResponse.self, from: data){
                    return decodedResponse.data
                    // Done Getting Mangas
                }else{  throw MangaCallError.decodedResponse("There was an error decoding the JSON Values")    }
                
            }// Do ends here
            catch {      print("There was an error getting Manga from the IDs \n \(error)")     }
            
        }else{  throw MangaCallError.mangaItemsURL("The URL is Wrong") }
        
        throw MangaCallError.network("You're Offline")
        
    } //callMangaDexAPI ends here
    
    static func getCover(item : Manga) -> some View{
        
        var finallink = ""
        
        for relation in item.relationships{
            if relation.type == "cover_art"{
                if  let coverName = relation.attributes?.fileName{
                    finallink = "https://uploads.mangadex.org/covers/\(item.id)/\(coverName).256.jpg"
                    //    let _ =  print("\(item.attributes.title) https://uploads.mangadex.org/covers/\(item.id)/\(coverName)")
                }
            }
        }
        
        //You don't really need CachedAsyncImage. Normal AsyncImage works. It just that cacheing improves the UX
        return  CachedAsyncImage(url: URL(string: finallink) ) { phase in
            
            switch phase {
                
            case .empty:
                ProgressView().padding()
                
            case .failure(_):
                AsyncImage(url: URL(string: finallink) ) {image in
                    image.resizable()
                } placeholder: {    ProgressView().padding()  }
                
            case .success(let image):
                image.resizable()
                
            @unknown default:
                Image(systemName: "exclamationmark.icloud")
                
            }//Switch ends here
            
        }//Closure ends here
        
    }//getCover ends here
    
    static func getSearchForMangaURL(for queryText: String) async -> String{
        
        let newQueryText =  queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let apiString = "https://api.mangadex.org/manga?title=\(newQueryText!)&includedTagsMode=AND&excludedTagsMode=OR&availableTranslatedLanguage%5B%5D=en&contentRating%5B%5D=safe&contentRating%5B%5D=suggestive&contentRating%5B%5D=erotica&order%5BlatestUploadedChapter%5D=desc&includes%5B%5D=manga&includes%5B%5D=cover_art"
        
        return apiString
    } //Seatch Ends Here
    
    static func produceExampleManga() -> Manga{
        let dummyLang: MangaLang = MangaLang(en: "Please Try Again")
        
        let dummyDesc = MangaLang(en: "Either an error happened or we're still loading data")
        
        let dummyAttrubuts: MangaAttributes = MangaAttributes(title: dummyLang, description: dummyDesc,
                                                              year: 3000, status: "Very Sad")
        
        let dummyRelation = [MangaRelations]()
        
        return Manga(id: "Blah", type: "manga", attributes: dummyAttrubuts, relationships: dummyRelation)
    } //produce Example Manga Item Ends Here
    
}//Extension Ends Here




