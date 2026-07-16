import SwiftUI

struct MainTabView: View {
    @StateObject private var mealViewModel = MealViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Discover
            DiscoverView()
                .environmentObject(mealViewModel)
                .tabItem {
                    Label("Discover", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: Favorites
            FavoritesView()
                .environmentObject(mealViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(1)
            
            // Tab 3: Cookbook
            CookbookView()
                .environmentObject(mealViewModel)
                .tabItem {
                    Label("Cookbook", systemImage: "book.fill")
                }
                .tag(2)
            
            // Tab 4: Profile
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.green)
        .task {
            // Load categories when app starts
            await mealViewModel.loadCategories()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
