//
//  ReadingList.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 30/11/2022.
//

import SwiftUI

struct ReadingList: View {
    
    @State private var readingListManga = [Manga]()
    @State private var readingListChapters = [FeedChapter]()
    
    func getReadingManga(){
        let lastRead = GetLastRead()
        for item in lastRead{
            readingListManga.append(item.MangaDetail)
            readingListChapters.append(item.Chapter)
        }
    }
    
    func deleteItemFromLastRead(at offest : IndexSet){
        var listOfRead = GetLastRead()
        withAnimation{
            listOfRead.remove(atOffsets: offest)
            readingListManga.remove(atOffsets: offest)
            readingListChapters.remove(atOffsets: offest)
        }
        updateLastReadChapter(with: listOfRead)
    }
    
    var readingMangaListView : some View{
        List{
            ForEach(readingListManga.indices, id: \.self){ index in
                let manga = readingListManga[index]
                let chapter = readingListChapters[index]
                NavigationLink(destination: ReadingView(viewChapterID: chapter.id)){
                    HStack{
                        VStack(alignment: .leading){
                            MangaView(item: manga)
                            FeedChapter.buildChapterNameView(chapter)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                //HStack, Spacer and .contentShape make on tap gesture apply on entire list row area
            }
            .onDelete(perform: deleteItemFromLastRead)
          /*  .toolbar{
                EditButton()
            }*/
        }
    }
    
    var body: some View {
        
        if !readingListManga.isEmpty{
            readingMangaListView
        }else{
            Text("You Haven't Started Any Manga \n :D")
                .task {
                    getReadingManga()
                }
        }
    }
}

struct ReadingList_Previews: PreviewProvider {
    static var previews: some View {
        ReadingList()
    }
}
