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
    @State var DownManga : DownloadedManga
    
    func deleteDownloadedChapter(at offsets : IndexSet){
        var allDownloads = DownloadedManga.GetDownloads()
        var DIndex = allDownloads.firstIndex(where: {$0.MangaDetail.id == DownManga.MangaDetail.id})
        
        //Delete from Storage
        offsets.sorted(by: > ).forEach { (i) in
            var chaptereDele = allDownloads[DIndex!].chapters[i]
            let name = chaptereDele.chapterName
            let pagesDele = chaptereDele.chapterPages
            print("Deleting \(name)")
            deleteDownChapters(pagesDele)
        }
        
       
        //Update JSON Data
        allDownloads[DIndex!].chapters.remove(atOffsets: offsets)
        if allDownloads[DIndex!].chapters.isEmpty{
            allDownloads.remove(at: DIndex!)
        }
        DownloadedManga.updateDownloads(with: allDownloads)
        
        //Update UI
        withAnimation{
            DownManga.chapters.remove(atOffsets: offsets)
        }
        
    }
    
    var body: some View{
        let title = DownManga.MangaDetail.attributes.title.en!
        
        List{
            ForEach(DownManga.chapters.indices, id: \.self){ i in
                let Chap = DownManga.chapters[i]
                let title = Chap.chapterName
                NavigationLink(title, destination: readDownload(chapterPages: Chap.chapterPages))
            }
            .onDelete(perform: deleteDownloadedChapter)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{   EditButton()    }
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
