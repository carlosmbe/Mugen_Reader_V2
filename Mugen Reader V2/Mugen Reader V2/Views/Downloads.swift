//
//  Downloads.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 01/12/2022.
//

import SwiftUI

struct Downloads: View {
    
    @State private var downloadsJSON = DownloadedManga.GetDownloads()
    var body: some View {
        Text("\(downloadsJSON.count)")
        Button("Refresh"){
            downloadsJSON = DownloadedManga.GetDownloads()
        }
        
        List(downloadsJSON.indices, id: \.self) { manga in
            let title = downloadsJSON[manga].MangaDetail.attributes.title.en!
            NavigationLink(title, destination: chooseChapter(DownManga: downloadsJSON[manga] )   )
        }
    }
}

struct chooseChapter : View{
    var DownManga : DownloadedManga
    
    var body: some View{
        List(DownManga.chapters.indices, id: \.self){ i in
            let Chap = DownManga.chapters[i]
            let title = Chap.chapterName
            NavigationLink(title, destination: readDownload(chapterPages: Chap.chapterPages))
            
        }
    }
    
}


struct readDownload : View{
    
    var chapterPages: [String]
    
    var body: some View{
        ScrollView {
            VStack{
                let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                ForEach(chapterPages, id:\.self){ pageLink in
                    
                    let fileName = URL(string: pageLink)!.lastPathComponent
                    let fileURL = documents.appendingPathComponent(fileName)
                    
                    let imageData = try!  Data(contentsOf: fileURL)
                    
                    Image(uiImage: UIImage(data: imageData)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                }
            }
            
            
        }
    }
    
    struct Downloads_Previews: PreviewProvider {
        static var previews: some View {
            Downloads()
        }
    }
