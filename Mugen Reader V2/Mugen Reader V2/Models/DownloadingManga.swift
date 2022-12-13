//
//  DownloadingManga.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 13/12/2022.
//

import Foundation

struct DownloadedManga : Codable{
    let MangaDetail : Manga
    var chapters : [downloadedChapter]
}


struct downloadedChapter : Codable, Equatable{
    let chapterName : String
    let chapterID : String
    var chapterPages: [String]
}

func downloadAndStoreImage(url: String) {
    
    let imageUrl = URL(string: url)!

    let imageData = try! Data(contentsOf: imageUrl)

    let fileName = imageUrl.lastPathComponent
    
    let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    let fileURL = documents.appendingPathComponent(fileName)
    
    try! imageData.write(to: fileURL)
}

extension DownloadedManga{
    
    static func downloadChapter(manga: Manga, chapterID: String, chapterName: String) async{
         if let decodedResponse = try? await FeedChapter.getChapterPageImageURLs(chapterID: chapterID){
             var finalPageLinks = decodedResponse
             
             let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
             var finalUrlArr = [String]()
             for urlString in finalPageLinks{
                 downloadAndStoreImage(url: urlString)
                 let fileName = URL(string: urlString)!.lastPathComponent
                 let fileURL = documents.appendingPathComponent(fileName)
                 finalUrlArr.append("\(fileURL)")
             }//For Ends Here
             
             var downs = [downloadedChapter]()
             let downloadedChapter = downloadedChapter(chapterName: chapterName, chapterID: chapterID, chapterPages: finalPageLinks)
             downs.append(downloadedChapter)
             let newDownload = DownloadedManga(MangaDetail: manga, chapters: downs)
             appendDownloadedChapters(newDownload)
             
             
         }else{
             print("If let failed when Downloading = getting page links. Most likely chapter id fault")
         }
     }
    
    static func GetDownloads() -> [DownloadedManga]{
        do{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileURL = paths[0].appendingPathComponent("DownloadedChapters.json")
  
                let dataInitLastRead = try Data(contentsOf: fileURL)
                let dataArray = try JSONDecoder().decode([DownloadedManga].self, from: dataInitLastRead)
                return dataArray
            
           
        }catch{
            print("Computed Var Failed Init \nError is \(error.localizedDescription)")
            return []
        }
    }
    
    static func appendDownloadedChapters(_ downMan : DownloadedManga){
        var downloadedManga = GetDownloads()
        
        if let sameManga = downloadedManga.firstIndex(where: {$0.MangaDetail.id == downMan.MangaDetail.id}){
            downloadedManga[sameManga].chapters.append(downMan.chapters.last!)
        }else{
            downloadedManga.append(downMan)
        }
        
        updateDownloads(with: downloadedManga)
    }
    
    static func updateDownloads(with newDownload : [DownloadedManga]){
        
        do{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileURL = paths[0].appendingPathComponent("DownloadedChapters.json")
         
            try JSONEncoder().encode(newDownload).write(to: fileURL)
            print("FInshed Encoding")
            
            let jsonData = try Data(contentsOf: fileURL)
            let finalData = try JSONDecoder().decode([DownloadedManga].self, from: jsonData)
            print("Fianl Data is \(finalData)")
        }catch{
            print(error)
        }
        
    }

}
