import SwiftUI

struct SideMenuView: View {
    
    @Binding var selectedSideMenuTab: Int
    @Binding var presentSideMenu: Bool
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(.white)
                    .frame(width: 270)
                    .shadow(color: profileViewModel.selectedColor.opacity(0.1), radius: 5, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 0) {
                    // Profile Image as a tappable row
                    Button(action: {
                        selectedSideMenuTab = SideMenuRowType.profile.rawValue
                        presentSideMenu.toggle() // Toggle the side menu visibility
                    }) {
                        ProfileImageView()
                            .frame(height: 140)
                            .padding(.bottom, 30)
                    }

                    // Side Menu Rows
                    ForEach(SideMenuRowType.allCases, id: \.self) { row in
                        if row != .profile { // Skip profile since it's handled separately
                            RowView(isSelected: selectedSideMenuTab == row.rawValue, imageName: row.iconName, title: row.title) {
                                selectedSideMenuTab = row.rawValue
                                presentSideMenu.toggle()
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.top, 100)
                .frame(width: 270)
                .background(Color.white)
            }
            Spacer()
        }
        .background(.clear)
    }
    
    func ProfileImageView() -> some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                if let profileImage = profileViewModel.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(profileViewModel.selectedColor.opacity(0.5), lineWidth: 10)
                        )
                        .cornerRadius(50)
                } else {
                    Image("profile") 
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(profileViewModel.selectedColor.opacity(0.5), lineWidth: 10)
                        )
                        .cornerRadius(50)
                }
                Spacer()
            }
            
            Text("User Name")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
        }
    }
    
    func RowView(isSelected: Bool, imageName: String, title: String, hideDivider: Bool = false, action: @escaping (() -> ())) -> some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading) {
                HStack(spacing: 20) {
                    Rectangle()
                        .fill(isSelected ? profileViewModel.selectedColor : .white)
                        .frame(width: 5)
                    
                    ZStack {
                        // Custom image asset instead of SF Symbol
                        Image(imageName)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(isSelected ? .black : .gray)
                            .frame(width: 26, height: 26)
                    }
                    .frame(width: 30, height: 30)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(isSelected ? .black : .gray)
                    Spacer()
                }
            }
        }
        .frame(height: 50)
        .background(
            LinearGradient(colors: [isSelected ? profileViewModel.selectedColor.opacity(0.5) : .white, .white], startPoint: .leading, endPoint: .trailing)
        )
    }

}

#Preview {
    SideMenuView(selectedSideMenuTab: .constant(0), presentSideMenu: .constant(false))
        .environmentObject(ProfileViewModel(context: PersistenceController.preview.container.viewContext))
}

