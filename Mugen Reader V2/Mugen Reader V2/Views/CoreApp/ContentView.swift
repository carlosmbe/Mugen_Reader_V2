//
//  ContentView.swift
//  Mugen Reader V2
//
//  Created by Carlos Mbendera on 23/10/2022.
//

import SwiftUI



struct ContentView: View {
    
    let seasonId = "77430796-6625-4684-b673-ffae5140f337"
    
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    @State private var searchText = ""
    @State private var title = "Seasonal"
    @State private var mangaResults = [Manga]()
    @State private var homeMangaResults = [Manga]()//This is more of a cache cause I put search results manga in MangaResults sometimes
    @State private var wantsListView = true  // This variable controls the layout
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var columns: [GridItem] {
        switch horizontalSizeClass {
        case .compact:
            return Array(repeating: .init(.flexible()), count: 2)
        case .regular:
            return Array(repeating: .init(.flexible()), count: 4)
        default:
            return Array(repeating: .init(.flexible()), count: 2)
        }
    }
        
    var MangaGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(mangaResults) { manga in
                    NavigationLink(destination: MangaDescription(selectedManga: manga)) {
                        MangaView(item: manga)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var MangaListView : some View{
        List(mangaResults){ manga in
            NavigationLink(destination: MangaDescription(selectedManga: manga)){
                HStack{
                    MangaView(item: manga)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
        }
    }
    
    var ToolBarItems: some View {
            Group {
                NavigationLink(destination: Downloads() ){
                    Label("Downloads", systemImage: "arrow.down.circle")
                }
                
                NavigationLink(destination: ReadingList()){
                    Label("Reading List", systemImage: "bookmark")
                }
                
                Toggle(isOn: $wantsListView) {
                    Text("List View")
                }
                
            }
        }
    
    var body: some View {
        
        Group{
            
            if mangaResults.isEmpty{
                VStack{
                    ProgressView()
                    Text("We're trying to get you some manga").padding()
                    Text("UwU").padding()
                }
            } else {
                if wantsListView {
                    MangaListView
                } else {
                    MangaGridView
                }
            }
            
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _ in
            if searchText.isEmpty{
                mangaResults = homeMangaResults
                title = "Seasonal"
            }
        }
        .onSubmit(of: .search) {
            Task{   await tryAPICallAgain()    }
        }
        
        .toolbar{
            ToolBarItems
             }
        .navigationTitle(title)
        
        
        .alert(isPresented: $showingErrorAlert){
            Alert(
                title: Text("There was an error :<")
                ,primaryButton: Alert.Button.default(Text("Try Again")){
                    Task{   await tryAPICallAgain() }
                }
                ,secondaryButton: .cancel()
            )}//Alert Closure Ends Here
        
        
        .task{  await getHomePageManga()    }
        
    }
    
    
    //This function checks if we're trying to a search again or a inital homepage load
    func tryAPICallAgain() async{
        if searchText.isEmpty{
            if homeMangaResults.isEmpty{
                await getHomePageManga()
            }else{
                mangaResults = homeMangaResults
                title = "Seasonal"
            }
            
            
        }//if search is empty it means the call was not done by a search error. Thus it was trying to get home page.
        else{
            let searchURL = Manga.buildSearchLink(for: searchText)
            do{
                mangaResults = try await Manga.callMangaDexAPI(for: searchURL)
                title = "Search Results"
            }catch{
                print("error is \(error.localizedDescription.debugDescription)")
                errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
                showingErrorAlert = true
            }
        }//Else Try Searching Again
        
    }//func ends here
    
    func getHomePageManga() async{
        do{
            print("Start Get Home Page")
            let builtLink = try  await Manga.buildSeasonalMangaCall(seasonListId: seasonId)
            homeMangaResults =  try await Manga.callMangaDexAPI(for: builtLink )
            withAnimation{ mangaResults = homeMangaResults }
            title = "Seasonal"
        }catch{
            errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
            showingErrorAlert = true
        }
        
    }
    
}//Home View Ends here

    
    

struct ContentViewGridViewOnly: View {
    
    let seasonId = "77430796-6625-4684-b673-ffae5140f337"
    
    
    //  @StateObject private var chosenMangaAlt = MangaClass()
    
    //   @State private var chosenManga = Manga.produceExampleManga()
    
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    @State private var searchText = ""
    
    @State private var title = "Seasonal"
    
    @State private var mangaResults = [Manga]()
    
    var animateMangaResults : [Manga]{
        get{mangaResults}
        set{mangaResults = newValue}
    }
    
    @State private var homeMangaResults = [Manga]()//This is more of a cache cause I put search results manga in MangaResults sometimes

    
    /*
    var ToolBarItems : some View{
        Group{
            NavigationLink(destination: Downloads()){
                Image(systemName: "arrow.down.circle")
            }
            NavigationLink(destination: ReadingList()){
                Image(systemName: "bookmark")
            }
        }
    }
    */
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var columns: [GridItem] {
        switch horizontalSizeClass {
        case .compact:
            return Array(repeating: .init(.flexible()), count: 2)
        case .regular:
            return Array(repeating: .init(.flexible()), count: 4)
        default:
            return Array(repeating: .init(.flexible()), count: 2)
        }
    }
        
    var MangaGridView: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(mangaResults) { manga in
                        NavigationLink(destination: MangaDescription(selectedManga: manga)) {
                            MangaView(item: manga)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    
    
    
    var body: some View {
        
        Group{
            
            if mangaResults.isEmpty{
                VStack{
                    ProgressView()
                    
                    Text("We're trying to get you some manga")
                        .padding()
                    
                    Text("UwU")
                        .padding()
                }
            }
            
            MangaGridView
                .searchable(text: $searchText)
                .onChange(of: searchText) { _ in
                    if searchText.isEmpty{
                        mangaResults = homeMangaResults
                        title = "Seasonal"
                    }
                }
                .onSubmit(of: .search) {
                    Task{   await tryAPICallAgain()    }
                }
                .toolbar{
                    //Commented out for testing
                    //MARK: ToolBarItems
                }
                .navigationTitle(title)
                .alert(isPresented: $showingErrorAlert){
                    Alert(
                        title: Text("There was an error :<")
                        ,primaryButton: Alert.Button.default(Text("Try Again")){
                            Task{   await tryAPICallAgain() }
                        }
                        ,secondaryButton: .cancel()
                    )}//Alert Closure Ends Here
            
            
        }
        .task{  await getHomePageManga()    }
        //MARK: I moved the Navigation View to App and need somewhere to put to this task. Hence I used a Group
        
    }
    
    //This function checks if we're trying to a search again or a inital homepage load
    func tryAPICallAgain() async{
        if searchText.isEmpty{
            if homeMangaResults.isEmpty{
                await getHomePageManga()
            }else{
                mangaResults = homeMangaResults
                title = "Seasonal"
            }
            
            
        }//if search is empty it means the call was not done by a search error. Thus it was trying to get home page.
        else{
            let searchURL = Manga.buildSearchLink(for: searchText)
            do{
                mangaResults = try await Manga.callMangaDexAPI(for: searchURL)
                title = "Search Results"
            }catch{
                print("error is \(error.localizedDescription.debugDescription)")
                errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
                showingErrorAlert = true
            }
        }//Else Try Searching Again
        
    }//func ends here
    
    func getHomePageManga() async{
        do{
            print("Start Get Home Page")
            let builtLink = try  await Manga.buildSeasonalMangaCall(seasonListId: seasonId)
            homeMangaResults =  try await Manga.callMangaDexAPI(for: builtLink )
            withAnimation{ mangaResults = homeMangaResults }
            title = "Seasonal"
        }catch{
            errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
            showingErrorAlert = true
        }
        
    }
    
}//Home View Ends here

struct ContentViewListViewOnly: View {
    
    let seasonId = "77430796-6625-4684-b673-ffae5140f337"
    
    
    //  @StateObject private var chosenMangaAlt = MangaClass()
    
    //   @State private var chosenManga = Manga.produceExampleManga()
    
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    @State private var searchText = ""
    
    @State private var title = "Seasonal"
    
    @State private var mangaResults = [Manga]()
    
    var animateMangaResults : [Manga]{
        get{mangaResults}
        set{mangaResults = newValue}
    }
    
    @State private var homeMangaResults = [Manga]()//This is more of a cache cause I put search results manga in MangaResults sometimes

    
    /*
    var ToolBarItems : some View{
        Group{
            NavigationLink(destination: Downloads()){
                Image(systemName: "arrow.down.circle")
            }
            NavigationLink(destination: ReadingList()){
                Image(systemName: "bookmark")
            }
        }
    }
    */
    
    
    var MangaListView : some View{
        List(mangaResults){ manga in
            NavigationLink(destination: MangaDescription(selectedManga: manga)){
                HStack{
                    MangaView(item: manga)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            //HStack, Spacer and .contentShape make on tap gesture apply on entire list row area
        }
    }
    
    
    
    var body: some View {
        
        Group{
            
            if mangaResults.isEmpty{
                VStack{
                    ProgressView()
                    
                    Text("We're trying to get you some manga")
                        .padding()
                    
                    Text("UwU")
                        .padding()
                }
            }
            
            MangaListView
                .searchable(text: $searchText)
                .onChange(of: searchText) { _ in
                    if searchText.isEmpty{
                        mangaResults = homeMangaResults
                        title = "Seasonal"
                    }
                }
                .onSubmit(of: .search) {
                    Task{   await tryAPICallAgain()    }
                }
                .toolbar{
                    //Commented out for testing
                    //MARK: ToolBarItems
                }
                .navigationTitle(title)
                .alert(isPresented: $showingErrorAlert){
                    Alert(
                        title: Text("There was an error :<")
                        ,primaryButton: Alert.Button.default(Text("Try Again")){
                            Task{   await tryAPICallAgain() }
                        }
                        ,secondaryButton: .cancel()
                    )}//Alert Closure Ends Here
            
            
        }
        .task{  await getHomePageManga()    }
        //MARK: I moved the Navigation View to App and need somewhere to put to this task. Hence I used a Group
        
    }
    
    
    
    
    
    //This function checks if we're trying to a search again or a inital homepage load
    func tryAPICallAgain() async{
        if searchText.isEmpty{
            if homeMangaResults.isEmpty{
                await getHomePageManga()
            }else{
                mangaResults = homeMangaResults
                title = "Seasonal"
            }
            
            
        }//if search is empty it means the call was not done by a search error. Thus it was trying to get home page.
        else{
            let searchURL = Manga.buildSearchLink(for: searchText)
            do{
                mangaResults = try await Manga.callMangaDexAPI(for: searchURL)
                title = "Search Results"
            }catch{
                print("error is \(error.localizedDescription.debugDescription)")
                errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
                showingErrorAlert = true
            }
        }//Else Try Searching Again
        
    }//func ends here
    
    func getHomePageManga() async{
        do{
            print("Start Get Home Page")
            let builtLink = try  await Manga.buildSeasonalMangaCall(seasonListId: seasonId)
            homeMangaResults =  try await Manga.callMangaDexAPI(for: builtLink )
            withAnimation{ mangaResults = homeMangaResults }
            title = "Seasonal"
        }catch{
            errorMessage = "I need to figure out how to display custom Error Enums Messages Here"
            showingErrorAlert = true
        }
        
    }
    
}//Home View Ends here






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
