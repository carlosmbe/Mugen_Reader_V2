//
//  Chapter.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 04/11/2022.
//

import Foundation
import SwiftUI


struct ReadChapterResponse: Codable{
   var result:  String
   var baseUrl: String
   var chapter: ChapterPages
}

struct ChapterPages: Codable{
        var  hash: String
        var  data: [String]
        var  dataSaver: [String]
}


struct ChapterFeedResponse: Codable{
    var  result:    String
    var  response:  String
    var  data: [FeedChapter]
}

struct FeedChapter: Codable, Identifiable{
    var id: String
    var attributes: ChapterDetails
}

struct ChapterDetails: Codable{
    var volume   :    String?
    var chapter  :    String?
    var title    :    String?
}



enum FeedChapterErrors: Error{
    case badURL, decodingError, unknownError
}

extension FeedChapter{
    
    static func buildChapterNameView(_ chapter: FeedChapter) -> some View {
        
        VStack(alignment: .leading) {
            Text(chapter.attributes.chapter.map { "Chapter \($0)" } ?? "")
            Text(chapter.attributes.title?.isEmpty == false ? chapter.attributes.title! : "")
                .padding(.leading, chapter.attributes.title?.isEmpty == true ? 0 : 10)
        }
    }

    
    static func getMangaChapterFeed(for mangaID : String) async throws -> [FeedChapter] {
        let rawURL: String = "https://api.mangadex.org/manga/\(mangaID)/feed?limit=500&translatedLanguage%5B%5D=en&contentRating%5B%5D=safe&contentRating%5B%5D=suggestive&contentRating%5B%5D=erotica&contentRating%5B%5D=pornographic&includeFutureUpdates=1&order%5BcreatedAt%5D=asc&order%5BupdatedAt%5D=asc&order%5BpublishAt%5D=asc&order%5BreadableAt%5D=asc&order%5Bvolume%5D=asc&order%5Bchapter%5D=asc"
        
        guard let apiurl = URL(string: rawURL) else {
            print("Failure and Emotional Damage")
            throw FeedChapterErrors.badURL
        }
        do{
            let (data, _) = try await URLSession.shared.data(from: apiurl)
            
            if let decodedResponse = try? JSONDecoder().decode(ChapterFeedResponse.self, from: data){
                return decodedResponse.data
            }else{
                throw FeedChapterErrors.decodingError
            }
            
        } catch{
            throw FeedChapterErrors.unknownError
        }
        throw FeedChapterErrors.unknownError
    }// Func Ends Here
    
    
    static func getChapterPageImageURLs(chapterID : String) async throws -> [String]{
        if let decodedResponse = try? await FeedChapter.getReadingChapterURLS(chapterID: chapterID){
            var baseUrl = decodedResponse.baseUrl
            var pages = decodedResponse.chapter.dataSaver
            var chapterHash = decodedResponse.chapter.hash
    
            var chapterPages = [String]()
            
            for page in pages{
                let finalLink = ("\(baseUrl)/data-saver/\(chapterHash)/\(page)")
                chapterPages.append(finalLink)
            }
            return chapterPages
        }
        throw FeedChapterErrors.unknownError
    }
    
    static func getReadingChapterURLS(chapterID : String) async throws -> ReadChapterResponse{
        
        print("Started getting pages")
        
        let getReadChaptersURL = ("https://api.mangadex.org/at-home/server/\(chapterID)")
        print(getReadChaptersURL)
        
        guard let callURL = URL(string: getReadChaptersURL) else{
            print("We had an error with the URL, rare, but it happens")
            throw FeedChapterErrors.badURL
        }
        
        do{
            let (data,_) = try await URLSession.shared.data(from: callURL)
          
            if let decodedResponse = try? JSONDecoder().decode(ReadChapterResponse.self, from: data){
              return decodedResponse
             
            }else{
                print("Read Chapter if let failed")
                throw FeedChapterErrors.decodingError
            }
            
        }catch{
            print("OMG, the api call failed. BIG SAD #getReadingChapterURLS")
            throw FeedChapterErrors.unknownError
        }
        throw FeedChapterErrors.unknownError
    }//End Of Func
    
}

