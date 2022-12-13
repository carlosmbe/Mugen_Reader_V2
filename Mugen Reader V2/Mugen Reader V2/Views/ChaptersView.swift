//
//  ChaptersView.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 04/11/2022.
//

import SwiftUI

struct ChaptersView: View {
    
    let chosenManga: Manga
    
    @State private var chapterResults = [FeedChapter]()
    var animateGetChapters : [FeedChapter]{
        get{chapterResults}
        set{chapterResults = newValue }
    }
    
    var ChaptersList : some View{
        List(chapterResults) { item in
            HStack{
                NavigationLink(
                    destination: ReadingView(viewChapterID: item.id)
                        .onAppear{
                            let currentLastRead = LastReadChapter(id: chosenManga.id, MangaDetail: chosenManga, Chapter: item)
                            appendToLastReadChapters(currentLastRead)
                        },
                    label: {
                        FeedChapter.buildChapterNameView(item)
                    }) .id(item.id) //.id for allowing jump scrolling
                //Nav Link Ends Here
                    .contextMenu {
                          Button("Download"){
                              Task{
                                  await DownloadedManga.downloadChapter(manga:chosenManga, chapterID: item.id, chapterName: item.attributes.title!)
                              }
                          }
                    }
            
            }//HStack Ends Here
            
        }
        .navigationTitle(chosenManga.attributes.title.en ?? "No English Title")
        .navigationBarTitleDisplayMode(.inline)
        .task {
                await getChapterResults()
        }
    }
    
    var body: some View {
        
        if let index = getLastReadID(){
            ScrollViewReader { proxy in
                ChaptersList
                    .toolbar{
                        Button("Continue") {
                            withAnimation{
                                proxy.scrollTo(index, anchor: .top)
                            }
                        }
                    }
            }
        }else{
            ChaptersList
        }
  
    }//body ends here
    
    func getLastReadID() -> String?{
        let lastReadChapters = GetLastRead()
        if let sameManga = lastReadChapters.firstIndex(where: {$0.id == chosenManga.id}){
            guard let finalIndex = chapterResults.firstIndex(where: {$0.id == lastReadChapters[sameManga].Chapter.id}) else { return nil }
            return chapterResults[finalIndex].id
        }else{
            return nil
        }
        
    }
    
    func getChapterResults() async{
        do{
            var apiChapterResults = try await FeedChapter.getMangaChapterFeed(for: chosenManga.id)
            apiChapterResults.sort{
                guard let titleNum0 = $0.attributes.chapter, let titleNum1 = $1.attributes.chapter else{ return false}
                return  titleNum0.localizedStandardCompare(titleNum1) == .orderedAscending
            }
            withAnimation{ chapterResults = apiChapterResults}
        }catch{
            //MARK: Make error alert here
        }
    }
}

struct ReadingView : View{
    
    var viewChapterID: String

    @State private var messageAlertError = ""
    @State private var showingChapterAlert = false
    
    @State private var chapterPages = [String]()
    
    var body: some View{
        let _ = print("chap pag\(chapterPages.count)")
        ScrollView {
            VStack{
                ForEach(chapterPages, id:\.self){ pageLink in
                    
                    AsyncImage(url: URL(string: pageLink)){ image in
                        image
                            .resizable()
                            .scaledToFill()
                    }  placeholder: {   ProgressView().padding(150)  }
                    
                }//For Each Ends Here
                
            }//VStack ends here
            
        }//Scroll View Ends Here
        
        .alert("There was an error", isPresented: $showingChapterAlert){}
        message:{ Text(messageAlertError)}
        /* I have forgotten the need of this onChange hence I commented it out while I was shortening my code
            .onChange(of: baseUrl, perform: { newValue in
                    Task{  await getChapterPages()   }
            })//On Change ends here
        */
            .task { await getChapterPages() }//Task ends here
           
    }//Body ends here
    
    func getChapterPages() async{
        if let decodedResponse = try? await FeedChapter.getChapterPageImageURLs(chapterID: viewChapterID){
          chapterPages = decodedResponse
        }else{
            showingChapterAlert = true
            messageAlertError = "If let failed when getting page links. Most likely chapter id fault"
        }
    }

    
}

struct ChaptersView_Previews: PreviewProvider {
    static var previews: some View {
        ChaptersView(chosenManga: Manga.produceExampleManga())
    }
}

